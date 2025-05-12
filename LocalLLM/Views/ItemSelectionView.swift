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
            
            Text("$\(String(format: "%.2f", item.amount))")
                .font(.body)
                .foregroundColor(item.isSelected ? .blue : .primary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            item.isSelected.toggle()
        }
    }
}

struct ItemSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemSelectionView(receipt: Receipt(
                items: [
                    ReceiptItem(label: "Burger", amount: 12.99),
                    ReceiptItem(label: "Fries", amount: 4.99),
                    ReceiptItem(label: "Soda", amount: 2.99)
                ],
                rawText: "Sample receipt"
            ))
            .environmentObject(Model())
        }
    }
}