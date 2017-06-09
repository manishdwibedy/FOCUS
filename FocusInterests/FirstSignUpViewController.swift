//
//  FirstSignUpViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/4/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class FirstSignUpViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneOrEmailTextField: UITextField!
    @IBOutlet weak var phoneEmailSwitcher: UISegmentedControl!
    var typeOfSignUpSelected = "phone"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneOrEmailTextField.setBottomBorder()
        self.phoneOrEmailTextField.keyboardType = .numberPad
        self.phoneOrEmailTextField.delegate = self
        phoneOrEmailTextField.setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        
        hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if phoneEmailSwitcher.selectedSegmentIndex == 0{
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneOrEmailTextField.text!) { (verificationID, error) in
                if ((error) != nil) {
                    print(error)
                } else {
                    print(verificationID)
                    UserDefaults.standard.set(verificationID, forKey: "firebase_verification")
                    UserDefaults.standard.synchronize()
                }
            }
        }
        else{
            self.performSegue(withIdentifier: "next", sender: nil)
        }
    }
    
    @IBAction func typeOfSignUpWasSelected(_ sender: Any) {
        phoneOrEmailTextField.resignFirstResponder()
        if phoneEmailSwitcher.selectedSegmentIndex == 0 {
            self.phoneOrEmailTextField.placeholder = "Phone Number"
            self.phoneOrEmailTextField.keyboardType = .numberPad
        } else {
            self.phoneOrEmailTextField.placeholder = "Email"
            self.phoneOrEmailTextField.keyboardType = .emailAddress
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            if let destinationVC = segue.destination as? SecondSignUpViewController {
                guard let validEntry = phoneOrEmailTextField.text else { return }
                switch self.phoneEmailSwitcher.selectedSegmentIndex {
                case 0:
                    self.typeOfSignUpSelected = "phone"
                case 1:
                    self.typeOfSignUpSelected = "email"
                default:
                    return
                }
                destinationVC.typeOfSignUp = self.typeOfSignUpSelected
                destinationVC.usersEmailOrPhone = validEntry
            }
        }
    }
    // MARK - TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func unwindToFirstSignUpVC(sender: UIStoryboardSegue){}
}
