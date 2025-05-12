//
//  WelcomeView.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var navigateToCamera = false
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 15) {
                Image(systemName: "doc.text.viewfinder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Receipt Scanner")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Scan, Split, Share")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            
            // Features section
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "camera.viewfinder",
                    title: "Scan Receipts",
                    description: "Quickly capture and process receipts with your camera"
                )
                
                FeatureRow(
                    icon: "checklist",
                    title: "Select Your Items",
                    description: "Choose only the items you want to pay for"
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Share Results",
                    description: "Easily share your bill with friends and family"
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
            
            // Scan button
            NavigationLink(destination: CameraView().environmentObject(model), isActive: $navigateToCamera) {
                Button(action: {
                    navigateToCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Scan Receipt")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 40)
            }
            
            // App version
            Text("Version 1.0")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .padding()
        .navigationTitle("Receipt Scanner")
        .navigationBarHidden(true)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(Model())
    }
}