//
//  ReceiptScanner.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import Foundation
import Vision
import VisionKit
import UIKit

class ReceiptScanner {
    func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ReceiptScannerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage from UIImage"])
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        try requestHandler.perform([request])
        
        guard let observations = request.results else {
            return ""
        }
        
        let extractedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        
        // Log the extracted receipt text
        print("📝 RECEIPT TEXT EXTRACTED:")
        print(extractedText)
        print("------------------------")
        
        return extractedText
    }
}