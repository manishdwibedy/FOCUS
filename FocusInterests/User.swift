//
//  User.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject, NSCoding {
    
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
    var readNotifications = 0
    var unreadNotifications = 0
    
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
    
    required init(coder decoder: NSCoder) {
        self.username = decoder.decodeObject(forKey: "username") as? String ?? ""
        self.fullname = decoder.decodeObject(forKey: "fullname") as? String ?? ""
        self.uuid = decoder.decodeObject(forKey: "uuid") as? String ?? ""
        self.userImage = decoder.decodeObject(forKey: "userImage") as? UIImage ?? #imageLiteral(resourceName: "placeholder_people")
        self.interests = decoder.decodeObject(forKey: "interests") as? [Interest]
        self.image_string = decoder.decodeObject(forKey: "image_string") as? String ?? ""
        self.hasPin = decoder.decodeObject(forKey: "hasPin") as? Bool ?? false
        self.pinDistance = decoder.decodeDouble(forKey: "pinDistance") as? Double ?? 0.0
        self.pinCaption = decoder.decodeObject(forKey: "pinCaption") as? String ?? ""
        self.matchingInterestCount = decoder.decodeObject(forKey: "matchingInterestCount") as? Int ?? 0
        self.isPrivate = decoder.decodeBool(forKey: "isPrivate") as? Bool ?? false
        self.readNotifications = decoder.decodeInteger(forKey: "readNotifications") as? Int ?? 0
        self.unreadNotifications = decoder.decodeInteger(forKey: "unreadNotifications") as? Int ?? 0
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.username, forKey: "username")
        coder.encode(self.fullname, forKey: "fullname")
        coder.encode(self.uuid, forKey: "uuid")
        coder.encode(self.userImage, forKey: "userImage")
        coder.encode(self.interests, forKey: "interests")
        coder.encode(self.image_string, forKey: "image_string")
        coder.encode(self.hasPin, forKey: "hasPin")
        coder.encode(self.pinDistance, forKey: "pinDistance")
        coder.encode(self.pinCaption, forKey: "pinCaption")
        coder.encode(self.matchingInterestCount, forKey: "matchingInterestCount")
        coder.encode(self.isPrivate, forKey: "isPrivate")
        coder.encode(self.readNotifications, forKey: "readNotifications")
        coder.encode(self.unreadNotifications, forKey: "unreadNotifications")
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
    
    static func setReadNotifications(read: Int){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues([
            "readCount" : read
            ])
        
        AuthApi.set(read: read)
    }
    
    static func setUnReadNotifications(unread: Int){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues([
            "unreadCount" : unread
            ])
        AuthApi.set(unread: unread)
    }
    
    static func getFollowing(gotFollowing: @escaping (_ result: [User]) -> Void){
        var following = [User]()
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").observeSingleEvent(of: .value, with: {snapshot in
            
            if let people = snapshot.value as? [String:[String:Any]]{
                var count = 0
                
                for (id, value) in people{
                    let uid = value["UID"] as! String
                    
                    Constants.DB.user.child(uid).observeSingleEvent(of: .value, with: {snapshot in
                        if let value = snapshot.value as? [String:Any]{
                            if let user = User.toUser(info: value){
                                count += 1
                                following.append(user)
                                
                                if following.count == count{
                                    gotFollowing(following)
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    static func getFollowers(gotFollowers: @escaping (_ result: [User]) -> Void){
        var followers = [User]()
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("followers/people").observeSingleEvent(of: .value, with: {snapshot in
            
            
            if let people = snapshot.value as? [String:[String:Any]]{
                var count = 0
                
                for (id, value) in people{
                    if let user = User.toUser(info: value){
                        count += 1
                        followers.append(user)
                        
                        if followers.count == count{
                            gotFollowers(followers)
                        }
                    }
                }
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
