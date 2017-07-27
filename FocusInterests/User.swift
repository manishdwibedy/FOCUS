//
//  User.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class User: Equatable {
    
    var username: String?
    var fullname: String?
    var uuid: String?
    var userImage: UIImage?
    var interests: [Interest]?
    var image_string: String?
    var hasPin: Bool = false
    var pinDistance = 0.0
    var pinCaption = ""
    var matchingInterestCount = 0
    
    init(username: String?, fullname: String?, uuid: String?, userImage: UIImage?, interests: [Interest]?, image_string: String?, hasPin: Bool?) {
        self.username =  username
        self.fullname = fullname
        self.uuid = uuid
        self.userImage = userImage
        self.interests = interests
        self.image_string = image_string
        self.hasPin = hasPin ?? false
    }
    
    static func toUser(info: [String: Any]) -> User?{
        guard let username = info["username"] as? String else{
            return nil
        }
        
        guard let fullname = info["fullname"] as? String else{
            return nil
        }
        
        guard let id = info["firebaseUserId"] as? String else{
            return nil
        }
        
        guard let image = info["image_string"] as? String else{
            return nil
        }
        
        guard let interests = info["interests"] as? String else{
            return nil
        }
        
        var user_interests = [Interest]()
        for interest in interests.components(separatedBy: ","){
            let interest_name = interest.components(separatedBy: "-")[0]
            
            user_interests.append(Interest(name: interest_name, category: nil, image: nil, imageString: nil))
        }
        
        
        return User(username: username, fullname: fullname, uuid: id, userImage: nil, interests: user_interests, image_string: image, hasPin: false)
        
    }
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
