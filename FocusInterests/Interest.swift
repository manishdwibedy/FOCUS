//
//  Interest.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

enum InterestCategory: String {
    
    case Sports = "sports"
    case Art = "art"
    case Nightlife = "nightlife"
    case Food = "food"
    case Shopping = "shopping"
}

enum InterestStatus{
    case normal
    case like
    case love
    case hate
    
    mutating func toggle() {
        switch self {
        case .normal:
            self = .like
        case .like:
            self = .love
        case .love:
            self = .normal
        case .hate:
            break
        }
    }
}

class Interest {
    
    var name: String?
    var category: InterestCategory?
    var image: UIImage?
    var imageString: String?
    var status: InterestStatus = .normal
    
    init(name: String?, category: InterestCategory?, image: UIImage?, imageString: String?) {
        self.name = name
        self.category = category
        self.image = image
        self.imageString = imageString
    }
    
    func addStatus(status: InterestStatus){
        self.status = status
        
    }
}
