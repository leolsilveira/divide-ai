//
//  ReceiptScanner.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import Foundation
import Vision
import VisionKit
// Removed UIKit import to make it platform-agnostic

class ReceiptScanner {
    // Removed convertToGrayScale as it depended on UIImage.
    // Grayscale conversion should happen before calling this, if needed.

    // Changed function signature to accept CGImage
    func recognizeText(from cgImage: CGImage) async throws -> String {
        // NOTE: Grayscale conversion logic removed. If needed, apply before getting CGImage.

        // Use the provided cgImage directly
        print("⚙️ Starting text recognition directly from CGImage.")
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            try requestHandler.perform([request])

            guard let observations = request.results else {
                return ""
            }

            // Extract lines directly from observations as suggested
            let lines = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            // --- New Parsing Logic ---

            let nonItemKeywords: Set<String> = [
                "HOTEL", "MOTEL", "RESTAURANT", "CAFE", "BAR", "STORE", "RECEIPT",
                "SUBTOTAL", "SUB-TOTAL", "TAX", "VAT", "GST", "HST", "PST",
                "TOTAL", "AMOUNT", "BALANCE", "CASH", "CREDIT", "CARD", "MASTERCARD", "VISA", "AMEX",
                "CHANGE", "DUE", "PAID", "TIP", "GRATUITY",
                "INVOICE", "ORDER", "TABLE", "GUEST", "SERVER", "CLERK",
                "DATE", "TIME", "PHONE", "WEBSITE", "ADDRESS",
                "ITEM", "DESCRIPTION", "QTY", "PRICE", "SUB", "TAXES",
                "DISCOUNT", "SAVINGS", "COUPON",
                "AUTH", "SIGNATURE", "PIN", "VERIFIED", "APPROVED", "TRANSACTION"
            ]

            let potentialItemLines = lines.filter { line in
                let upperLine = line.uppercased()
                // Filter out lines that are likely headers, footers, or summary info
                if nonItemKeywords.contains(where: { keyword in upperLine.contains(keyword) }) {
                    // More aggressive filtering for lines that are *only* keywords or very short
                    if upperLine.split(whereSeparator: { $0.isWhitespace }).allSatisfy({ nonItemKeywords.contains(String($0)) }) || line.count < 5 {
                         print("Filtering out metadata line: \(line)")
                         return false
                    }
                }
                // Keep lines that seem to have a price at the end or start with a number
                if line.range(of: "\\d+\\.\\d{2}$", options: String.CompareOptions.regularExpression) != nil || line.range(of: "^\\d+", options: String.CompareOptions.regularExpression) != nil {
                    return true
                }
                // Filter out very short lines that didn't match price/qty patterns
                if line.count < 8 && !line.contains("$") { // Heuristic
                    print("Filtering out short/non-item line: \(line)")
                    return false
                }
                return true // Default to keep if not obviously metadata
            }
            
            print("👀 Potential Item Lines after filtering:")
            potentialItemLines.forEach { print("  - \($0)") }
            print("------------------------")

            var parsedItems: [[String: Any?]] = []
            // Regex: ^(\d+)\s+(.+?)\s+\$?(\d+\.\d{2})$
            // Group 1: Quantity (digits)
            // Group 2: Label (anything, non-greedy)
            // Group 3: Price (digits.digits) with optional $
            let itemRegex = #"^(\d+(?:\.\d+)?)\s+(.+?)\s+\$?(\d+\.\d{2})$"# // Allow decimal quantity

            for line in potentialItemLines {
                if let match = line.range(of: itemRegex, options: String.CompareOptions.regularExpression) {
                    let nsRange = NSRange(match, in: line)
                    if let regex = try? NSRegularExpression(pattern: itemRegex) {
                        let results = regex.matches(in: line, range: nsRange)
                        if let firstResult = results.first, firstResult.numberOfRanges == 4 {
                            let quantityString = (line as NSString).substring(with: firstResult.range(at: 1))
                            let label = (line as NSString).substring(with: firstResult.range(at: 2)).trimmingCharacters(in: .whitespaces)
                            let totalPriceString = (line as NSString).substring(with: firstResult.range(at: 3))

                            guard let quantity = Double(quantityString), let totalPrice = Double(totalPriceString) else {
                                print("⚠️ Could not parse quantity/price for line: \(line)")
                                continue
                            }

                            var unitPrice: Double? = nil
                            if quantity > 0 {
                                unitPrice = totalPrice / quantity
                            }
                            
                            // Round unitPrice to 2 decimal places if not nil
                            if var up = unitPrice {
                                unitPrice = round(up * 100) / 100
                            }

                            let itemDict: [String: Any?] = [
                                "label": label,
                                "quantity": quantity,
                                "unitPrice": unitPrice,
                                "totalPrice": totalPrice
                            ]
                            parsedItems.append(itemDict)
                            print("✅ Parsed Item: \(itemDict)")
                        }
                    }
                } else {
                     print("🚫 No regex match for line: \(line)")
                }
            }
            
            let resultDict = ["items": parsedItems]
            var jsonString = "{\"items\":[]}" // Default to empty items JSON

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: resultDict, options: [.prettyPrinted]) // Use .prettyPrinted for easier debugging
                if let MjsonString = String(data: jsonData, encoding: .utf8) {
                    jsonString = MjsonString
                }
            } catch {
                print("Error serializing JSON: \(error)")
            }

            print("📝 FINAL JSON STRING to be returned by ReceiptScanner:")
            print(jsonString)
            print("------------------------")

            return jsonString
        } // End of recognizeText function
}
