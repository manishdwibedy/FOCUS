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
import SCLAlertView

class FirstSignUpViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usPhoneLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneNumberEmailView: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneEmailSwitcher: UISegmentedControl!
    
    var typeOfSignUpSelected = "phone"
    let darkBlueBackgroundColor = UIColor(red: 21/255.0, green: 41/255.0, blue: 65/255.0, alpha: 1.0)
    let limeGreenColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberEmailView.addBottomBorderWithColor(color: UIColor.white, width: 1)
        
        self.nextButton.roundCorners(radius: 9.0)
        self.phoneTextField.keyboardType = .numberPad
        self.emailTextField.isHidden = true
        
        self.phoneTextField.delegate = self
        self.emailTextField.delegate = self
        self.customizeSwitcherAppearance()
        hideKeyboardWhenTappedAround()
    }
    
    func customizeSwitcherAppearance() {
        self.phoneTextField.setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        //        var attr = NSDictionary(object: UIFont(name: "Avenir", size: 20.0)!, forKey: NSFontAttributeName as NSCopying)
        
        self.phoneEmailSwitcher.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Avenir", size: 20.0)!,NSForegroundColorAttributeName:UIColor.white], for: .normal)
        
        self.phoneEmailSwitcher.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "Avenir", size: 20.0)!,NSForegroundColorAttributeName: self.limeGreenColor], for:.selected)
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        
        self.phoneTextField.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        
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
            PhoneAuthProvider.provider().verifyPhoneNumber("+1\(self.phoneTextField.text!)") { (verificationID, error) in
                if ((error) != nil) {
                    print(error ?? "")
                } else {
                    print(verificationID ?? "")
                    UserDefaults.standard.set(verificationID, forKey: "firebase_verification")
                    UserDefaults.standard.synchronize()
                }
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                let code = alertView.addTextField("Enter your verification code")
                alertView.addButton("Next") {
                    let credential = PhoneAuthProvider.provider().credential(
                        withVerificationID: UserDefaults.standard.string(forKey: "firebase_verification")!,
                        verificationCode: code.text!)
                    if credential != nil{
                        self.performSegue(withIdentifier: "next", sender: credential)
                    }
                    else{
                        SCLAlertView().showError("Invalid code", subTitle: "Please enter a valid code.")
                    }
                    
                }
                alertView.showSuccess("Button View", subTitle: "This alert view has buttons")
                
            }
        }
        else{
            self.performSegue(withIdentifier: "next", sender: nil)
        }
    }
    
    
    
    @IBAction func typeOfSignUpWasSelected(_ sender: Any) {
        phoneTextField.resignFirstResponder()
        if phoneEmailSwitcher.selectedSegmentIndex == 0 {
            
            self.emailTextField.isHidden = true
            self.usPhoneLabel.isHidden = false
            self.phoneTextField.isHidden = false
        } else {
            self.usPhoneLabel.isHidden = true
            self.phoneTextField.isHidden = true
            self.emailTextField.isHidden = false
            
            self.emailTextField.keyboardType = .emailAddress
            self.emailTextField.returnKeyType = .done
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            if let destinationVC = segue.destination as? SecondSignUpViewController {
                guard phoneTextField.text != nil else { return }
                switch self.phoneEmailSwitcher.selectedSegmentIndex {
                case 0:
                    self.typeOfSignUpSelected = "phone"
                    destinationVC.usersEmailOrPhone = self.phoneTextField.text!
                    destinationVC.credential = sender as! PhoneAuthCredential
                case 1:
                    self.typeOfSignUpSelected = "email"
                    destinationVC.usersEmailOrPhone = self.emailTextField.text!
                default:
                    return
                }
                destinationVC.typeOfSignUp = self.typeOfSignUpSelected
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTextField {
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            
            let components = newString.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            
            if (length - index) > 3
            {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
            
//            let phoneNumber = textField.text
//            
//            if phoneNumber?.characters.count == 3{
//                textField.text = phoneNumber! + "-"
//                return false
//            }
//            else if phoneNumber?.characters.count == 7{
//                textField.text = phoneNumber! + "-"
//                return false
//            }
//            return true
        }
        return true
    }
    
    
    
    // MARK - TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func unwindToFirstSignUpVC(sender: UIStoryboardSegue){}
}
