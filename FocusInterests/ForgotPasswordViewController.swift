//
//  ForgotPasswordViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/14/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController, UITextViewDelegate{

    @IBOutlet weak var emailTextFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var delegate: LoginViewControllerDelegate?
    
    let screenSize = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailTextView.delegate = self
        self.emailTextView.textContainer.maximumNumberOfLines = 1
        let myString = NSMutableAttributedString(string: "Enter your email", attributes : [NSForegroundColorAttributeName: UIColor.lightGray,NSFontAttributeName: UIFont(name: "Avenir Book", size: 19)!,NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        
        
        self.emailTextView.attributedText = myString
        self.emailTextView.textAlignment = .center
        
        self.submitButton.roundCorners(radius: 6.0)
        
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        print("sending email to user")
        Auth.auth().sendPasswordReset(withEmail: emailTextView.text!) { (error) in
            if error == nil{
                
            }
        }
        self.delegate?.showPopup()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.emailTextView.text = ""
        if self.emailTextView.intrinsicContentSize.width >= (self.screenSize.width - 32){
            self.emailTextView.adjustsFontForContentSizeCategory = true
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
