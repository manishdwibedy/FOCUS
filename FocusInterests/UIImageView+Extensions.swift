//
//  UIImageView+Extensions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func roundedImage() {

        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
