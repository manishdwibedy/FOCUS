//
//  EventIconViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseStorage
import SwiftyCam
import Photos

class EventIconViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var event: Event?
    var imageData: Data?
    let storage = Storage.storage()
    
    @IBOutlet weak var cameraTabBttn: UITabBarItem!
    @IBOutlet weak var photoLibraryTabItem: UITabBarItem!
    @IBOutlet weak var videoTabItem: UITabBarItem!
    @IBOutlet weak var skipTabItem: UITabBarItem!
    @IBOutlet weak var eventIcon: UIImageView!
    
    //
    var flipCameraButton: UIButton!
    var flashButton: UIButton!
    var dismissButton: UIButton!
    var captureButton: SwiftyRecordButton!
    var lastImageButton: UIButton!
    var imagePicker = UIImagePickerController()
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraDelegate = self
        shouldUseDeviceOrientation = true
        
        imagePicker.delegate = self
        
        allowAutoRotate = false
        audioEnabled = false
        
        addButtons()
        fetchPhotos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageData != nil{
            self.performSegue(withIdentifier: "event_invite", sender: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let newVC = PhotoViewController(image: photo)
        newVC.parentVC = self
        self.present(newVC, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }, completion: { (success) in
                focusView.removeFromSuperview()
            })
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print(camera)
    }
    
    @objc private func cameraSwitchAction(_ sender: Any) {
        switchCamera()
    }
    
    @objc private func dismiss(_ sender: Any) {
        self.performSegue(withIdentifier: "event_invite", sender: nil)
    }
    
    @objc private func toggleFlashAction(_ sender: Any) {
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState())
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
        }
    }
    
    @objc private func showGallery(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func addButtons() {
        
        captureButton = SwiftyRecordButton(frame: CGRect(x: view.frame.midX - 37.5, y: view.frame.height - 100.0, width: 75.0, height: 75.0))
        self.view.addSubview(captureButton)
        captureButton.delegate = self
        
        // dismiss button
        
        dismissButton = UIButton(frame: CGRect(x: (view.frame.width - 70.0), y: 20, width: 50.0, height: 23.0))
        dismissButton.setTitle("Skip", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        self.view.addSubview(dismissButton)
        
        // lower left -> last image
        
        lastImageButton = UIButton(frame: CGRect(x: (((view.frame.width / 2 - 37.5) / 2) - 25.0), y: view.frame.height - 90.0, width: 50.0, height: 50.0))
        lastImageButton.addTarget(self, action: #selector(showGallery(_:)), for: .touchUpInside)
        self.view.addSubview(lastImageButton)
        
        
        // upper left -> flash
        
        flashButton = UIButton(frame: CGRect(x: 30, y: 20, width: 50.0, height: 23.0))
        flashButton.setImage(#imageLiteral(resourceName: "flash"), for: .normal)
        flashButton.addTarget(self, action: #selector(toggleFlashAction(_:)), for: .touchUpInside)
        self.view.addSubview(flashButton)
        
        // lower right -> flip camera
        
        let test = CGFloat((view.frame.width - (view.frame.width / 2 + 37.5)) + ((view.frame.width / 2) - 37.5) - 9.0)
        
        flipCameraButton = UIButton(frame: CGRect(x: test, y: view.frame.height - 77.5, width: 30.0, height: 23.0))
        flipCameraButton.setImage(#imageLiteral(resourceName: "CameraSwitch"), for: UIControlState())
        flipCameraButton.addTarget(self, action: #selector(cameraSwitchAction(_:)), for: .touchUpInside)
        self.view.addSubview(flipCameraButton)
    }
    
    
    
    func fetchPhotos () {
        self.fetchPhotoAtIndexFromEnd(index: 0)
    }
    
    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndexFromEnd(index:Int) {
        
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Sort the images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions) {
            
            // If the fetch result isn't empty,
            // proceed with the image request
            if fetchResult.count > 0 {
                // Perform the image request
                imgManager.requestImage(for: fetchResult.object(at: fetchResult.count - 1 - index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                    self.lastImageButton.setImage(image, for: .normal)
                })
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let edited = info[UIImagePickerControllerEditedImage] as? UIImage{
            picker.dismiss(animated: true, completion: { _ in
                let newVC = PhotoViewController(image: edited)
                newVC.parentVC = self
                self.present(newVC, animated: true, completion: nil)
            })
        }
        else if let original = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: { _ in
                let newVC = PhotoViewController(image: original)
                newVC.parentVC = self
                self.present(newVC, animated: true, completion: nil)
            })
        }
    }

    
//    private func chooseFromGallery(){
//        picker.allowsEditing = true
//        picker.sourceType = .photoLibrary
//        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
//        present(picker, animated: true, completion: nil)
//    }
//    
//    private func chooseFromCamera(){
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.allowsEditing = false
//            picker.sourceType = UIImagePickerControllerSourceType.camera
//            picker.cameraCaptureMode = .photo
//            picker.modalPresentationStyle = .fullScreen
//            picker.allowsEditing = true
//            present(picker,animated: true,completion: nil)
//        }
//    }
//    
//    @IBAction func cameraSelected(_ sender: UIBarButtonItem) {
//        chooseFromCamera()
//    }
//    
//    @IBAction func photoSelected(_ sender: UIBarButtonItem) {
//        chooseFromGallery()
//    }
//    
//    
//    
//    @IBAction func skipImage(_ sender: UIBarButtonItem) {
//        skipPickingImage()
//    }
//    // MARK: ImagePickerController Delegate Methods
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage //2
//        eventIcon.contentMode = .scaleAspectFit //3
//        eventIcon.image = chosenImage //4
//        self.imageData = UIImagePNGRepresentation(chosenImage)
//        dismiss(animated:true, completion: nil)
//    }
//    
//    func createPin(sender: UIBarButtonItem){
//        self.performSegue(withIdentifier: "event_invite", sender: nil)
//    }
    
    private func skipPickingImage(){
        self.performSegue(withIdentifier: "event_invite", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "event_invite"{
            let destinationVC = segue.destination as! SendInvitationsViewController
            destinationVC.event = self.event
            destinationVC.image = self.imageData
        }
    }
    
}
