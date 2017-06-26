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
    var imageURL: String?
    var type = ""
    var id = ""
    var data: NSDictionary!
    
    init(itemName: String?, imageURL: String?, type: String) {
        self.itemName = itemName
        self.imageURL = imageURL
        self.type = type
    }
}
