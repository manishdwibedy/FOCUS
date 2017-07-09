//
//  Notification.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 7/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class NotificationUtil{
    
    static func getNotificationCount(gotNotification: @escaping (_ comments: [FocusNotification]) -> Void,
                            gotInvites: @escaping (_ comments: [FocusNotification]) -> Void,
                            gotFeed: @escaping (_ comments: [FocusNotification]) -> Void){
        var nofArray = [FocusNotification]()
        var invArray = [FocusNotification]()
        var feedArray = [FocusNotification]()
        
        NotificationUtil.getNotifications(gotEventComments: {comments in
            nofArray.append(contentsOf: comments)
            gotNotification(nofArray)
        }, gotEventLikes: {likes in
            nofArray.append(contentsOf: likes)
            gotNotification(nofArray)
        }, gotPins: {pins in
            nofArray.append(contentsOf: pins)
            gotNotification(nofArray)
        }, gotAcceptedInvites: {invites in
            nofArray.append(contentsOf: invites)
            gotNotification(nofArray)
        })
        
        FirebaseDownstream.shared.getUserNotifications(completion: {array in
            invArray = array!
            gotInvites(invArray)
        }, gotNotif: {not in
        })
        
        getFeeds(gotPins: {pins in
            feedArray.append(contentsOf: pins)
            gotFeed(nofArray)
        }, gotEvents: { events in
            feedArray.append(contentsOf: events)
            gotFeed(nofArray)
        }, gotInvitations: {invitations in
            feedArray.append(contentsOf: invitations)
            gotFeed(nofArray)
        })

    }
    
    static func getNotifications(gotEventComments: @escaping (_ comments: [FocusNotification]) -> Void, gotEventLikes: @escaping (_ comments: [FocusNotification]) -> Void, gotPins: @escaping (_ pins: [FocusNotification]) -> Void, gotAcceptedInvites: @escaping (_ comments: [FocusNotification]) -> Void){
        
        var place_count = 0
        var place_invites = [FocusNotification]()
        var event_comment_count = 0
        var event_comments = [FocusNotification]()
        var event_likes_count = 0
        var event_likes = [FocusNotification]()
        
        var pins = [FocusNotification]()
        var pinCount = 0
        var totalPins = 0
        var pinImageCount = 0
        var pinImageMap = [String:String]()
        
        let user = NotificationUser(username: AuthApi.getUserName(), uuid: AuthApi.getFirebaseUid()!, imageURL: nil)
        
        Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/send_invites").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String:Any]{
                if let places = value["place"] as? [String:Any]{
                    place_count += places.count
                    for (_, invite) in places{
                        if let invite = invite as? [String:Any]{
                            Constants.DB.user.child((invite["user"] as? String)!).observeSingleEvent(of: .value, with: { snapshot in
                                if let value = snapshot.value as? [String:Any]{
                                    let user = NotificationUser(username: value["username"] as? String, uuid: invite["user"] as? String, imageURL: value["image_string"] as? String)
                                    
                                    let place = ItemOfInterest(itemName: invite["name"] as? String, imageURL: nil, type: "place")
                                    place.id = (invite["id"] as? String)!

                                    let event_comment = FocusNotification(type: NotificationType.Going, sender: user, item: place, time: Date(timeIntervalSince1970: invite["time"] as! Double))
                                    place_invites.append(event_comment)
                                    
                                    if place_invites.count == place_count{
                                        gotAcceptedInvites(place_invites)
                                    }
                                }
                                
                            })
                            
                            
                        }
                        
                    }
                }
            }
            
            
        })
        Constants.DB.event.queryOrdered(byChild: "creator").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
            let eventInfo = snapshot.value as? [String : Any]
            
            
            if let eventInfo = eventInfo{
                for (id, event) in eventInfo{
                    if let info = event as? [String:Any]{
                        
                        let event = Event(title: (info["title"])! as! String, description: (info["description"])! as! String, fullAddress: (info["fullAddress"])! as! String, shortAddress: (info["shortAddress"])! as! String, latitude: (info["latitude"])! as! String, longitude: (info["longitude"])! as! String, date: (info["date"])! as! String, creator: (info["creator"])! as! String, id: id, category: info["interest"] as? String, privateEvent: (info["private"] as? Bool)!)
                        
                        if let comments = info["comments"] as? [String:Any]{
                            event_comment_count += comments.count
                            for (_, commentData) in comments{
                                if let commentData = commentData as? [String:Any]{
                                    if let user = commentData["fromUID"] as? String{
                                        getUserData(uid: user, gotInfo: {user in
                                            let comment = ItemOfInterest(itemName: commentData["comment"] as! String, imageURL: nil, type: "comment")
                                            comment.data = [
                                                "type": "event",
                                                "id": id,
                                                "actionType": "comment",
                                                "senderID": commentData["fromUID"] as? String,
                                                "event": event
                                            ]
                                            
                                            let event_comment = FocusNotification(type: NotificationType.Comment, sender: user, item: comment, time: Date(timeIntervalSince1970: commentData["date"] as! Double))
                                            event_comments.append(event_comment)
                                            
                                            if event_comments.count == event_comment_count{
                                                gotEventComments(event_comments)
                                            }
                                        })
                                    }
                                }
                            }
                        }
                        
                        if let likes = info["likedBy"] as? [String:Any]{
                            event_likes_count += likes.count
                            for (_, likeData) in likes{
                                if let likeData = likeData as? [String:Any]{
                                    if let user = likeData["UID"] as? String{
                                        getUserData(uid: user, gotInfo: {user in
                                            let comment = ItemOfInterest(itemName: event.title, imageURL: nil, type: "like")
                                            comment.data = [
                                                "type": "event",
                                                "id": id,
                                                "actionType": "like",
                                                "senderID": likeData["UID"] as? String,
                                                "event": event
                                            ]
                                            
                                            let event_comment = FocusNotification(type: NotificationType.Comment, sender: user, item: comment, time: Date())
                                            event_likes.append(event_comment)
                                            
                                            if event_likes.count == event_likes_count{
                                                gotEventLikes(event_likes)
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
            let pin11 = snapshot.value as? [String : Any]
            let pinID = snapshot.key
            if let pin = pin11{
                
                let pinInfo = pinData(UID: pin["fromUID"] as! String, dateTS: pin["time"] as! Double, pin: pin["pin"] as! String, location: pin["formattedAddress"] as! String, lat: pin["lat"] as! Double, lng: pin["lng"] as! Double, path: Constants.DB.pins.child(AuthApi.getFirebaseUid()! as! String), focus: pin["focus"] as? String ?? "")
                
                
                let time = Date(timeIntervalSince1970: pin["time"] as! Double)
                let address = pin["formattedAddress"] as! String
                let place = ItemOfInterest(itemName: pin["pin"] as! String, imageURL: nil, type: "pin")
                place.id = pinID
                place.data = [
                    "type": "pin",
                    "id": AuthApi.getFirebaseUid()!,
                    "actionType": "like",
                    "senderID": AuthApi.getFirebaseUid()!,
                    "pin": pinInfo
                ]
                let pinFeed = FocusNotification(type: NotificationType.Pin, sender: user, item: place, time: time)
                
                
                if let images = pin["images"] as? [String:Any]{
                    let imageURL = (images[images.keys.first!] as? [String:Any])?["imagePath"] as? String
                    let pinImage = Constants.storage.pins.child(imageURL!)
                    
                    
                    // Fetch the download URL
                    pinImage.downloadURL { url, error in
                        if let error = error {
                            // Handle any errors
                        } else {
                            pinImageMap[place.id] = url?.absoluteString
                            pinImageCount += 1
                            if pinCount == pins.count && pinImageCount == totalPins{
                                // attach images for all pins
                                
                                for pin in pins{
                                    if let image = pinImageMap[(pin.item?.id)!]{
                                        pin.item?.imageURL = image
                                    }
                                }
                                gotPins(pins)
                                print("pin done \(pinCount)")
                            }
                        }
                    }
                    
                    
                }
                else{
                    pinImageCount += 1
                    if pinCount == pins.count && pinImageCount == totalPins{
                        // attach images for all pins
                        
                        for pin in pins{
                            if let image = pinImageMap[(pin.item?.id)!]{
                                pin.item?.imageURL = image
                            }
                        }
                        gotPins(pins)
                        print("pin done \(pinCount)")
                    }
                }
                
                
                if let comments = pin["comments"] as? [String:Any]{
                    pinCount += comments.count
                    
                    for (id, data) in comments{
                        let commentData = data as? [String:Any]
                        let commentInfo = ItemOfInterest(itemName: commentData?["comment"] as? String, imageURL: place.imageURL, type: "comment")
                        commentInfo.data = [
                            "type": "pin",
                            "id": id,
                            "actionType": "comment",
                            "senderID": AuthApi.getFirebaseUid()!,
                            "pin": pinInfo
                        ]
                        
                        commentInfo.id = pinID
                        Constants.DB.user.child((commentData?["fromUID"] as? String)!).observeSingleEvent(of: .value, with: { snapshot in
                            
                            if let data = snapshot.value as? [String:Any]{
                                let user = NotificationUser(username: data["username"] as? String, uuid: data["firebaseUserId"] as? String, imageURL: nil)
                                let pinFeed = FocusNotification(type: NotificationType.Comment, sender: user, item: commentInfo, time: time)
                                
                                pins.append(pinFeed)
                                
                                if pinCount == pins.count && pinImageCount == totalPins{
                                    // attach images for all pins
                                    
                                    for pin in pins{
                                        if let image = pinImageMap[(pin.item?.id)!]{
                                            pin.item?.imageURL = image
                                        }
                                    }
                                    gotPins(pins)
                                    print("pin done \(pinCount)")
                                }
                            }
                            
                        })
                        
                    }
                    
                }
                
                if let likes = pin["like"] as? [String:Any]{
                    let likeData = likes["likedBy"] as? [String:Any]
                    
                    if let likeCount = likes["num"] as? Int{
                        pinCount += likeCount
                    }
                    
                    for (id, data) in likeData!{
                        if let likeData = data as? [String:Any]{
                            Constants.DB.user.child((likeData["UID"] as? String)!).observeSingleEvent(of: .value, with: { snapshot in
                                
                                let data = snapshot.value as? [String:Any]
                                let user = NotificationUser(username: data?["username"] as? String, uuid: data?["firebaseUserId"] as? String, imageURL: nil)
                                let pinFeed = FocusNotification(type: NotificationType.Like, sender: user, item: place, time: time)
                                pins.append(pinFeed)
                                
                                if pinCount == pins.count && pinImageCount == totalPins{
                                    // attach images for all pins
                                    
                                    for pin in pins{
                                        if let image = pinImageMap[(pin.item?.id)!]{
                                            pin.item?.imageURL = image
                                        }
                                    }
                                    gotPins(pins)
                                    print("pin done \(pinCount)")
                                }
                            })
                        }
                        
                    }
                }
            }
            
            totalPins += 1
            if pinCount == pins.count{
                gotPins(pins)
                print("pin done \(pinCount)")
            }
        })
        
    }
    
    

}
