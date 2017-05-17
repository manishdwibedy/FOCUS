//
//  EventIconViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseStorage

class EventIconViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarDelegate{
    
    var event: Event?
    let picker = UIImagePickerController()
    var imageData: Data?
    let storage = FIRStorage.storage()
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var cameraTabBttn: UITabBarItem!
    @IBOutlet weak var photoLibraryTabItem: UITabBarItem!
    @IBOutlet weak var videoTabItem: UITabBarItem!
    @IBOutlet weak var skipTabItem: UITabBarItem!
    @IBOutlet weak var eventIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        tabBar.delegate = self
        formatNavBar()
        setupTabBar()
    }
    
    // MARK: - Tab Bar Delegate Method
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item {
        case cameraTabBttn:
            chooseFromCamera()
        case photoLibraryTabItem:
            chooseFromGallery()
        case videoTabItem:
            break
        // to do
        case skipTabItem:
            skipPickingImage()
        default:
            return
        }
    }
    
    // MARK: ImagePickerController Delegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        eventIcon.contentMode = .scaleAspectFit //3
        eventIcon.image = chosenImage //4
        self.imageData = UIImagePNGRepresentation(chosenImage)
        dismiss(animated:true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    private func chooseFromGallery(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    private func chooseFromCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        }
    }
    
    func createPin(sender: UIBarButtonItem){
        let id = self.event?.saveToDB(ref: Constants.DB.event)
        
        if let data = imageData{
            let imageRef = Constants.storage.event.child("\(id!).jpg")
            
            // Create file metadata including the content type
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = imageRef.put(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("\(error!)")
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let _ = metadata.downloadURL
            }
        }
        self.performSegue(withIdentifier: "event_invite", sender: nil)
    }
    
    private func skipPickingImage(){
        let _ = self.event?.saveToDB(ref: Constants.DB.event)
        self.performSegue(withIdentifier: "event_invite", sender: nil)
    }
    
    // MARK: - UI Set Up
    
    private func setupTabBar() {
        // lines 115-121 create seperators between each tab bar item
        let itemWidth = floor(self.tabBar.frame.size.width / CGFloat(self.tabBar.items!.count))
        let separatorWidth: CGFloat = 0.5
        for i in 0...(self.tabBar.items!.count - 2) {
            let separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i + 1) - CGFloat(separatorWidth / 2), y: 0.2 * self.tabBar.frame.size.height, width: CGFloat(separatorWidth), height: self.tabBar.frame.size.height * 0.6))
            separator.backgroundColor = UIColor.white
            self.tabBar.addSubview(separator)
        }
        let attributes = [
            NSFontAttributeName:UIFont(name: "American Typewriter", size: 18),
            NSForegroundColorAttributeName:UIColor.white
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
    }
    
    private func formatNavBar(){
        self.navigationItem.title = "Choose Photo"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.createPin(sender:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindFromSendInvites(sender: UIStoryboardSegue){}
    
    
}
