//
//  SignUpViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/22/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: BaseViewController {
    @IBOutlet weak var LogoImage: UIImageView!
    
    @IBOutlet weak var realFirstNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var uploadPhotoText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LogoImage.alpha = 0
        
        signUpButton.backgroundColor = UIColor.appBlue()
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signFName, textField: realFirstNameText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signFName, textField: firstNameText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signLName, textField: lastNameText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signEmail, textField: emailText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signPword, textField: passwordText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signUName, textField: userNameText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signLocation, textField: locationText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.signPhoto, textField: uploadPhotoText)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateLogo()
    }
    @IBAction func signUpButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: Constants.otherIds.mainSB, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.otherIds.openingMainVC)
        present(vc, animated: true, completion: nil)
    }
    
    func animateLogo() {
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseIn, animations: {
            self.LogoImage.alpha = 1
        }, completion: nil)
    }
}
