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
    var uuid: String?
    var userImage: UIImage?
    var interests: [Interest]?
    var image_string: String?
    
    init(username: String?, uuid: String?, userImage: UIImage?, interests: [Interest]?, image_string: String?) {
        self.username =  username
        self.uuid = uuid
        self.userImage = userImage
        self.interests = interests
        self.image_string = image_string
    }
}
