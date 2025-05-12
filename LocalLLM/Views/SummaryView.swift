//
//  SummaryView.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import SwiftUI

struct SummaryView: View {
    let receipt: Receipt
    @State private var showShareSheet = false
    @State private var shareText = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: Model
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .center, spacing: 5) {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                        .padding(.top)
                    
                    Text("Your Bill")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Here's a summary of your selected items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                
                // Selected items section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Selected Items")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    if selectedItems.isEmpty {
                        Text("No items selected")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(selectedItems) { item in
                            HStack {
                                Text(item.label)
                                Spacer()
                                Text(formatCurrency(item.amount))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Your Total")
                            .font(.headline)
                        Spacer()
                        Text(formatCurrency(receipt.selectedTotal))
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Receipt details section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Receipt Details")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    if let imageData = receipt.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Receipt Total")
                            .font(.subheadline)
                        Spacer()
                        Text(formatCurrency(receipt.total))
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    
                    HStack {
                        Text("Date")
                            .font(.subheadline)
                        Spacer()
                        Text(formatDate(receipt.timestamp))
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: 15) {
                    Button(action: {
                        prepareShareText()
                        showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Return to home screen
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "house")
                            Text("Done")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: shareText)
        }
    }
    
    private var selectedItems: [ReceiptItem] {
        receipt.items.filter { $0.isSelected }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func prepareShareText() {
        var text = "My Bill\n\n"
        
        for item in selectedItems {
            text += "\(item.label): \(formatCurrency(item.amount))\n"
        }
        
        text += "\nTotal: \(formatCurrency(receipt.selectedTotal))"
        
        shareText = text
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SummaryView(receipt: Receipt(
                items: [
                    ReceiptItem(label: "Burger", amount: 12.99, isSelected: true),
                    ReceiptItem(label: "Fries", amount: 4.99, isSelected: true),
                    ReceiptItem(label: "Soda", amount: 2.99, isSelected: false)
                ],
                rawText: "Sample receipt"
            ))
            .environmentObject(Model())
        }
    }
}