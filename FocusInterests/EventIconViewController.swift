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
        
        self.navigationItem.title = "Choose Icon"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.createPin(sender:)))
        
        let attributes = [
            NSFontAttributeName:UIFont(name: "American Typewriter", size: 18),
            NSForegroundColorAttributeName:UIColor.white
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
        setupTabBar()
    }
    
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
            break
            //to do
        default:
            return
        }
        
    }
    
    
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
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let _ = metadata.downloadURL
            }
        }
        self.performSegue(withIdentifier: "event_invite", sender: nil)
    }
    
    func setupTabBar() {
        
        let itemWidth = floor(self.tabBar.frame.size.width / CGFloat(self.tabBar.items!.count))
        
        // this is the separator width.  0.5px matches the line at the top of the tab bar
        let separatorWidth: CGFloat = 0.5
        
        // iterate through the items in the Tab Bar, except the last one
        for i in 0...(self.tabBar.items!.count - 2) {
            // make a new separator at the end of each tab bar item
            let separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i + 1) - CGFloat(separatorWidth / 2), y: 0.2 * self.tabBar.frame.size.height, width: CGFloat(separatorWidth), height: self.tabBar.frame.size.height * 0.6))
            
            // set the color to light gray (default line color for tab bar)
            separator.backgroundColor = UIColor.white
            
            self.tabBar.addSubview(separator)
        }
    }
    
    
    
    
    
}
