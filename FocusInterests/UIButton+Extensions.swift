//
//  UIButton+Extensions.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension UIButton{
    func roundCorners(radius: Double){
        self.layer.cornerRadius = CGFloat(radius)
        self.clipsToBounds = true
    }
    
    func roundButton(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width/2
    }
}
