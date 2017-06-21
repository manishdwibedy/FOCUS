//
//  ForgotPasswordViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/14/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your email", attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
        self.emailTextField.setBottomBorder()
        self.submitButton.roundCorners(radius: 6.0)
        
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        print("sending email to user")
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
            if error == nil{
                
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
