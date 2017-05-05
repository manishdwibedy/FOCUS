//
//  FirstSignUpViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/4/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class FirstSignUpViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneOrEmailTextField: UITextField!
    @IBOutlet weak var phoneEmailSwitcher: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneOrEmailTextField.setBottomBorder()
        self.phoneOrEmailTextField.keyboardType = .numberPad
        self.phoneOrEmailTextField.delegate = self
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
        if segue.identifier == "finishSignUp" {
            let destinationVC = SecondSignUpViewController()
            guard let validEntry = phoneOrEmailTextField.text else { return }
            switch self.phoneEmailSwitcher.selectedSegmentIndex {
            case 0:
                destinationVC.typeOfSignUp = "phone"
            case 1:
                destinationVC.typeOfSignUp = "email"
            default:
                return
            }
            destinationVC.usersEmailOrPhone = validEntry
        }
    }
    
    
    @IBAction func unwindToFirstSignUpVC(sender: UIStoryboardSegue){}
}
