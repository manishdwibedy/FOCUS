//
//  FirstLoginVC.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/22/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class FirstLoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.backgroundColor = UIColor.primaryGreen()
        loginButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.backgroundColor = UIColor.appBlue()
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        
    }
    @IBAction func loginTapped(_ sender: Any) {
        
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
    }
}
