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
    
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    let storage_UserProfile = Storage.storage().reference(withPath: "user_profile/")
    
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
        if let description = focusUser.description {
            dict["description"] = description as AnyObject
        } else {
            dict["description"] = "" as AnyObject
        }
        

        let pathString = "users/\(focusUser.firebaseId!)"
        ref.child(pathString).setValue(dict)
    }
    
    func addToUsers_(focusUser: FocusUser) {
        
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
        if let description = focusUser.description {
            dict["description"] = description as AnyObject
        } else {
            dict["description"] = "" as AnyObject
        }
        if let description = focusUser.description {
            dict["description"] = description as AnyObject
        } else {
            dict["description"] = "" as AnyObject
        }
        
        // ADDED FROM VIEW
        if let name = focusUser.name {
            dict["name"] = name as AnyObject
        } else {
            dict["name"] = "" as AnyObject
        }
        if let website = focusUser.website {
            dict["website"] = website as AnyObject
        } else {
            dict["website"] = "" as AnyObject
        }
        if let email = focusUser.email {
            dict["email"] = email as AnyObject
        } else {
            dict["email"] = "" as AnyObject
        }
        if let gender = focusUser.gender {
            dict["gender"] = gender as AnyObject
        } else {
            dict["gender"] = "" as AnyObject
        }
        if let phone = focusUser.phone {
            dict["phone"] = phone as AnyObject
        } else {
            dict["phone"] = "" as AnyObject
        }
        
        
        ref.child("users").child(focusUser.firebaseId!).updateChildValues(dict)
    }
    
    func addInterestWithUser(interest: Interest, currentUserId: String) {
        let dict = ["\(interest.name!)-\(interest.category!.rawValue)" : true]
        let userDict = [AuthApi.getFirebaseUid()! : true]
        let pathUser = "users/\(currentUserId)/interests/\(interest.name!)-\(interest.category!)"
        let pathInterest = "interests/\(interest.name!)-\(interest.category!)"
        
        ref.child(pathUser).setValue(dict)
        ref.child(pathInterest).setValue(userDict)
    }
    
    func uploadProfileImage(image: UIImage, completion: @escaping (String) -> Void) {
        
        if let uid = AuthApi.getFirebaseUid() {
            let storeChild = storageRef.child("profileImage\(uid)")
            let shrunkenImage = image.resized(withPercentage: 0.2)
            if let uploadData = UIImagePNGRepresentation(shrunkenImage!) {
                storeChild.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
                    
                    if let url = metaData?.downloadURL() {
                        DispatchQueue.main.async(execute: {
                            completion(String(describing: url))
                        })
                    }
                    
                })
            }

        }
    }
    
    func uploadProfileImage_(image: UIImage, completion: @escaping (String) -> Void) {
        
        if let uid = AuthApi.getFirebaseUid() {
            let storeChild = storage_UserProfile.child("\(uid).jpg")
            let shrunkenImage = image.resized(withPercentage: 0.2)

            if let uploadData = UIImagePNGRepresentation(shrunkenImage!) {
                storeChild.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "Error")
                        return
                    }
                    
                    if let url = metaData?.downloadURL() {
                        DispatchQueue.main.async(execute: {
                            completion(String(describing: url))
                        })
                    }
                    
                })
            }
            
        }
    }
}
