//
//  UITextField+Extensions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/25/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    class func whitePlaceholder(text: String, textField: UITextField) {
        let attrString = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName:UIColor.appTextFPlaceholder()])
        textField.attributedPlaceholder = attrString
    }
    
    func setBottomBorder() {
        self.borderStyle = .none
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.layoutSublayers()
        self.layer.masksToBounds = true
    }
}
