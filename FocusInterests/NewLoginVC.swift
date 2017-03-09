//
//  NewLoginVC.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn

class NewLoginVC: UIViewController, GIDSignInUIDelegate {
    
    let handle = FIRAuth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle?.addStateDidChangeListener({ (auth, user) in
            if let u = user {
                print("user uid: \(u.uid)")
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        handle?.removeStateDidChangeListener(handle!)
    }
}
