//
//  ItemSelectionView.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import SwiftUI

struct ItemSelectionView: View {
    @State var receipt: Receipt
    @State private var navigateToSummary = false
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            // Header with total information
            VStack(spacing: 5) {
                Text("Select Your Items")
                    .font(.headline)
                
                Text("Receipt Total: \(formatCurrency(receipt.total))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            
            // List of items with checkboxes
            List {
                ForEach(0..<receipt.items.count, id: \.self) { index in
                    ItemRow(item: $receipt.items[index])
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            // Footer with selected total
            VStack(spacing: 10) {
                Divider()
                
                HStack {
                    Text("Your Subtotal:")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formatCurrency(receipt.selectedTotal))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                // Select all/none buttons
                HStack(spacing: 20) {
                    Button(action: selectAllItems) {
                        Text("Select All")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: deselectAllItems) {
                        Text("Select None")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 5)
                
                // Continue button
                Button(action: {
                    navigateToSummary = true
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .navigationTitle("Select Items")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: SummaryView(receipt: receipt)
                    .environmentObject(model),
                isActive: $navigateToSummary
            ) {
                EmptyView()
            }
        )
    }
    
    private func selectAllItems() {
        for index in 0..<receipt.items.count {
            receipt.items[index].isSelected = true
        }
    }
    
    private func deselectAllItems() {
        for index in 0..<receipt.items.count {
            receipt.items[index].isSelected = false
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

struct ItemRow: View {
    @Binding var item: ReceiptItem
    
    var body: some View {
        HStack {
            Button(action: {
                item.isSelected.toggle()
            }) {
                Image(systemName: item.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(item.isSelected ? .blue : .gray)
                    .font(.system(size: 20))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading) {
                Text(item.label)
                    .font(.body)
            }
            
            Spacer()
            
            // Display quantity and unit price if available, otherwise just total price
            VStack(alignment: .trailing) {
                Text(formatCurrency(item.totalPrice)) // Use totalPrice
                    .font(.body)
                    .foregroundColor(item.isSelected ? .blue : .primary)
                if item.quantity != 1.0 || item.unitPrice != nil {
                    Text(itemDetailText(item: item))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            item.isSelected.toggle()
        }
    }

    // Helper to format item details (quantity/unit price)
    private func itemDetailText(item: ReceiptItem) -> String {
        var details: [String] = []
        if item.quantity != 1.0 {
            // Format quantity nicely (e.g., remove .0)
            let quantityString = String(format: "%g", item.quantity)
            details.append("Qty: \(quantityString)")
        }
        if let unitPrice = item.unitPrice {
            details.append("(@ \(formatCurrency(unitPrice)))")
        }
        return details.joined(separator: " ")
    }

     // Helper function copied from main view for preview
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$" // Or use locale-specific symbol
        return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }
}

struct ItemSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemSelectionView(receipt: Receipt(
                items: [
                    // Update initializer to use totalPrice and add other fields
                    ReceiptItem(label: "Burger", quantity: 1.0, unitPrice: 12.99, totalPrice: 12.99),
                    ReceiptItem(label: "Fries", quantity: 2.0, unitPrice: 2.50, totalPrice: 5.00), // Example with quantity
                    ReceiptItem(label: "Soda", quantity: 1.0, unitPrice: nil, totalPrice: 2.99) // Example with no unit price
                ],
                rawText: "Sample receipt"
            ))
            .environmentObject(Model())
        }
    }
}
