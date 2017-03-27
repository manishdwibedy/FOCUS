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
