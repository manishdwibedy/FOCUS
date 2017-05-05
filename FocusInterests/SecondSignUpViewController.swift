//
//  SecondSignUpViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/4/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase

class SecondSignUpViewController: BaseViewController, UITextFieldDelegate {

    var usersEmailOrPhone: String = ""
    var typeOfSignUp: String = ""
    var userName: String = ""
    var password: String = ""
    var fullName: String = ""
    
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
    }
    
    @IBAction func finishBttnPressed(_ sender: Any) {
        print("bttn was pressed")
        switch typeOfSignUp {
        case "phone":
            let formatedString = formatPhoneString(phoneNumber: usersEmailOrPhone)
            FIRAuth.auth()!.createUser(withEmail: formatedString, password: "", completion: { (user, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
            })
        default:
            return
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


}
