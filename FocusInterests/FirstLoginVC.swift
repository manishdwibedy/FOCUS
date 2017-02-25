//
//  FirstLoginVC.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/22/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

protocol LoginDelegate {
    func login()
}

class FirstLoginViewController: BaseViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var uNameText: UITextField!
    @IBOutlet weak var pWordText: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    
    let appD = UIApplication.shared.delegate as! AppDelegate
    var delegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImage.alpha = 0
        
        animateLogo()
        
        self.delegate = appD
        
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.logVCUname, textField: uNameText)
        UITextField.whitePlaceholder(text: Constants.textfieldPlaceholers.logVCPword, textField: pWordText)
        loginButton.backgroundColor = UIColor.primaryGreen()
        loginButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.backgroundColor = UIColor.appBlue()
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        ifLoggedIn()
    }
    @IBAction func loginTapped(_ sender: Any) {
        defaults.set(true, forKey: Constants.defaultsKeys.loggedIn)
        transition()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
    }
    
    func animateLogo() {
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseIn, animations: {
            self.logoImage.alpha = 1
        }, completion: nil)
    }
    
    func ifLoggedIn() {
        if defaults.bool(forKey: Constants.defaultsKeys.loggedIn) {
            delegate?.login()
        }
    }
    
    func transition() {
        let storyboard = UIStoryboard(name: Constants.otherIds.mainSB, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.otherIds.openingMainVC)
        present(vc, animated: true, completion: nil)
    }
}
