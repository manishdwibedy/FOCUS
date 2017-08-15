//
//  FollowPeople.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 6/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import Crashlytics

class Follow{
    static func followUser(uid: String){
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").queryOrdered(byChild: "UID").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:Any]
            
            if value == nil{
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").childByAutoId().updateChildValues([
                        "UID": uid,
                        "time": Date().timeIntervalSince1970
                    ])
                
                
                sendNotification(to: uid, title: "New Follower", body: "\(AuthApi.getUserName()!) started following you", actionType: "", type: "", item_id: "", item_name: "")
                
            }
        })
        
        
        
        Constants.DB.user.child(uid).child("followers").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:Any]
            
            if value == nil{
                Constants.DB.user.child(uid).child("followers/people").childByAutoId().updateChildValues([
                    "UID": AuthApi.getFirebaseUid()!,
                    "time": Date().timeIntervalSince1970
                    ])
            }
        })
        
        Constants.DB.user.child(uid).observeSingleEvent(of: .value, with: {snapshot in
        
            if let data = snapshot.value as? [String:Any]{
                if let username = data["username"] as? String{
                    Answers.logCustomEvent(withName: "Follow",
                                           customAttributes: [
                                            "follower": AuthApi.getFirebaseUid()!,
                                            "following": username,
                                            "type": "user"
                                            
                        ])
                    
                }
            }
        })
        
    }
    
    static func unFollowUser(uid: String){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").queryOrdered(byChild: "UID").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:Any]
            
            for (id, _) in value!{
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people/\(id)").removeValue()
            }
            
        })
        Constants.DB.user.child(uid).child("followers").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:Any]
            
            if let value = value{
                for (id, _) in value{
                    Constants.DB.user.child(uid).child("followers/people/\(id)").removeValue()
                    
                }
            }
            
            
        })
    }
    
    static func followPlace(id: String){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").childByAutoId().updateChildValues(["placeID": id])
        
        
        Constants.DB.following_place.child(id).child("followers/places").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: {snapshot in
            
            if let data = snapshot.value as? [String:Any]{
                if let username = data["username"] as? String{
                    
                    getYelpByID(ID: id, completion: {place in
                        Answers.logCustomEvent(withName: "Follow",
                                               customAttributes: [
                                                "follower": AuthApi.getFirebaseUid()!,
                                                "following": place.name,
                                                "type": "place"
                                                
                            ])
                        
                    })
                    
                }
            }
        })
        
    }
    
    static func unFollowPlace(id: String){
        if id.characters.count > 0{
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").queryOrdered(byChild: "placeID").queryEqual(toValue: id).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                
                if let value = value{
                    for (id, _) in value{
                        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places/\(id)").removeValue()
                    }
                    
                }
                
            })
            
            Constants.DB.following_place.child(id).child("followers").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    for (key,_) in value!
                    {
                        Constants.DB.following_place.child(id).child("followers").child(key as! String).removeValue()
                    }
                    
                    
                    
                }
            })   
        }
        
    }
}
