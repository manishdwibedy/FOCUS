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
        let id = ref.childByAutoId().key
        var dict = [String : AnyObject]()
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
        
        // create func that takes array of Interests and returns array of comma-separated strings
        if let interests = focusUser.interests {
            dict["interests"] = "There'll be an array of interest names here" as AnyObject
        } else {
            dict["interests"] = "" as AnyObject
        }
        let pathString = "users/\(id)"
        ref.child(pathString).setValue(dict)
    }
}
