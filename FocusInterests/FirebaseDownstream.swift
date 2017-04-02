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
    
    let ref = FIRDatabase.database().reference()
    
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
    
    
    
}
