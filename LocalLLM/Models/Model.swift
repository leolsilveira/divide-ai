//
//  Model.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import Foundation
import LLM

class Model: LLM {
    convenience init() {
        let url = Bundle.main.url(forResource: "gemma-3-1b-it-Q4_K_S", withExtension: "gguf")!
        // System prompt focused on the exact output format
        let systemPrompt = """
        You are an AI assistant. Your sole function is to process text and return a JSON object.
        Your entire output must be ONLY the JSON object. No introductory text, no explanations, no markdown.
        """
        self.init(from: url, template: .chatML(systemPrompt))!
        
    }
    
    // Helper struct to decode the LLM's JSON response (matches the updated schema)
    private struct LLMResponse: Codable {
        let items: [ReceiptItem] // Assumes ReceiptItem now includes quantity, unitPrice, totalPrice
    }

    func extractReceiptItems(from jsonString: String) -> [ReceiptItem] { // Changed to synchronous, text is now jsonString
        // The 'jsonString' parameter is now expected to be the JSON output
        // directly from ReceiptScanner.swift

        print("📄 Received JSON string for parsing in Model.swift:")
        print(jsonString)
        print("------------------------")
        
        // Attempt to parse the expected {"items": [...]} structure
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let decodedResponse = try JSONDecoder().decode(LLMResponse.self, from: jsonData)
                return decodedResponse.items
            } catch {
                print("Failed to decode LLMResponse from provided JSON: \(error). Attempting fallback parsing.")
                // Fallback parsing if the primary structure is not matched
                return parseItemsManually(from: jsonString)
            }
        }
        
        print("Failed to convert jsonString to data. Returning empty array.")
        return []
    }
    
    private func parseItemsManually(from responseText: String) -> [ReceiptItem] {
        // Try to extract a JSON array directly from the response text
        // This handles cases where the LLM might output just the array `[...]`
        // or a slightly malformed JSON that still contains a valid array part.
        
        // First, attempt to decode as LLMResponse if the string looks like a complete object
        if responseText.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{"),
           let jsonData = responseText.data(using: .utf8) {
            do {
                let decodedResponse = try JSONDecoder().decode(LLMResponse.self, from: jsonData)
                return decodedResponse.items
            } catch {
                // Silently ignore, will try array parsing next
            }
        }

        // Attempt to find and parse just an array `[...]`
        if let arrayStartIndex = responseText.firstIndex(of: "["),
           let arrayEndIndex = responseText.lastIndex(of: "]"),
           arrayStartIndex < arrayEndIndex {
            
            let jsonArrayString = String(responseText[arrayStartIndex...arrayEndIndex])
            if let jsonData = jsonArrayString.data(using: .utf8) {
                // Attempt 1: Decode as [ReceiptItem]
                do {
                    let items = try JSONDecoder().decode([ReceiptItem].self, from: jsonData)
                    print("Fallback: Successfully decoded as [ReceiptItem].")
                    return items
                } catch {
                    print("Fallback: Failed to decode directly as [ReceiptItem]: \(error).")
                    // Proceed to attempt 2 below
                }

                // Attempt 2: Decode as LLMResponse (only if Attempt 1 failed)
                do {
                    let decodedResponse = try JSONDecoder().decode(LLMResponse.self, from: jsonData)
                    print("Fallback: Successfully decoded as LLMResponse.")
                    return decodedResponse.items
                } catch {
                    print("Fallback: Failed to decode as LLMResponse: \(error).")
                    // Proceed to final return [] below
                }
            }
        }
        
        print("Fallback: Could not parse items manually. Returning empty array.")
        return []
    }
}
