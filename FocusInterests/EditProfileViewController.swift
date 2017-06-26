//
//  EditProfileViewController.swift
//  FocusInterests
//
//  Created by Nicolas on 24/05/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var genderTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var infoTf: UITextField!
    @IBOutlet weak var websiteTf: UITextField!
    @IBOutlet weak var usernameTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var profilePhotoView: UIImageView!
    
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fillDataFromUser()
        hideKeyboardWhenTappedAround()
        
        genderTf.addTarget(self, action: "getGender:", forControlEvents: UIControlEvents.TouchDown)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillDataFromUser() {
        FirebaseDownstream.shared.getCurrentUser {[unowned self] (dictionnary) in
            if dictionnary != nil {
                print(dictionnary!)
                
                
                // SET USERID
                
                self.userId = dictionnary!["firebaseUserId"] as? String ?? nil
                
                guard (self.userId != nil) else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                // GET STRING
                let username_str = dictionnary!["username"] as? String ?? ""
                let description_str = dictionnary!["description"] as? String ?? ""
                let gender_str = dictionnary!["gender"] as? String ?? ""
                let name_str = dictionnary!["fullname"] as? String ?? ""
                let website_str = dictionnary!["website"] as? String ?? ""
                //let email_str = dictionnary!["email"] as? String ?? ""
                //let phone_str = dictionnary!["phone_nbr"] as? String ?? ""

                
                
                // SET CONTENT
                self.usernameTf.text = username_str
                self.infoTf.text = description_str
                self.genderTf.text = gender_str
                self.nameTf.text = name_str
                self.websiteTf.text = website_str
                
                // SET PROFILE PHOTO
                let image_str = dictionnary!["image_string"] as! String
                self.profilePhotoView.roundedImage()
                self.profilePhotoView.sd_setImage(with: URL(string: image_str), placeholderImage: UIImage(named: "empty_event"))
                
                
            }
            
        }

    }
    
    func getGender(textField: UITextField) {
        let alertController = UIAlertController(title: "Gender?", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let maleAction = UIAlertAction(title: "Male", style: .default) { action in
            textField.text = "Male"
        }
        let femaleAction = UIAlertAction(title: "Female", style: .default) { action in
            textField.text = "Female"
        }
        alertController.addAction(maleAction)
        alertController.addAction(femaleAction)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneAction(_ sender: Any) {
        
        FirebaseUpstream.sharedInstance.uploadProfileImage_(image: profilePhotoView.image!) { [unowned self] (returnUrl) in
            
            let url = returnUrl as String
            
            let focusUser = FocusUser(userName: self.usernameTf.text, firebaseId: self.userId, imageString: url, currentLocation: nil, name: self.nameTf.text, website: self.websiteTf.text, email: self.emailTf.text, gender: self.genderTf.text, phone: self.phoneTf.text, description: self.infoTf.text)
            
            
            FirebaseUpstream.sharedInstance.addToUsers_(focusUser: focusUser)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func changePhotoAction(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            picker.sourceType = .camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func editAction(_ sender: Any) {
        let selectInterests = InterestsViewController(nibName: "InterestsViewController", bundle: nil)
        self.present(selectInterests, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        profilePhotoView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        profilePhotoView.backgroundColor = UIColor.clear
        profilePhotoView.contentMode = UIViewContentMode.scaleAspectFit
        
        self.profilePhotoView.roundedImage()

        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
