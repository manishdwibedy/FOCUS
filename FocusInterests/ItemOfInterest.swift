//
//  ItemOfInterest.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class ItemOfInterest {
    
    var itemName: String?
    var features: [Feature]?
    var mainImage: UIImage?
    var distance: String?
    
    init(itemName: String?, features: [Feature]?, mainImage: UIImage?, distance: String?) {
        self.itemName = itemName
        self.features = features
        self.mainImage = mainImage
        self.distance = distance
    }
}
