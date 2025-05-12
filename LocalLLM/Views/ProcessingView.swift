//
//  ProcessingView.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import SwiftUI
import UIKit

struct ProcessingView: View {
    let image: UIImage
    @State private var receipt: Receipt?
    @State private var isProcessing = true
    @State private var errorMessage: String?
    @State private var navigateToItemSelection = false
    
    @EnvironmentObject var model: Model
    private let receiptScanner = ReceiptScanner()
    
    var body: some View {
        VStack {
            if isProcessing {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(2)
                        .padding()
                    
                    Text("Processing Receipt...")
                        .font(.headline)
                    
                    Text("Extracting text and identifying items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if let errorMessage = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.orange)
                    
                    Text("Processing Error")
                        .font(.headline)
                    
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button(action: {
                        // Go back to camera view
                        self.navigateToItemSelection = false
                    }) {
                        Text("Try Again")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            } else {
                // Show a success message briefly before navigating
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    
                    Text("Processing Complete")
                        .font(.headline)
                    
                    Text("Found \(receipt?.items.count ?? 0) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    // Navigate to item selection after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        navigateToItemSelection = true
                    }
                }
            }
        }
        .navigationTitle("Processing")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isProcessing)
        .background(
            NavigationLink(
                destination: ItemSelectionView(receipt: receipt ?? Receipt(items: [], rawText: "")),
                isActive: $navigateToItemSelection
            ) {
                EmptyView()
            }
        )
        .onAppear {
            processReceipt()
        }
    }
    
    private func processReceipt() {
        Task {
            do {
                // Step 1: Extract text from image
                let extractedText = try await receiptScanner.recognizeText(from: image)
                
                // Step 2: Process text with LLM to extract items
                let items = await model.extractReceiptItems(from: extractedText)
                
                // Step 3: Create receipt object
                if !items.isEmpty {
                    let imageData = image.jpegData(compressionQuality: 0.7)
                    let newReceipt = Receipt(items: items, rawText: extractedText, imageData: imageData)
                    
                    // Update UI on main thread
                    await MainActor.run {
                        self.receipt = newReceipt
                        self.isProcessing = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "No items could be extracted from the receipt. Please try again with a clearer image."
                        self.isProcessing = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error processing receipt: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProcessingView(image: UIImage(systemName: "doc.text")!)
                .environmentObject(Model())
        }
    }
}