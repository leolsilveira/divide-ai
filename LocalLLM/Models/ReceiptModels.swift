//
//  ReceiptModels.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import Foundation

// Receipt item model
struct ReceiptItem: Identifiable, Codable {
    var id = UUID()
    var label: String
    var quantity: Double = 1.0 // Default to 1 if not specified
    var unitPrice: Double?     // Unit price might not always be present
    var totalPrice: Double     // Renamed from 'price', represents total for the line
    var isSelected: Bool = false
}

// Receipt model
struct Receipt: Identifiable, Codable {
    var id = UUID()
    var items: [ReceiptItem]
    var rawText: String
    var imageData: Data?
    var timestamp: Date = Date()
    
    var total: Double {
        items.reduce(0) { $0 + $1.totalPrice } // Use totalPrice
    }

    var selectedTotal: Double {
        items.filter { $0.isSelected }.reduce(0) { $0 + $1.totalPrice } // Use totalPrice
    }
}