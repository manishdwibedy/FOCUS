//
//  EditProfileViewController.swift
//  FocusInterests
//
//  Created by Nicolas on 24/05/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SCLAlertView

class EditProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var genderTf: UITextField!
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var infoTf: UITextField!
    @IBOutlet weak var websiteTf: UITextField!
    @IBOutlet weak var usernameTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var profilePhotoView: UIImageView!
    
    let genders = ["Not Specified", "Male", "Female"]
    let ACCEPTABLE_CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789_."
    
    var doneButton: UIBarButtonItem!
    var userPickerView: UIPickerView!
    var userId: String!
    var hasSelectedGender: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fillDataFromUser()
        hideKeyboardWhenTappedAround()
        
        genderTf.delegate = self
        usernameTf.delegate = self
        
        self.userPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 190))
        self.userPickerView.delegate = self
        self.userPickerView.dataSource = self
        self.userPickerView.backgroundColor = UIColor.lightGray
        self.userPickerView.alpha = 0.9
        self.genderTf.inputView = self.userPickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        doneButton.tintColor = UIColor.blue
        doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Heavy", size: 15.0)!], for: .normal)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!]
        
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        toolBar.isUserInteractionEnabled = true
        self.genderTf.inputAccessoryView = toolBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
         return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("you have selected a row")
        self.genderTf.text = genders[row]
    }
    
    func doneButtonPressed(){
        print("done has been pressed")
        self.genderTf.resignFirstResponder()
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
                let email_str = dictionnary!["email"] as? String ?? ""
                let phone_str = dictionnary!["phone_nbr"] as? String ?? ""

                
                
                // SET CONTENT
                self.usernameTf.text = username_str
                self.nameTf.text = name_str
                self.websiteTf.text = website_str
                self.infoTf.text = description_str
                
                self.emailTf.text = email_str
                self.phoneTf.text = phone_str
                self.genderTf.text = gender_str
                
                // SET PROFILE PHOTO
                let image_str = dictionnary!["image_string"] as! String
                self.profilePhotoView.roundedImage()
                self.profilePhotoView.sd_setImage(with: URL(string: image_str), placeholderImage: UIImage(named: "empty_event"))
                
                
            }
            
        }

    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues([
            "username": self.usernameTf.text ?? "",
            "fullname": self.nameTf.text ?? "",
            "website": self.websiteTf.text ?? "",
            "description": self.infoTf.text ?? "",
            "email": self.emailTf.text ?? "",
            "phone_nbr": self.phoneTf.text ?? "",
            "gender": self.genderTf.text ?? ""
            ])
        
        uploadImage(image:profilePhotoView.image!, path: Constants.storage.user_profile.child(AuthApi.getFirebaseUid()!))
        
        self.dismiss(animated: true, completion: nil)
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

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {
    
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
    
    
//    @IBOutlet weak var genderTf: UITextField!
//    @IBOutlet weak var phoneTf: UITextField!
//    @IBOutlet weak var emailTf: UITextField!
//    @IBOutlet weak var infoTf: UITextField!
//    @IBOutlet weak var websiteTf: UITextField!
//    @IBOutlet weak var usernameTf: UITextField!
//    @IBOutlet weak var nameTf: UITextField!
//    @IBOutlet weak var profilePhotoView: UIImageView!
//    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTf{
            usernameTf.becomeFirstResponder()
        }
        else if textField == usernameTf{
            
            Constants.DB.user_mapping.observeSingleEvent(of: .value, with: {snapshot in
                if ((snapshot.value as? NSDictionary)?[self.usernameTf.text ?? ""]) != nil{
                    SCLAlertView().showError("Error", subTitle: "Please choose a unique username.")
                    textField.becomeFirstResponder()
                }
                else{
                    Constants.DB.user_mapping.child(AuthApi.getUserName()!).removeValue()
                    Constants.DB.user_mapping.child(textField.text!).setValue(AuthApi.getUserEmail())
                    AuthApi.set(username: textField.text)
                }
            })
            
            websiteTf.becomeFirstResponder()
        }
        else if textField == websiteTf{
            infoTf.becomeFirstResponder()
        }
        else if textField == infoTf{
            emailTf.becomeFirstResponder()
        }
        else if textField == emailTf{
            phoneTf.becomeFirstResponder()
        }
        else if textField == phoneTf{
            genderTf.becomeFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameTf{
            let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
            return (string == filtered)
        }
        return true
    }
}
