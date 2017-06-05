//
//  FirebaseDownstream.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/4/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import Firebase

class FirebaseDownstream {
    
    public static let shared = FirebaseDownstream()
    
    let ref = Database.database().reference()
    
    var giantInterestMap = [
        InterestCategory.Art.rawValue : [Constants.interests.modernArt, Constants.interests.murals, Constants.interests.museums],
        InterestCategory.Food.rawValue : [Constants.interests.french, Constants.interests.italian, Constants.interests.mexican],
        InterestCategory.Nightlife.rawValue : [Constants.interests.bars, Constants.interests.clubs, Constants.interests.events],
        InterestCategory.Shopping.rawValue : [Constants.interests.clothing, Constants.interests.electronics, Constants.interests.furniture],
        InterestCategory.Sports.rawValue : [Constants.interests.basketball, Constants.interests.bike, Constants.interests.football, Constants.interests.soccer]
    ]
    
    private init (){}
    
    func getCurrentUser(completion: @escaping (NSDictionary?) -> Void) {
        let userID = AuthApi.getFirebaseUid()
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            
            DispatchQueue.main.async(execute: { 
                completion(value)
            })
        })
    }
    
    func getUserNotifications(completion: @escaping ([FocusNotification]?) -> Void) {
        let userId = AuthApi.getFirebaseUid()
        
        print("getUserNotification")

        if let id = userId {
            ref.child("users").child(id).child("invitations").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    var returnableNotif = [FocusNotification]()
                    for (k, v) in value {
                        print(k)
                        print(v)
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    completion(nil)
                })
                
            })
        }
        
    }
    
    func getCurrentUserInterests(completion: @escaping ([Interest]?) -> Void) {
        let userId = AuthApi.getFirebaseUid()
        
        if let id = userId{
            ref.child("users").child(id).child("interests").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    var returnableInterests = [Interest]()
                    for (k,_) in value {
                        let key1 = k as! String
                        let kl = key1.lowercased()
                        let strArr = kl.components(separatedBy: "-")
                        if let mapArr: [Interest] = self.giantInterestMap[strArr[1]] {
                            for interest in mapArr {
                                if interest.name! == strArr[0] {
                                    returnableInterests.append(interest)
                                }
                            }
                            
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        completion(returnableInterests)
                    })
                }
                
            })
        }
        
    }
    
    func isUserEmailVerified(completion: @escaping (Bool) -> Void) {
        guard let email = Auth.auth().currentUser?.email, let password = AuthApi.getPassword() else { return }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription ?? String())
            } else {
                completion(user!.isEmailVerified)
            }
        })
    }
    
}
