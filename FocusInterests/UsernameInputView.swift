//
//  UsernameInputView.swift
//  FocusInterests
//
//  Created by Christopher Gilardi on 6/28/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class UsernameInputView : UIView, UITextFieldDelegate {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var usernameInputField: UITextField!
    
    
    var completion: ((String) -> Void)!
    var error : ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init(frame : CGRect, onCompletion : ((String) -> Void)!, onError: ((String) -> Void)?) {
        self.init(frame: frame)
        self.completion = onCompletion
        self.error = onError
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("UsernameInputView", owner: self, options: nil)
        self.addSubview(self.view)
        print(self.view.frame.size)
        print(self.frame.size)
        self.view.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
        self.view.layoutIfNeeded()
        
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        self.createButton.layer.cornerRadius = 5.0
        self.createButton.clipsToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.removeKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        styleInputField()
    }
    
    func removeKeyboard(){
        usernameInputField.resignFirstResponder()
    }
    
    private func styleInputField() {
        let bottomBorder = CALayer()
        let width = CGFloat(2.0)
        bottomBorder.borderColor = UIColor.appBlue().cgColor
        bottomBorder.frame = CGRect(x: 0, y: usernameInputField.frame.size.height - width, width: usernameInputField.frame.size.width + 25, height: usernameInputField.frame.size.height)
        
        bottomBorder.borderWidth = width
        usernameInputField.layer.addSublayer(bottomBorder)
        usernameInputField.clipsToBounds = true
        
        usernameInputField.delegate = self
    }
    
    private func styleButton() {
        createButton.layer.cornerRadius = 10
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        if !usernameInputField.text!.isEmpty {
            completion(usernameInputField.text!)
        } else {
            if error != nil {
                error!("err_no_input")
            }
        }
        dismissKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        createButtonPressed(UIButton())
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterSet = CharacterSet.letters
        var backspacePressed = false
        
        if (range.length == 1 && string.isEmpty) {
            backspacePressed = true
        }
        
        let uppercase = string.characters.filter{ $0.isUppercase }
        
        print("\(uppercase) | Count = \(uppercase.count)")
        
        if (string.rangeOfCharacter(from: characterSet) != nil || string == "." || string == "_" || backspacePressed) && uppercase.count == 0 {
            return true
        }
        return false
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    
}
