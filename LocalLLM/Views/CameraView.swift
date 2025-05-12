//
//  CameraView.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import SwiftUI
import AVFoundation
import UIKit
import Photos

struct CameraView: View {
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var navigateToProcessing = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @EnvironmentObject var model: Model
    
    var body: some View {
        VStack {
            if let image = image {
                // Show captured image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                HStack(spacing: 30) {
                    Button(action: {
                        self.image = nil
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retake")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        navigateToProcessing = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Use Photo")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
                
                NavigationLink(
                    destination: ProcessingView(image: image)
                        .environmentObject(model),
                    isActive: $navigateToProcessing
                ) {
                    EmptyView()
                }
            } else {
                // Camera placeholder
                VStack {
                    Spacer()
                    
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("Take a photo of your receipt")
                        .font(.headline)
                        .padding()
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            handlePhotoLibraryAccess()
                        }) {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 30))
                                Text("Gallery")
                                    .font(.caption)
                            }
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                        
                        Button(action: {
                            handleCameraAccess()
                        }) {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                Text("Camera")
                                    .font(.caption)
                            }
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Scan Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image, sourceType: sourceType)
        }
        .alert(isPresented: $showingPermissionAlert) {
            Alert(
                title: Text("Permission Required"),
                message: Text(permissionAlertMessage),
                primaryButton: .default(Text("Settings"), action: {
                    PermissionManager.shared.openSettings()
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func handleCameraAccess() {
        let status = PermissionManager.shared.checkPermission(.camera)
        
        switch status {
        case .authorized:
            // Permission already granted
            sourceType = .camera
            showingImagePicker = true
        case .notDetermined:
            // Request permission
            PermissionManager.shared.requestPermission(.camera) { granted in
                if granted {
                    self.sourceType = .camera
                    self.showingImagePicker = true
                } else {
                    self.showPermissionAlert(message: "Camera access is required to scan receipts.")
                }
            }
        case .denied, .restricted:
            // Permission denied
            showPermissionAlert(message: "Camera access is required to scan receipts. Please enable it in Settings.")
        case .unknown:
            showPermissionAlert(message: "Unknown camera permission status. Please try again.")
        }
    }
    
    private func handlePhotoLibraryAccess() {
        let status = PermissionManager.shared.checkPermission(.photoLibrary)
        
        switch status {
        case .authorized:
            // Permission already granted
            sourceType = .photoLibrary
            showingImagePicker = true
        case .notDetermined:
            // Request permission
            PermissionManager.shared.requestPermission(.photoLibrary) { granted in
                if granted {
                    self.sourceType = .photoLibrary
                    self.showingImagePicker = true
                } else {
                    self.showPermissionAlert(message: "Photo library access is required to select receipt images.")
                }
            }
        case .denied, .restricted:
            // Permission denied
            showPermissionAlert(message: "Photo library access is required to select receipt images. Please enable it in Settings.")
        case .unknown:
            showPermissionAlert(message: "Unknown photo library permission status. Please try again.")
        }
    }
    
    private func showPermissionAlert(message: String) {
        permissionAlertMessage = message
        showingPermissionAlert = true
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CameraView()
        }
    }
}