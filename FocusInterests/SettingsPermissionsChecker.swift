//
//  SettingsPermissionsChecker.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import Photos
import AVFoundation

struct SettingsPermissionChecker {
    
    static let defaults = UserDefaults.standard
    
    static func checkCameraPermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch status {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            return false
        case .restricted:
            return false
        }
    }
    
    static func checkLibraryPermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            return false
        case .restricted:
            return false
        }
    }
    
    static func cameraDialoguePresented() {
        defaults.set(true, forKey: "cameraDialoguePresented")
    }
    
    static func libraryDialoguePresented() {
        defaults.set(true, forKey: "libraryDialoguePresented")
    }
}
