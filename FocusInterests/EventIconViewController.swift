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

    @IBOutlet weak var eventIcon: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker.delegate = self
        
        self.navigationItem.title = "Choose Icon"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.createPin(sender:)))
//
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func chooseFromGallery(_ sender: UIBarButtonItem) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func chooseFromCamera(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
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
            let _ = imageRef.put(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let _ = metadata.downloadURL
            }
        }
        self.performSegue(withIdentifier: "show_events", sender: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
