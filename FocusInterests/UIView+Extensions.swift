//
//  UIView+Extensions.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension UIView{
    func topCornersRounded(radius: Double){
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        
        self.layer.mask = rectShape
    }
    
    func allCornersRounded(radius: Double){
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight , .topLeft, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
        
        self.layer.mask = rectShape
    }

}
