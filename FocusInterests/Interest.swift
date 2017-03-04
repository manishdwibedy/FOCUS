//
//  Interest.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

enum InterestCategory {
    
    case Sports
    case Art
    case Nightlife
    case Food
    case Shopping
}

class Interest {
    
    var name: String?
    var category: InterestCategory?
    var image: UIImage?
    
    init(name: String?, category: InterestCategory?, image: UIImage?) {
        self.name = name
        self.category = category
        self.image = image
    }
}
