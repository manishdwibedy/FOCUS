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
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneNumberEmailView: UIView!
    @IBOutlet weak var phoneOrEmailTextField: UITextField!
    @IBOutlet weak var phoneEmailSwitcher: UISegmentedControl!
    
    var typeOfSignUpSelected = "phone"
    let darkBlueBackgroundColor = UIColor(red: 21/255.0, green: 41/255.0, blue: 65/255.0, alpha: 1.0)
    let limeGreenColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberEmailView.addBottomBorderWithColor(color: UIColor.white, width: 1)
        
        self.nextButton.roundCorners(radius: 9.0)
        self.phoneOrEmailTextField.keyboardType = .numberPad
        self.phoneOrEmailTextField.delegate = self
        
        self.customizeSwitcherAppearance()
        hideKeyboardWhenTappedAround()
    }
    
    func customizeSwitcherAppearance() {
        self.phoneOrEmailTextField.setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        //        var attr = NSDictionary(object: UIFont(name: "Avenir", size: 20.0)!, forKey: NSFontAttributeName as NSCopying)
        
        self.phoneEmailSwitcher.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Avenir", size: 20.0)!,NSForegroundColorAttributeName:UIColor.white], for: .normal)
        
        self.phoneEmailSwitcher.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Avenir", size: 20.0)!,NSForegroundColorAttributeName: self.limeGreenColor], for:.selected)
        
        self.phoneEmailSwitcher.setBackgroundImage(self.imageWithColor(color: UIColor.clear), for:.normal, barMetrics:.default)
        
        self.phoneEmailSwitcher.setBackgroundImage(self.imageWithColor(color: UIColor.clear), for:.selected, barMetrics:.default)
        
        self.phoneEmailSwitcher.setDividerImage(self.imageWithColor(color: UIColor.white), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        self.phoneEmailSwitcher.setDividerImage(self.imageWithColor(color: UIColor.white), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: self.phoneEmailSwitcher.frame.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
        
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
