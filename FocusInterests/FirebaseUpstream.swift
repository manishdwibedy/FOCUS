//
//  FirebaseUpstream.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/4/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseUpstream {
    
    public static let sharedInstance = FirebaseUpstream()
    
    fileprivate init() {}
    
    var ref = FIRDatabase.database().reference()
    
    func addToUsers(focusUser: FocusUser) {

        var dict = [String : AnyObject]()
        
        if let fireId = focusUser.firebaseId {
            dict["firebaseUserId"] = fireId as AnyObject
        }
        if let uName = focusUser.userName {
            dict["username"] = uName as AnyObject
        } else {
            dict["username"] = "" as AnyObject
        }
        if let imString = focusUser.imageString {
            dict["image_string"] = imString as AnyObject
        } else {
            dict["image_string"] = "" as AnyObject
        }
        if let clLoc = focusUser.currentLocation {
            dict["current_location"] = clLoc as AnyObject
        } else {
            dict["current_location"] = "" as AnyObject
        }

        let pathString = "users/\(focusUser.firebaseId!)"
        ref.child(pathString).setValue(dict)
    }
    
    func addInterestWithUser(interest: Interest, currentUserId: String) {
        var dict = [String : AnyObject]()
        
        let id = ref.childByAutoId().key
        
    }
    
    func uploadProfileImage(image: UIImage, user: FocusUser) {
        
    }
}
