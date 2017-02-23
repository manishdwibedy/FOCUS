//
//  SignUpViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/22/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var LogoImage: UIImageView!
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
        
        signUpButton.backgroundColor = UIColor.appBlue()
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        
    }
    @IBAction func signUpButton(_ sender: Any) {
    }
}
