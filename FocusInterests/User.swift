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
    var isPrivate = false
    
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
        let user = User(username: username, fullname: fullname, uuid: id, userImage: nil, interests: user_interests, image_string: image, hasPin: false)
        
        if let isPrivate = info["private"] as? Bool{
            user.isPrivate = isPrivate
        }
        else{
            user.isPrivate = false
        }
        return user
        
    }
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    static func blockUser(uid: String){
        
        Constants.DB.user.child(uid).child("blocked/people").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:Any]
            
            if value == nil{
                Constants.DB.user.child(uid).child("blocked/people").childByAutoId().updateChildValues([
                    "UID": AuthApi.getFirebaseUid()!,
                    "time": Date().timeIntervalSince1970
                    ])
            }
        })
        
    }
    
//    static func unFollowUser(uid: String){
//        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").queryOrdered(byChild: "UID").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? [String:Any]
//            
//            for (id, _) in value!{
//                Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people/\(id)").removeValue()
//            }
//            
//        })
//        Constants.DB.user.child(uid).child("followers").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? [String:Any]
//            
//            if let value = value{
//                for (id, _) in value{
//                    Constants.DB.user.child(uid).child("followers/people/\(id)").removeValue()
//                    
//                }
//            }
//            
//            
//        })
//    }
}
