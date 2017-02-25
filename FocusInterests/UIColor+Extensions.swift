//
//  UIColor+Extensions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func primaryGreen() -> UIColor {
        let primaryGreen = UIColor(colorLiteralRed: 43.0/255, green: 197.0/255, blue: 12.0/277.0, alpha: 1)
        return primaryGreen
    }
    
    class func appBlue() -> UIColor {
        let appBlue = UIColor(colorLiteralRed: 40 / 255.0, green: 40 / 255.0, blue: 172 / 255.0, alpha: 1)
        return appBlue
    }
    
    class func appTextFPlaceholder() -> UIColor {
        let appTextFPlaceholder = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        return appTextFPlaceholder
    }
}
