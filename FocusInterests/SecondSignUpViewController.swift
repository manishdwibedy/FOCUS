//
//  SecondSignUpViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/4/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SCLAlertView

class SecondSignUpViewController: BaseViewController, UITextFieldDelegate {

    var usersEmailOrPhone: String = ""
    var typeOfSignUp: String = ""
    var userName: String = ""
    var password: String = ""
    var fullName: String = ""
    var user: User? = nil
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.finishButton.isEnabled = false
        formatTextFields()
        setTextFieldDelegates()
        testSegueFromFirstSignUpVC()
        
        fullNameTextField.setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        passwordTextField.setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        userNameTextField.setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        finishButton.roundCorners(radius: 10)
        
        hideKeyboardWhenTappedAround()

    }
    
    @IBAction func finishBttnPressed(_ sender: Any) {
        print("bttn was pressed")
        let validPassword = self.passwordTextField.text as! String
        
        let usernameLength = userNameTextField.text?.characters.count
        if usernameLength! < 2{
            showError(message: "Your username is too short")
            return
        }
        else if usernameLength! > 20{
            showError(message: "Your username is too long")
            return 
        }
        else if self.fullNameTextField.text!.components(separatedBy: " ").count == 1{
            showError(message: "Please enter you full name")
        }
        
        switch typeOfSignUp {
        case "phone":
            let formatedString = formatPhoneString(phoneNumber: usersEmailOrPhone)
            AuthApi.set(firebaseUid: AuthApi.getFirebaseUid()!)
            AuthApi.setPassword(password: validPassword)
            AuthApi.set(loggedIn: .Email)
            Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/username").setValue(self.userNameTextField.text)
            Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/fullname").setValue(self.fullNameTextField.text)
            
        case "email":
            let email = self.usersEmailOrPhone
            
            Constants.DB.user_mapping.child(userNameTextField.text!).observeSingleEvent(of: .value, with: {snapshot in
                let value = snapshot.value as? String
                if value == nil{
                    Auth.auth().createUser(withEmail: email, password: validPassword, completion: { (user, error) in
                        if error != nil {
                            showLoginError(error!)
                        }
                        
                        if let validUser = user {
                            Auth.auth().signIn(withEmail: email, password: validPassword) { (user, error) in
                                AuthApi.set(userEmail: email)
                                AuthApi.set(firebaseUid: validUser.uid)
                                AuthApi.setPassword(password: validPassword)
                                AuthApi.set(loggedIn: .Email)
                                AuthApi.set(username: self.userNameTextField.text)
                                Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/email").setValue(email)
                                Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/username").setValue(self.userNameTextField.text)
                                Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/fullname").setValue(self.fullNameTextField.text)
                                Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/fullname_lowered").setValue(self.fullNameTextField.text?.lowercased())
                                Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/firebaseUserId").setValue(AuthApi.getFirebaseUid()!)
                                Constants.DB.user_mapping.child(self.userNameTextField.text!).setValue(email)
                                self.showHomeVC()
                                
                            }
                        }
                    })
                }
                else{
                    SCLAlertView().showCustom("Oops!", subTitle: "That username is already taken.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
                }
            })
            
        default:
            return
        }
        
    }
    
    func showHomeVC() {
        
        if getUserInterests().characters.count == 0{
            let interestsVC = InterestsViewController(nibName: "InterestsViewController", bundle: nil)
            interestsVC.isNewUser = true
            self.present(interestsVC, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
            present(vc, animated: true, completion: nil)
        }
        
        
    }
    
    func setTextFieldDelegates(){
        let _ = [fullNameTextField,passwordTextField,userNameTextField].map{$0?.delegate = self}
    }
    
    func formatTextFields(){
        let _ = [fullNameTextField, passwordTextField, userNameTextField].map{$0?.setBottomBorder()}
    }
    
    func testSegueFromFirstSignUpVC(){
        print(typeOfSignUp)
        print("\(usersEmailOrPhone)")
    }
    
    func checkAllTextFieldsAreFilled(){
        let textFields = [fullNameTextField,passwordTextField,userNameTextField]
        var textFieldsAreEmpty: Bool = false
        for tF in textFields {
            if (tF?.text?.isEmpty)! {
                textFieldsAreEmpty = true
            }
        }
        if textFieldsAreEmpty {
            self.finishButton.isEnabled = false
        } else {
            self.finishButton.isEnabled = true
        }
    }
    
    
    func formatPhoneString(phoneNumber: String) -> String {
       // add code to turn phoneNumber into valid email
        return ""
    }
    
    // MARK: - TextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkAllTextFieldsAreFilled()
    }

    let ACCEPTABLE_CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789_."

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == userNameTextField{
            let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
            return (string == filtered)

        }
        return true
    }

}
