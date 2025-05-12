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
    var amount: Double
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
        items.reduce(0) { $0 + $1.amount }
    }
    
    var selectedTotal: Double {
        items.filter { $0.isSelected }.reduce(0) { $0 + $1.amount }
    }
}