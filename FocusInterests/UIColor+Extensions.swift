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
        let primaryGreen = UIColor(colorLiteralRed: 14.0/255, green: 177.0/255, blue: 43.0/277.0, alpha: 1)
        return primaryGreen
    }
    
    class func darkGreen() -> UIColor {
        let dg = UIColor(colorLiteralRed: 14/255.0, green: 59/255.0, blue: 14/255.0, alpha: 1.0)
        return dg
    }
    
    class func appBlue() -> UIColor {
        let appBlue = UIColor(colorLiteralRed: 40 / 255.0, green: 40 / 255.0, blue: 172 / 255.0, alpha: 1)
        return appBlue
    }
    
    class func appTextFPlaceholder() -> UIColor {
        let appTextFPlaceholder = UIColor(colorLiteralRed: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        return appTextFPlaceholder
    }
    
    class func randomColorGenerator() -> UIColor {
        let blueValue = Float(Int(arc4random() % 255)) / 255.0
        let greenValue = Float(Int(arc4random() % 255)) / 255.0
        let redValue = Float(Int(arc4random() % 255)) / 255.0
        let randomColor = UIColor(colorLiteralRed: redValue, green: greenValue, blue: blueValue, alpha: 1)
        return randomColor
    }
    
    class func veryLightGrey() -> UIColor {
        let color = UIColor(colorLiteralRed: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        return color
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
