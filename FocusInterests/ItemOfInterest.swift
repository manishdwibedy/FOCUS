//
//  ItemOfInterest.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class ItemOfInterest: NSObject, NSCoding {
    
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
    
    required init(coder decoder: NSCoder) {
        self.itemName = decoder.decodeObject(forKey: "itemName") as? String
        self.imageURL = decoder.decodeObject(forKey: "imageURL") as? String
        self.type = decoder.decodeObject(forKey: "type") as? String ?? ""
        self.id = decoder.decodeObject(forKey: "id") as? String ?? ""
        self.data = decoder.decodeObject(forKey: "data") as? NSDictionary
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.itemName, forKey: "itemName")
        coder.encode(self.imageURL, forKey: "imageURL")
        coder.encode(self.type, forKey: "type")
        coder.encode(self.id, forKey: "id")
        coder.encode(self.data, forKey: "data")
    }
}
