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
    
    func getUserNotifications(completion: @escaping ([FocusNotification]?) -> Void, gotNotif: @escaping (_ events: [FocusNotification]) -> Void) {
        let userId = AuthApi.getFirebaseUid()
        
        print("getUserNotification")
        
        if let id = userId {
            ref.child("users").child(id).child("invitations").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    var returnableNotif = [FocusNotification]()
                    var valueCount = 0
                    var totalCount = 0
                    for (key, v) in value {
                        let inValue = value[key] as! NSDictionary
                        totalCount = totalCount + inValue.count
                    }
                    for (key, v) in value {
                        let inValue = value[key] as! NSDictionary
                        for (inKey, _) in inValue
                        {
                            self.ref.child("users").child((inValue[inKey] as! NSDictionary)["fromUID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                                if let valueUID = snapshot.value as? NSDictionary {
                                    var dbKey = ""
                                    
                                    if key as! String == "event"{
                                        
                                        dbKey = "events"
                                        self.ref.child(dbKey).child((inValue[inKey] as! NSDictionary)["ID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                                            if let valueInviteID = snapshot.value as? NSDictionary {
                                                let itemName = valueInviteID["title"] as! String
                                                let item = ItemOfInterest(itemName: itemName, imageURL: "", type: "event")
                                                item.type = "event"
                                                item.id = (inValue[inKey] as! NSDictionary)["ID"] as! String
                                                item.data = [
                                                    "invite": inValue[inKey] as? [String:Any]
                                                ]
                                                let notification = FocusNotification(type: NotificationType.Invite, sender: NotificationUser(username: valueUID["username"] as? String, uuid: (inValue[inKey] as! NSDictionary)["fromUID"] as? String, imageURL: ""), item: item, time: NSDate(timeIntervalSince1970: ((inValue[inKey] as! NSDictionary)["time"] as? Double)!) as Date)
                                                returnableNotif.append(notification)
                                                
                                            }
                                            valueCount = valueCount + 1
                                            if valueCount == totalCount
                                            {
                                               DispatchQueue.main.async(execute: {
                                                    completion(returnableNotif)
                                                })
                                            }
                                        })
                                    }else if key as! String == "place"{
                                        print(inValue[inKey])
                                        print(valueUID)
                                        print("________")
                                        dbKey = "places"
                                        let place_invite = inValue[inKey] as! NSDictionary
                                        let item = ItemOfInterest(itemName: (place_invite["name"] as? String), imageURL: "", type: "place")
                                        item.type = "place"
                                        item.id = (inValue[inKey] as! NSDictionary)["ID"] as! String
                                        item.data = [
                                            "inviteTime": place_invite["inviteTime"] as? String,
                                            "invite": inValue[inKey] as? [String:Any]
                                        ]
                                        let notification = FocusNotification(type: NotificationType.Invite, sender: NotificationUser(username: valueUID["username"] as? String, uuid: place_invite["fromUID"] as? String, imageURL: ""), item: item, time: NSDate(timeIntervalSince1970: (place_invite["time"] as? Double)!) as Date)
                                        returnableNotif.append(notification)
                                        
                                    
                                    valueCount = valueCount + 1
                                    if valueCount == totalCount
                                    {
                                        
                                        DispatchQueue.main.async(execute: {
                                            completion(returnableNotif)
                                        })
                                    }
                                    }
                                
                                    
                                    
                                }
                                
                                
                            })
                        }
                    }
                }
                
                
                
            })
            
            var returnNotif = [FocusNotification]()
            ref.child("users").child(id).child("notifications").observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    for (key,_) in value{
                        let item = ItemOfInterest(itemName: "", imageURL: "", type: "")
                        item.data = value[key] as! NSDictionary
                        let notification = FocusNotification(type: NotificationType.Invite, sender: NotificationUser(username: "", uuid: item.data["senderID"] as? String, imageURL: ""), item: item, time: Date(timeIntervalSince1970: TimeInterval((value[key] as! NSDictionary)["time"] as! Double)))
                    
                        returnNotif.append(notification)
                   }
                    gotNotif(returnNotif)
                }
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
