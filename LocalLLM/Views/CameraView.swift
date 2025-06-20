//
//  CameraView.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit // Import UIKit only if available
#endif
import Photos

struct CameraView: View {
    #if canImport(UIKit)
    @State private var image: UIImage? // UIImage is UIKit-specific
    @State private var sourceType: UIImagePickerController.SourceType = .camera // UIImagePickerController is UIKit-specific
    #else
    // Provide alternative state variables or placeholders for non-UIKit platforms if needed
    @State private var image: Data? // Example: Use Data as a placeholder
    @State private var sourceType: Int = 0 // Placeholder type
    #endif
    @State private var showingImagePicker = false
    @State private var navigateToProcessing = false
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @EnvironmentObject var model: Model // Assuming Model is platform-agnostic
    
    var body: some View {
        VStack { // Outer VStack containing everything
            #if canImport(UIKit)
            // --- Entire UI for UIKit platforms ---
            if let uiImage = image {
                // UI for displaying the captured image and buttons
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()

                HStack(spacing: 30) {
                    // Using simplified Button syntax
                    Button { self.image = nil } label: {
                         Label("Retake", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered) // Example style

                    Button { navigateToProcessing = true } label: {
                         Label("Use Photo", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent) // Example style
                }
                .padding()

                // Convert UIImage to Data before passing
                let imageData = uiImage.jpegData(compressionQuality: 0.8) ?? Data()

                // NavigationLink (remains inside the `if let` block)
                NavigationLink(
                    destination: ProcessingView(imageData: imageData)
                        .environmentObject(model),
                    isActive: $navigateToProcessing
                ) { EmptyView() }

            } else {
                // UI for the camera placeholder (when no image is captured yet)
                VStack {
                    Spacer()
                    Image(systemName: "camera.viewfinder")
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100).foregroundColor(.gray)
                    Text("Take a photo of your receipt").font(.headline).padding()
                    Spacer()
                    HStack(spacing: 30) {
                        Button(action: handlePhotoLibraryAccess) {
                            VStack {
                                Image(systemName: "photo.on.rectangle").font(.system(size: 30))
                                Text("Gallery").font(.caption)
                            }
                            .frame(width: 80, height: 80)
                            .contentShape(Rectangle()) // Make whole area tappable
                        }
                        .buttonStyle(.borderedProminent) // Example style

                        Button(action: handleCameraAccess) {
                             VStack {
                                Image(systemName: "camera.fill").font(.system(size: 30))
                                Text("Camera").font(.caption)
                            }
                             .frame(width: 80, height: 80)
                             .contentShape(Rectangle()) // Make whole area tappable
                        }
                         .buttonStyle(.borderedProminent) // Example style
                    }
                    .padding(.bottom, 40)
                } // End placeholder VStack
            } // End if let uiImage = image / else

            #else
            // --- UI for non-UIKit platforms ---
            VStack {
                Text("Camera/Photo Library access is not available on this platform.")
                    .padding()
                // Optionally add alternative UI, e.g., a file importer
            }
            #endif
        } // End outer VStack
        .navigationTitle("Scan Receipt")
        .navigationBarTitleDisplayMode(.inline)
        #if canImport(UIKit)
        .sheet(isPresented: $showingImagePicker) {
            // Ensure ImagePicker is only used when UIKit is available
            ImagePicker(image: $image, sourceType: sourceType)
        }
        #endif
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
        #if canImport(UIKit)
        // This whole function relies on PermissionManager and UIKit types
        // Removed the unnecessary guard let, directly use the singleton
        let permissionManager = PermissionManager.shared
        let status = permissionManager.checkPermission(.camera)

        switch status {
        case .authorized:
            sourceType = .camera
            showingImagePicker = true
        case .notDetermined:
            permissionManager.requestPermission(.camera) { granted in
                if granted {
                    self.sourceType = .camera
                    self.showingImagePicker = true
                } else {
                    self.showPermissionAlert(message: "Camera access is required to scan receipts.")
                }
            }
        case .denied, .restricted:
            showPermissionAlert(message: "Camera access is required to scan receipts. Please enable it in Settings.")
        case .unknown:
             showPermissionAlert(message: "Unknown camera permission status.")
        }
        #else
        // Handle non-UIKit platforms - e.g., show an alert
        showPermissionAlert(message: "Camera access is not available on this platform.")
        #endif
    }

    private func handlePhotoLibraryAccess() {
        #if canImport(UIKit)
        // This whole function relies on PermissionManager and UIKit types
        // Removed the unnecessary guard let, directly use the singleton
        let permissionManager = PermissionManager.shared
        let status = permissionManager.checkPermission(.photoLibrary)

        switch status {
        case .authorized:
            sourceType = .photoLibrary
            showingImagePicker = true
        case .notDetermined:
            permissionManager.requestPermission(.photoLibrary) { granted in
                if granted {
                    self.sourceType = .photoLibrary
                    self.showingImagePicker = true
                } else {
                    self.showPermissionAlert(message: "Photo library access is required to select receipt images.")
                }
            }
        case .denied, .restricted:
            showPermissionAlert(message: "Photo library access is required to select receipt images. Please enable it in Settings.")
        case .unknown:
            showPermissionAlert(message: "Unknown photo library permission status.")
        }
        #else
        // Handle non-UIKit platforms - e.g., show an alert
        showPermissionAlert(message: "Photo Library access is not available on this platform.")
        #endif
    }
    
    private func showPermissionAlert(message: String) {
        permissionAlertMessage = message
        showingPermissionAlert = true
    }
}

#if canImport(UIKit)
// Define ImagePicker only when UIKit is available
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
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
#endif

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CameraView()
        }
    }
}