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
//        self.layer.borderWidth = 2.0
//        self.layer.borderColor = UIColor.redColor().CGColor

    }
}
