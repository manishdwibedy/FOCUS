//
//  FollowPeople.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 6/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

func followUser(uid: String){
    Constants.DB.user.child("users").child(AuthApi.getFirebaseUid()!).child("following/people").childByAutoId().updateChildValues(["UID": uid])

    Constants.DB.user.child(uid).child("followers/people").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
    
}

func unFollowUser(uid: String){
    Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").queryOrdered(byChild: "UID").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? [String:Any]

        for (id, _) in value!{
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people/\(id)").removeValue()
        }

    })
    Constants.DB.user.child(uid).child("followers").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? [String:Any]
        
        for (id, _) in value!{
            Constants.DB.user.child(uid).child("followers/people/\(id)").removeValue()

        }
        
    })
}
