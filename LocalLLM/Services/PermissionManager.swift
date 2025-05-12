//
//  PermissionManager.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import Foundation
import AVFoundation
import Photos
import UIKit

enum PermissionType {
    case camera
    case photoLibrary
}

enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
    case unknown
}

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    // Check if permission is granted
    func checkPermission(_ type: PermissionType) -> PermissionStatus {
        switch type {
        case .camera:
            return checkCameraPermission()
        case .photoLibrary:
            return checkPhotoLibraryPermission()
        }
    }
    
    // Request permission
    func requestPermission(_ type: PermissionType, completion: @escaping (Bool) -> Void) {
        switch type {
        case .camera:
            requestCameraPermission(completion: completion)
        case .photoLibrary:
            requestPhotoLibraryPermission(completion: completion)
        }
    }
    
    // Open settings
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Private Methods
    
    private func checkCameraPermission() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .unknown
        }
    }
    
    private func checkPhotoLibraryPermission() -> PermissionStatus {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .unknown
        }
    }
    
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    private func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }
}