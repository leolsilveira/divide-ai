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
        let url = Bundle.main.url(forResource: "Llama-3.2-1B-Instruct-Q4_K_M", withExtension: "gguf")!
        let systemPrompt = "You are a helpful AI assistant specialized in processing receipts."
        self.init(from: url, template: .chatML(systemPrompt))!
    }
    
    func extractReceiptItems(from text: String) async -> [ReceiptItem] {
        let prompt = """
        You are an assistant that extracts items and their prices from receipt text.
        
        Extract all items and their corresponding prices from the following receipt text.
        Return the result as a JSON array with objects containing "label" and "amount" fields.
        Only include actual items purchased, not subtotals, taxes, or totals.
        
        Receipt text:
        \(text)
        
        JSON response:
        """
                
        // Call respond method which updates the output property
        await self.respond(to: prompt)
        
        // Get the response from the output property
        let responseText = self.output
        
        // Log the LLM model response
        print("🤖 LLM MODEL RESPONSE:")
        print(responseText)
        print("------------------------")
        
        // Parse JSON response
        if let jsonData = responseText.data(using: .utf8),
           let items = try? JSONDecoder().decode([ReceiptItem].self, from: jsonData) {
            return items
        }
        
        // Fallback parsing if JSON is not properly formatted
        return parseItemsManually(from: responseText)
    }
    
    private func parseItemsManually(from responseText: String) -> [ReceiptItem] {
        // Extract JSON part from the response
        if let jsonStart = responseText.range(of: "["),
           let jsonEnd = responseText.range(of: "]", options: .backwards),
           jsonStart.lowerBound < jsonEnd.upperBound {
            let jsonText = responseText[jsonStart.lowerBound...jsonEnd.upperBound]
            
            if let jsonData = String(jsonText).data(using: .utf8),
               let items = try? JSONDecoder().decode([ReceiptItem].self, from: jsonData) {
                return items
            }
        }
        return []
    }
}
