//
//  ChangeUsernamePasswordViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/26/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseAuth

class ChangeUsernamePasswordViewController: UIViewController {
    @IBOutlet weak var username: UITextField!

    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if AuthApi.getLoginType() == .Email{
            password.isEnabled = true
            repeatPassword.isEnabled = true
        }
        
        updateButton.roundCorners(radius: 10)
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateUser(_ sender: UIButton) {
        if !(username.text?.isEmpty)! && !(password.text?.isEmpty)! && password.text == repeatPassword.text{
            
            Auth.auth().currentUser?.updatePassword(to: password.text!, completion: { error in
                if error != nil{
                    print(error)
                    SCLAlertView().showError("Invalid password", subTitle: "Couldn't update your password... there was an error.")
                }else{
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
