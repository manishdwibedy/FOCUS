//
//  UIImage+Extensions.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

extension UIImage{
    func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();

        return normalizedImage;
    }

}
