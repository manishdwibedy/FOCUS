//
//  User.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    var username: String?
    var fullname: String?
    var uuid: String?
    var userImage: UIImage?
    var interests: [Interest]?
    var image_string: String?
    var hasPin: Bool = false
    var pinDistance = 0.0
    var pinCaption = ""
    
    init(username: String?, fullname: String?, uuid: String?, userImage: UIImage?, interests: [Interest]?, image_string: String?, hasPin: Bool?) {
        self.username =  username
        self.fullname = fullname
        self.uuid = uuid
        self.userImage = userImage
        self.interests = interests
        self.image_string = image_string
        self.hasPin = hasPin ?? false
    }
}
