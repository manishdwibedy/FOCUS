//
//  EventIconViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseStorage

class EventIconViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var event: Event?
    let picker = UIImagePickerController()
    var imageData: Data?
    let storage = FIRStorage.storage()
    
    @IBOutlet weak var cameraTabBttn: UITabBarItem!
    @IBOutlet weak var photoLibraryTabItem: UITabBarItem!
    @IBOutlet weak var videoTabItem: UITabBarItem!
    @IBOutlet weak var skipTabItem: UITabBarItem!
    @IBOutlet weak var eventIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
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
    
    @IBAction func cameraSelected(_ sender: UIBarButtonItem) {
        chooseFromCamera()
    }
    
    @IBAction func photoSelected(_ sender: UIBarButtonItem) {
        chooseFromGallery()
    }
    
    
    
    @IBAction func skipImage(_ sender: UIBarButtonItem) {
        skipPickingImage()
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
    
    func createPin(sender: UIBarButtonItem){
        self.performSegue(withIdentifier: "event_invite", sender: nil)
    }
    
    private func skipPickingImage(){
        let _ = self.event?.saveToDB(ref: Constants.DB.event)
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
