//
//  UITextView+Extensions.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/27/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension UITextView{
    func roundCorners(radius: Double){
        self.layer.cornerRadius = CGFloat(radius)
    }
    
    func addBorder(width: Double, color: UIColor){
        self.layer.borderWidth = CGFloat(width)
        self.layer.borderColor = color.cgColor
    }
}
