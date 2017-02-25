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
}
