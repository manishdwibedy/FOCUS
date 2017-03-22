//
//  UserProfile1ViewController+UIImagePickerC.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

extension UserProfile1ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Got image: \(info)")
        if let userImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            self.cellImageDelegate?.set(image: userImage)
            FirebaseUpstream.sharedInstance.uploadProfileImage(image: userImage, completion: { (url) in
                self.user?.setImageString(imageString: String(describing: url))
            })

        }
                dismiss(animated: true, completion: nil)
    }
    
    func presentImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let granted = SettingsPermissionChecker.checkLibraryPermission()
            if defaults.bool(forKey: "libraryDialoguePresented") {
                if granted {
                    self.pickerController.delegate = self
                    self.pickerController.sourceType = .photoLibrary
                    self.pickerController.allowsEditing = true
                    self.present(pickerController, animated: true, completion: nil)
                    
                }
            } else {
                PHPhotoLibrary.requestAuthorization({ (authStatus) in
                    if authStatus == .authorized {
                        SettingsPermissionChecker.libraryDialoguePresented()
                        self.pickerController.delegate = self
                        self.pickerController.sourceType = .photoLibrary
                        self.pickerController.allowsEditing = true
                        self.present(self.pickerController, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let granted = SettingsPermissionChecker.checkCameraPermission()
            
            if !defaults.bool(forKey: "cameraDialoguePresented") {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                    if granted {
                        self.pickerController.delegate = self
                        self.pickerController.sourceType = .camera
                        self.pickerController.allowsEditing = true
                        SettingsPermissionChecker.cameraDialoguePresented()
                        self.present(self.pickerController, animated: true, completion: nil)
                    } else {
                        self.mustHavePermissionsAlert(permissionType: "camera use")
                    }
                })
            } else {
                if granted {
                    self.pickerController.delegate = self
                    self.pickerController.sourceType = .camera
                    self.pickerController.allowsEditing = true
                    self.present(self.pickerController, animated: true, completion: nil)
                } else {
                    mustHavePermissionsAlert(permissionType: "camera use")
                }
            }
        }
    }
    
    func showPickerActionSheet() {
        let alert = UIAlertController(title: "Photo from?", message: "Create Photo or Use Existing", preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.primaryGreen()
        let actionCamera = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
            self.accessCamera()
        }
        let actionLibrary = UIAlertAction(title: "Choose Photo", style: .default) { (alert) in
            self.presentImagePicker()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCamera)
        alert.addAction(actionLibrary)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func mustHavePermissionsAlert(permissionType: String) {
        let alert = UIAlertController(title: "Permission Denied", message: "In order to use this feature, you must change Focus's permission for \(permissionType) in your device's settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
