   //
//  GlobalFunctions.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation
import Crashlytics
import FirebaseStorage
import SCLAlertView
import FirebaseAuth
import DataCache

func featuresToString(features: [Feature]) -> String {
    var strArray = [String]()
    for f in features {
        strArray.append(f.featureName!)
    }
    let joinedStr = strArray.joined(separator: ", ")
    return joinedStr
}

func showLoginError(_ error: Error){
    Crashlytics.sharedInstance().recordError(error)

    if let errCode = AuthErrorCode(rawValue: error._code) {
        switch errCode {
        case .accountExistsWithDifferentCredential:
            SCLAlertView().showCustom("Oops!", subTitle: "You've already signed in with a different account.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
        case .invalidEmail:
            SCLAlertView().showCustom("Oops!", subTitle: "Choose a valid email.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
        case .emailAlreadyInUse:
            SCLAlertView().showCustom("Oops!", subTitle: "Email already in use.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
        case .weakPassword:
            SCLAlertView().showCustom("Oops!", subTitle: "Password must be min. 8 characters.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
        case .tooManyRequests:
            SCLAlertView().showCustom("Oops!", subTitle: "Wait a moment and try again.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
        case .userTokenExpired:
            SCLAlertView().showCustom("Oops!", subTitle: "User token expired. Please login in again.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
        default:
            SCLAlertView().showCustom("Oops!", subTitle: "Session Expired. Please Login again.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
        }
    }
}
   
func showError(message: String){
    SCLAlertView().showCustom("Oops!", subTitle: message, color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
}
   
func getYelpToken(completion: @escaping (_ result: String) -> Void){
    let url = "https://api.yelp.com/oauth2/token"
    let parameters: [String: String] = [
        "client_id" : "vFAIR9-9TE52_DCWXHrXew",
        "client_secret" : "Bb3UszmDi1zoFMsWqhnodGrOhK3s8SBKaV6SK2gdn3sE3txhVOxSjGHdcFsitovD",
        "grant_type": "client_credentials"
        
        
    ]
    
    let headers: HTTPHeaders = [
        "content-type": "application/x-www-form-urlencoded",
        "cache-contro": "no-cache"
    ]
    
    Alamofire.request(url, method: .post, parameters:parameters, headers: headers).responseJSON { response in
        let json = JSON(data: response.data!)
        let token = json["access_token"].stringValue
        
        AuthApi.set(yelpAccessToken: token)
        
        completion(token)
        
    }
}

let days = ["Sun", "Mon", "Tue", "Wed", "Thr", "Fri", "Sat"]

func getOpenHours(_ hours: [Hours]) -> [String]{
    var result = [String]()
    
    var last_day_start = hours[0].day
    var last_day_end = hours[0].day
    var last_start = hours[0].start
    var last_end = hours[0].end
    
    
    for (_, hour) in hours.dropFirst().enumerated(){
        
        // last day matches to the current day
        if hour.start == last_start && hour.end == last_end && hour.day == last_day_end + 1{
            last_day_end = hour.day
        }
            //last day doesn't match to the current day
        else{
            // if only day was there a
            if last_day_end == last_day_start{
                result.append("\(days[last_day_start]) \(convert24HourTo12Hour(last_start)) - \(convert24HourTo12Hour(last_end))")
            }
            else{
                result.append("\(days[last_day_start]) - \(days[last_day_end]) \(convert24HourTo12Hour(last_start)) - \(convert24HourTo12Hour(last_end))")
            }
            last_day_start = hour.day
            last_day_end = hour.day
            last_start = hour.start
            last_end = hour.end
        }
    }
    return result
}

func convert24HourTo12Hour(_ time: String) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HHmm"
    let date12 = dateFormatter.date(from: time)!
    
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter.string(from: date12)
    
}

func changeTimeZone(of date: Date, from sourceTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> Date{
    let str: String = date.description(with: nil)
    let fromDF: DateFormatter = DateFormatter()
    fromDF.timeZone = TimeZone(abbreviation: "GMT")
    fromDF.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let gmtDate: Date = fromDF.date(from: str)!
    let date_string = fromDF.string(from: gmtDate)
    print(gmtDate)
    
    let toDF: DateFormatter = DateFormatter()
    toDF.timeZone = TimeZone(abbreviation: "PDT")
    toDF.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let estDate: Date = toDF.date(from: date_string)!
    return(estDate)
}

func getEvents(around location: CLLocation, completion: @escaping (_ result: [Event]) -> Void){
    let url = "https://www.eventbriteapi.com/v3/events/search/"

    _ = 0
    var eventList = [Event]()
    
    let parameters: [String: String] = [
        "categories": getEventBriteCategories(),
        "token" : AuthApi.getEventBriteToken()!,
        "sort_by": "distance",
        "location.latitude": String(location.coordinate.latitude),
        "location.longitude" : String(location.coordinate.longitude),
        "location.within": "10mi"
    ]
    
    Alamofire.request(url, method: .get, parameters:parameters, headers: nil).responseJSON { response in
        let json = JSON(data: response.data!)
        let events = json["events"]
        
        if let array = events.arrayObject{
            for (_, eventJson) in events {
                
                let category_id = eventJson["category_id"].stringValue

                let event = Event(title: eventJson["name"]["text"].stringValue, description: eventJson["description"]["text"].stringValue, fullAddress: nil, shortAddress: nil, latitude: nil, longitude: nil, date: eventJson["start"]["local"].stringValue, creator: "", category: getInterest(eventBriteId: category_id), privateEvent: (eventJson["private"] as? Bool)!)
                
                event.setEndTime(endTime: eventJson["end"]["local"].stringValue)
                event.setImageURL(url: eventJson["logo"]["url"].stringValue
                )
                getEventLocation(eventJson["venue_id"].stringValue, completion: { location in
                    event.fullAddress = location?.address
                    event.shortAddress = location?.address
                    event.latitude = location?.latitude
                    event.longitude = location?.longitude
                    
                    eventList.append(event)
                    
                    if eventList.count == array.count{
                        completion(eventList)
                    }
                    
                })
                
                
            }
        }
    }
}

func getEventLocation(_ id: String, completion: @escaping (_ result: EventLocation?) -> Void){

    let url = "https://www.eventbriteapi.com/v3/venues/\(id)"
    let parameters: [String: String] = [
        "token" : AuthApi.getEventBriteToken()!,
    ]
    
    Alamofire.request(url, method: .get, parameters:parameters, headers: nil).responseJSON { response in
        let json = JSON(data: response.data!)
        let address = json["address"].dictionaryValue
        
        if let address_string = address["localized_address_display"]?.stringValue{
            let location = EventLocation(address: address_string, latitude: (address["latitude"]?.stringValue)!, longitude: (address["longitude"]?.stringValue)!)
            
            completion(location)
        }
        
    }
    
}

func isValidEmail(text:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: text)
}

func getDistance(fromLocation: CLLocation, toLocation: CLLocation, addBracket: Bool = false, precision: Int = 1) -> String{
    let distanceInMeters = fromLocation.distance(from: toLocation)
    let distance = distanceInMeters/1609.344
    
    if addBracket{
        if precision == 0{
            return "\(Int(distance)) mi"
        }
        else{
            return "(\(distance.roundTo(places: precision)) mi)"
        }
        
    }
    else{
        if precision == 0{
            return "\(Int(distance)) mi"
        }
        else{
            return "\(distance.roundTo(places: precision)) mi"   
        }
    }
    
}

func uploadImage(image:UIImage, path: StorageReference)
{
    
    let localFile = UIImageJPEGRepresentation(image, 0.5)
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    _ = AuthApi.getFirebaseUid()
    let uploadTask = path.putData(localFile!, metadata: metadata, completion: {metadata, error in
        if error == nil{
            AuthApi.set(userImage: metadata?.downloadURLs?[0].absoluteString)
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues([
                "image_string": metadata?.downloadURLs?[0].absoluteString
                ])
        }
    })
    
    uploadTask.observe(.progress) { snapshot in
        if let progress = snapshot.progress {
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            print(percentComplete)
        }
    }
    
    uploadTask.observe(.success) { snapshot in
        
    }
    
    uploadTask.observe(.failure) { snapshot in
        print(snapshot.error!)
    }
    
}

func sendNotification(to id: String, title: String, body: String, actionType: String, type: String, item_id: String, item_name: String){
    let url = "http://notifications-dev2.us-west-2.elasticbeanstalk.com/sendMessage"
    
    let time = NSDate().timeIntervalSince1970
    
    Constants.DB.user.child("\(id)/notifications").childByAutoId().setValue([
        "title": title,
        "body": body,
        "time": Double(time),
        "actionType": actionType,
        "type": type,
        "id": item_id,
        "name": item_name,
        "senderID": AuthApi.getFirebaseUid() ?? ""
        ])
    
    Constants.DB.user.child(id).observeSingleEvent(of: .value, with: { snapshot in
        
        
        let user = snapshot.value as? [String : Any] ?? [:]
        
        let token = user["token"] as? String
        
        let parameters = [
            "to":token ?? "",
            "title": title,
            "body": body
            
            ] as [String : Any]
        
        
        Alamofire.request(url, method: .get, parameters:parameters, headers: nil).response { response in
            print(response)
        }
        
    })
}

func getAllActivity(gotPins: @escaping (_ pins: [FocusNotification]) -> Void, gotEvents: @escaping (_ events: [FocusNotification]) -> Void, gotInvitations: @escaping (_ invitations: [FocusNotification]) -> Void){
    let userID = AuthApi.getFirebaseUid()
    var pins = [FocusNotification]()
    var events = [FocusNotification]()
    var invitations_event = [FocusNotification]()
    
    var pinCount = 0
    var followerCount = 0
    var invitationCount = 0
    var eventCount = 0
    var totalInvitation = 0
    
    var pinImageMap = [String:String]()
    var pinImageCount = 0
    var totalPins = 0
    Constants.DB.user.observeSingleEvent(of: .value, with: { snapshot in
        if let users = snapshot.value as? [String : [String:Any]]{
            for (_, userData) in users{
                if let user = User.toUser(info: userData){
                    let UID = user.uuid
                    
                    let user = NotificationUser(username: user.username, uuid: UID, imageURL: nil)
                    Constants.DB.pins.child(UID!).observeSingleEvent(of: .value, with: { snapshot in
                        let pin11 = snapshot.value as? [String : Any]
                        let pinID = snapshot.key
                        if let pin = pin11{
                            let time = Date(timeIntervalSince1970: pin["time"] as! Double)
                            _ = pin["formattedAddress"] as! String
                            let place = ItemOfInterest(itemName: pin["pin"] as? String, imageURL: nil, type: "pin")
                            
                            pinCount += 1
                            totalPins += 1
                            
                            place.data = [
                                "pin": pin,
                                "key": pinID
                            ]
                            place.id = pinID
                            
                            let pinFeed = FocusNotification(type: NotificationType.Pin, sender: user, item: place, time: time)
                            
                            
                            pins.append(pinFeed)
                            if let images = pin["images"] as? [String:Any]{
                                let imageURL = (images[images.keys.first!] as? [String:Any])?["imagePath"] as? String
                                let pinImage = Constants.storage.pins.child(imageURL!)
                                
                                
                                // Fetch the download URL
                                pinImage.downloadURL { url, error in
                                    if error != nil {
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
                                
                                for (_, data) in comments{
                                    let commentData = data as? [String:Any]
                                    let commentInfo = ItemOfInterest(itemName: commentData?["comment"] as? String, imageURL: place.imageURL, type: "comment")
                                    commentInfo.id = pinID
                                    Constants.DB.user.child((commentData?["fromUID"] as? String)!).observeSingleEvent(of: .value, with: { snapshot in
                                        
                                        if let data = snapshot.value as? [String:Any]{
                                            let user = NotificationUser(username: data["username"] as? String, uuid: data["firebaseUserId"] as? String, imageURL: nil)
                                            let pinFeed = FocusNotification(type: NotificationType.Comment, sender: user, item: commentInfo, time: time)
                                            commentInfo.data = [
                                                "pin": pin,
                                                "key": pinID
                                            ]
                                            
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
                                if let likeData = likes["likedBy"] as? [String:Any]{
                                    if let likeCount = likes["num"] as? Int{
                                        pinCount += likeCount
                                    }
                                    
                                    for (_, data) in likeData{
                                        if let likeData = data as? [String:Any]{
                                            Constants.DB.user.child((likeData["UID"] as? String)!).observeSingleEvent(of: .value, with: { snapshot in
                                                
                                                let data = snapshot.value as? [String:Any]
                                                let user = NotificationUser(username: data?["username"] as? String, uuid: data?["firebaseUserId"] as? String, imageURL: nil)
                                                let pinFeed = FocusNotification(type: NotificationType.Like, sender: user, item: place, time: time)
                                                place.data = [
                                                    "pin": pin,
                                                    "key": pinID
                                                ]
                                                
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
                        }
                        
                    })
                    
                    
                    Constants.DB.event.queryOrdered(byChild: "creator").queryEqual(toValue: UID).observeSingleEvent(of: .value, with: { snapshot in
                        let eventInfo = snapshot.value as? [String : Any]
                        
                        if let eventInfo = eventInfo{
                            for (id, event) in eventInfo{
                                if let info = event as? [String:Any]{
                                    let event = Event.toEvent(info: info)
                                    event?.id = id
                                    //                        MMM dd, hh:mm
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "MMM d, h:mm a"
                                    
                                    let time = dateFormatter.date(from: (event?.date!)!)
                                    
                                    let gregorianCalendar = Calendar(identifier: .gregorian)
                                    var components = gregorianCalendar.dateComponents([.year, .month, .day], from: time!)
                                    
                                    components.year = 2017
                                    let date = gregorianCalendar.date(from: components)!
                                    
                                    
                                    
                                    let address = event?.shortAddress
                                    let place = ItemOfInterest(itemName: address, imageURL: nil, type: "event")
                                    place.id = snapshot.key
                                    place.data = [
                                        "event": event
                                    ]
                                    
                                    if let time = time{
                                        let eventFeed = FocusNotification(type: NotificationType.Created, sender: user, item: place, time: date)
                                        events.append(eventFeed)
                                        
                                    }
                                }
                                
                            }
                        }
                        eventCount += 1
                        if eventCount == followerCount{
                            gotEvents(events)
                            print("event done \(eventCount)")
                            print(events.count)
                        }
                    })
                    
                    Constants.DB.user.child(UID!).observeSingleEvent(of: .value, with: { snapshot in
                        let data = snapshot.value as? [String : Any]
                        
                        if let invitations = data?["invitations"] as? [String:Any]{
                            
                            if let event = invitations["event"] as? [String:[String:Any]]{
                                for (_,invite) in event{
                                    if let status = invite["status"] as? String{
                                        if status == "accepted"{
                                            totalInvitation += 1
                                            let id = invite["ID"]  as! String
                                            
                                            
                                            Constants.DB.event.child(id).observeSingleEvent(of: .value, with: { snapshot in
                                                let info = snapshot.value as? [String : Any]
                                                
                                                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as? String, longitude: (info?["longitude"])! as? String, date: (info?["date"])! as! String, creator: (info?["creator"])! as? String, id: id, category: info?["interest"] as? String, privateEvent: (info?["private"] as? Bool)!)
                                                
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "MMM d, h:mm a"
                                                
                                                let time = dateFormatter.date(from: event.date!)
                                                let address = event.shortAddress
                                                let place = ItemOfInterest(itemName: address, imageURL: nil, type: "event")
                                                place.id = snapshot.key
                                                place.data = [
                                                    "event": event
                                                ]
                                                
                                                let eventDF = DateFormatter()
                                                eventDF.dateFormat = "MMM d, h:mm a"

                                                if let time = eventDF.date(from: event.date!){
                                                    let gregorianCalendar = Calendar(identifier: .gregorian)
                                                    var components = gregorianCalendar.dateComponents([.year, .month, .day], from: time)
                                                    components.year = 2017
                                                    
                                                    let eventFeed = FocusNotification(type: NotificationType.Going, sender: user, item: place, time: gregorianCalendar.date(from: components)!)
                                                    invitations_event.append(eventFeed)
                                                    
                                                }
                                                invitationCount += 1
                                                if invitationCount == totalInvitation{
                                                    gotInvitations(invitations_event)
                                                    print("invitation done \(invitationCount)")
                                                }
                                            })
                                        }
                                    }
                                    
                                }
                            }
                        }
                    })
                }
                
            }
        }
    })
}
   
func getFeeds(gotPins: @escaping (_ pins: [FocusNotification]) -> Void, gotEvents: @escaping (_ events: [FocusNotification]) -> Void, gotInvitations: @escaping (_ invitations: [FocusNotification]) -> Void){
    
    let userID = AuthApi.getFirebaseUid()
    var pins = [FocusNotification]()
    var events = [FocusNotification]()
    var invitations_event = [FocusNotification]()
    
    var pinCount = 0
    var followerCount = 0
    var invitationCount = 0
    var eventCount = 0
    var totalInvitation = 0
    
    var pinImageMap = [String:String]()
    var pinImageCount = 0
    var totalPins = 0
    Constants.DB.user.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
        
        
        let user = snapshot.value as? [String : Any]
        
        let followers = user?["following"] as? [String : Any]
        let people = followers?["people"] as? [String : [String: Any]] ?? [:]
        
        followerCount = people.count
        for (_, follower) in people{
            let followerID = follower["UID"] as! String
//            let username = follower["username"] as! String
//            let imageURL = follower["imageURL"] as? String
//            let followerID = "0wOmLiHD6jWg33qyz0DxJ0BAEDy1"
            
            
            let followerUser = NotificationUser(username: "username", uuid: followerID, imageURL: nil)
            Constants.DB.pins.child(followerID).observeSingleEvent(of: .value, with: { snapshot in
                let pin11 = snapshot.value as? [String : Any]
                let pinID = snapshot.key
                if let pin = pin11{
                    let time = Date(timeIntervalSince1970: pin["time"] as! Double)
                    _ = pin["formattedAddress"] as! String
                    let place = ItemOfInterest(itemName: pin["pin"] as? String, imageURL: nil, type: "pin")
                    
                    pinCount += 1
                    totalPins += 1
                    
                    place.data = [
                        "pin": pin,
                        "key": pinID
                    ]
                    place.id = pinID
                    
                    let pinFeed = FocusNotification(type: NotificationType.Pin, sender: followerUser, item: place, time: time)
                    
                    
                    pins.append(pinFeed)
                    if let images = pin["images"] as? [String:Any]{
                        let imageURL = (images[images.keys.first!] as? [String:Any])?["imagePath"] as? String
                        let pinImage = Constants.storage.pins.child(imageURL!)
                        
                        
                        // Fetch the download URL
                        pinImage.downloadURL { url, error in
                            if error != nil {
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
                        
                        for (_, data) in comments{
                            let commentData = data as? [String:Any]
                            let commentInfo = ItemOfInterest(itemName: commentData?["comment"] as? String, imageURL: place.imageURL, type: "comment")
                            commentInfo.id = pinID
                            Constants.DB.user.child((commentData?["fromUID"] as? String)!).observeSingleEvent(of: .value, with: { snapshot in
                                
                                if let data = snapshot.value as? [String:Any]{
                                    let user = NotificationUser(username: data["username"] as? String, uuid: data["firebaseUserId"] as? String, imageURL: nil)
                                    let pinFeed = FocusNotification(type: NotificationType.Comment, sender: user, item: commentInfo, time: time)
                                    commentInfo.data = [
                                        "pin": pin,
                                        "key": pinID
                                    ]
                                    
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
                        if let likeData = likes["likedBy"] as? [String:Any]{
                            if let likeCount = likes["num"] as? Int{
                                pinCount += likeCount
                            }
                            
                            for (_, data) in likeData{
                                if let likeData = data as? [String:Any]{
                                    Constants.DB.user.child((likeData["UID"] as? String)!).observeSingleEvent(of: .value, with: { snapshot in
                                        
                                        let data = snapshot.value as? [String:Any]
                                        let user = NotificationUser(username: data?["username"] as? String, uuid: data?["firebaseUserId"] as? String, imageURL: nil)
                                        let pinFeed = FocusNotification(type: NotificationType.Like, sender: user, item: place, time: time)
                                        place.data = [
                                            "pin": pin,
                                            "key": pinID
                                        ]
                                        
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
                }
                
//                
//                
//                if pinCount == pins.count && pinImageCount == totalPins{
//                    gotPins(pins)
//                    print("pin done \(pinCount)")
//                }
            })
            
            
            Constants.DB.event.queryOrdered(byChild: "creator").queryEqual(toValue: followerID).observeSingleEvent(of: .value, with: { snapshot in
                let eventInfo = snapshot.value as? [String : Any]
                
                if let eventInfo = eventInfo{
                    for (id, event) in eventInfo{
                        if let info = event as? [String:Any]{
                            let event = Event.toEvent(info: info)
                            event?.id = id
                            //                        MMM dd, hh:mm
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM d, h:mm a"
                            
                            let time = dateFormatter.date(from: (event?.date!)!)
                            
                            let gregorianCalendar = Calendar(identifier: .gregorian)
                            var components = gregorianCalendar.dateComponents([.year, .month, .day], from: time!)
                            
                            components.year = 2017
                            let date = gregorianCalendar.date(from: components)!


                            
                            let address = event?.shortAddress
                            let place = ItemOfInterest(itemName: address, imageURL: nil, type: "event")
                            place.id = snapshot.key
                            place.data = [
                                "event": event
                            ]
                            
                            if let time = time{
                                let eventFeed = FocusNotification(type: NotificationType.Created, sender: followerUser, item: place, time: date)
                                events.append(eventFeed)
                                
                            }
                        }
                    
                    }
                }
                eventCount += 1
                if eventCount == followerCount{
                    gotEvents(events)
                    print("event done \(eventCount)")
                    print(events.count)
                }
            })

            Constants.DB.user.child(followerID).observeSingleEvent(of: .value, with: { snapshot in
                let data = snapshot.value as? [String : Any]
                
                if let invitations = data?["invitations"] as? [String:Any]{
                    
                    if let event = invitations["event"] as? [String:[String:Any]]{
                        for (_,invite) in event{
                            if let status = invite["status"] as? String{
                                if status == "accepted"{
                                    totalInvitation += 1
                                    let id = invite["ID"]  as! String
                                    
                                    
                                    Constants.DB.event.child(id).observeSingleEvent(of: .value, with: { snapshot in
                                        let info = snapshot.value as? [String : Any]
                                        
                                        let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as? String, longitude: (info?["longitude"])! as? String, date: (info?["date"])! as! String, creator: (info?["creator"])! as? String, id: id, category: info?["interest"] as? String, privateEvent: (info?["private"] as? Bool)!)
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MMM d, h:mm a"
                                        
                                        let time = dateFormatter.date(from: event.date!)
                                        let address = event.shortAddress
                                        let place = ItemOfInterest(itemName: address, imageURL: nil, type: "event")
                                        place.id = snapshot.key
                                        place.data = [
                                            "event": event
                                        ]
                                        
                                        let eventDF = DateFormatter()
                                        eventDF.dateFormat = "MMM d, h:mm a"
                                        
                                        if let time = time{
                                            
                                            let eventFeed = FocusNotification(type: NotificationType.Going, sender: followerUser, item: place, time: eventDF.date(from: event.date!)!)
                                            invitations_event.append(eventFeed)
                                            invitations_event.append(eventFeed)
                                            
                                        }
                                        invitationCount += 1
                                        if invitationCount == totalInvitation{
                                            gotInvitations(invitations_event)
                                            print("invitation done \(invitationCount)")
                                        }
                                    })
                                }
                            }
                            
                        }
                    }

                    
//                    if let place = invitations["place"] as? [String:[String:Any]]{
//                        for (_,invite) in place{
//                            if let status = invite["status"] as? String{
//                                if status == "accepted"{
//                                    totalInvitation += 1
//                                    let id = invite["ID"]  as! String
//                                    
//                                    
//                                    getYelpByID(ID: id, completion: {place in
//                                        
//                                        if place.id.characters.count > 0{
//                                            let dateFormatter = DateFormatter()
//                                            dateFormatter.dateFormat = "MMM d, h:mm a"
//                                            
//                                            let time = dateFormatter.date(from: dateFormatter.string(from: Date(timeIntervalSince1970: (invite["time"] as? Double)!)))
//                                            let address = place.address[0]
//                                            let place = ItemOfInterest(itemName: address, imageURL: nil, type: "place")
//                                            place.id = snapshot.key
//                                            place.data = [
//                                                "place": place
//                                            ]
//                                            if let time = time{
//                                                let eventFeed = FocusNotification(type: NotificationType.Going, sender: followerUser, item: place, time: time)
//                                                invitations_event.append(eventFeed)
//                                                
//                                            }
//                                            invitationCount += 1
//                                            if invitationCount == totalInvitation{
//                                                gotInvitations(invitations_event)
//                                                print("invitation done \(invitationCount)")
//                                            }
//                                        }
//                                        else{
//                                            invitationCount += 1
//                                            if invitationCount == totalInvitation{
//                                                gotInvitations(invitations_event)
//                                                print("invitation done \(invitationCount)")
//                                            }
//                                        }
//                                        
//                                    })
//                                    
//                                    
//                                }
//                            }
//                            
//                        }
//                    }
                }
            })
        }
    })
}


func getEventBriteToken(userCode: String, completion: @escaping (_ result: String) -> Void){
    
    let url = "https://www.eventbrite.com/oauth/token"
    let parameters: [String: String] = [
        "client_id" : "34IONXEGBQSXJGZXWO",
        "client_secret" : "FU6FJALJ6DBE6RCVZY2Q7QE73PQIFJRDSPMIAWBUK6XIOY4M3Q",
        "grant_type": "authorization_code",
        "code": userCode
    ]
    
    let headers: HTTPHeaders = [
        "content-type": "application/x-www-form-urlencoded",
        "cache-contro": "no-cache"
    ]
    
    Alamofire.request(url, method: .post, parameters:parameters, headers: headers).responseJSON { response in
        let json = JSON(data: response.data!)
        let token = json["access_token"].stringValue
        
        AuthApi.set(yelpAccessToken: token)
        
        completion(token)
        
    }
}

func getInterest(eventBriteId: String) -> String{
    
    for (interest, ids) in Constants.interests.eventBriteMapping{
        let id_list = ids.components(separatedBy: ",")
        for id in id_list{
            if id == eventBriteId{
                return interest
            }
        }
    }
    return ""
}

func getInterest(yelpCategory: String) -> String{
    //let yelpParent = Constants.interests.yelpParent[yelpCategory]
    var category = yelpCategory
    var parent = ""
    while let yelpParent = Constants.interests.yelpParent[category]{
        category = yelpParent
        parent = yelpParent
    }
    
    for (interest, ids) in Constants.interests.yelpMapping{
        let id_list = ids.components(separatedBy: ",")
        for id in id_list{
            if id == parent{
                return interest
            }
        }
    }
    return ""
}

func getEventBriteCategories() -> String{
    let interests = getUserInterests().components(separatedBy: ",")
    var categories = Set<String>()
    
    for interest in interests{
        if let category = Constants.interests.eventBriteMapping[interest]{
            categories.insert(category)
        }
    }
    return categories.joined(separator: ",")
}

func getYelpCategories() -> String{
    let interests = getUserInterests().components(separatedBy: ",")
    var categories = Set<String>()
    
    for interest in interests{
        if let category = Constants.interests.yelpMapping[interest]{
            categories.insert(category)
        }
    }
    return categories.joined(separator: ",")
}

func getYelpCategory(category: String)-> String{
    var categories = Set<String>()
    
    if let category = Constants.interests.yelpMapping[category]{
        categories.insert(category)
    }
    return categories.joined(separator: ",")
}


func saveUserInfo(){
    Crashlytics.sharedInstance().setUserIdentifier(AuthApi.getFirebaseUid())
    Crashlytics.sharedInstance().setUserEmail(AuthApi.getUserEmail())
    Crashlytics.sharedInstance().setUserName(AuthApi.getUserName())
}

func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
    let attrs = [
        NSFontAttributeName: UIFont(name: "Avenir-Black", size: 17),
        NSForegroundColorAttributeName: UIColor.white
    ]
    let nonBoldAttribute = [
        NSFontAttributeName: UIFont(name: "Avenir-Book", size: 17),
        NSForegroundColorAttributeName: UIColor.white
        ]
    let attrStr = NSMutableAttributedString(string: string, attributes: attrs ?? [:])
    if let range = nonBoldRange {
        attrStr.setAttributes(nonBoldAttribute, range: range)
    }
    return attrStr
}

func attributedString(from string: String, boldRange: NSRange?) -> NSAttributedString {
    let attrs = [
        NSFontAttributeName: UIFont(name: "Avenir-Black", size: 17),
        NSForegroundColorAttributeName: UIColor.white
    ]
    let nonBoldAttribute = [
        NSFontAttributeName: UIFont(name: "Avenir-Book", size: 17),
        NSForegroundColorAttributeName: UIColor.white
    ]
    let attrStr = NSMutableAttributedString(string: string, attributes: nonBoldAttribute)
    if let range = boldRange {
        attrStr.setAttributes(attrs, range: range)
    }
    return attrStr
}

func getPlaceName(location: CLLocation, completion: @escaping (String) -> Void){
    // Add below code to get address for touch coordinates.
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
        
        // Place details
        var placeMark: CLPlacemark!
        placeMark = placemarks?[0]
        
        // Address dictionary
        print(placeMark.addressDictionary as Any)
        
        // Location name
        if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
            print(locationName)
            completion(locationName as String)
        }
        // Street address
        if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
            print(street)
        }
        
    })
}

func getUnreadCount(count: @escaping (Int)->Void){
    Constants.DB.messages.child(AuthApi.getFirebaseUid()!).queryOrdered(byChild: "read").queryEqual(toValue: false).observe(.value, with: {(snapshot) in
        
        if let message = snapshot.value as? [String:Any]{
            count(message.count)
        }
        else{
            count(0)
        }
    })
}

   func getNearbyPlaces(text: String?, id: String, categories: String?, count: Int?, location: CLLocation, completion: @escaping ([Place])->Void){
    let url = "https://api.yelp.com/v3/businesses/search"
    let parameters: [String: Any] = [
        "term": text ?? "",
        "limit": count ?? 20,
        "categories": categories ?? "",
        "latitude" : location.coordinate.latitude,
        "longitude" : location.coordinate.longitude
    ]
    
    var places = [Place]()
    let headers: HTTPHeaders = [
        "authorization": "Bearer \(AuthApi.getYelpToken()!)",
        "cache-contro": "no-cache"
    ]
    
    Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
        let json = JSON(data: response.data!)
        
        
        for (_, business) in json["businesses"].enumerated(){
            let id = business.1["id"].stringValue
            let name = business.1["name"].stringValue
            let image_url = business.1["image_url"].stringValue
            let isClosed = business.1["is_closed"].boolValue
            let reviewCount = business.1["review_count"].intValue
            let rating = business.1["rating"].floatValue
            let latitude = business.1["coordinates"]["latitude"].doubleValue
            let longitude = business.1["coordinates"]["longitude"].doubleValue
            let price = business.1["price"].stringValue
            let address_json = business.1["location"]["display_address"].arrayValue
            let phone = business.1["display_phone"].stringValue
            let distance = business.1["distance"].doubleValue
            let categories_json = business.1["categories"].arrayValue
            let url = business.1["url"].stringValue
            let plain_phone = business.1["phone"].stringValue
            
            var address = [String]()
            for raw_address in address_json{
                address.append(raw_address.stringValue)
            }
            
            var categories = [Category]()
            for raw_category in categories_json as [JSON]{
                let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                categories.append(category)
            }
            
            let miles = (distance/1609.344).roundTo(places: 1)
            let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: miles, categories: categories, url: url, plainPhone: plain_phone)
            
            if !places.contains(place) && place.id != id{
                places.append(place)
                
            }
        }
        completion(places)
        
    }
}

func addGreenDot(label: UILabel, content: String, right: Bool = false){
    
    if content.characters.count > 0 {
        if !right{
            label.text =  "● \(content)"
        }
        else{
            label.text =  "\(content) ●"
        }
        
        let primaryFocus = NSMutableAttributedString(string: label.text!)
        
        if !right{
            primaryFocus.addAttribute(NSForegroundColorAttributeName, value: Constants.color.green, range: NSRange(location: 0, length: 1))
        }
        else{
            primaryFocus.addAttribute(NSForegroundColorAttributeName, value: Constants.color.green, range: NSRange(location: content.characters.count + 1, length: 1))
        }
        label.attributedText = primaryFocus
    }
    else{
        label.text = "N.A."
    }
}

   
func getYelpByID(ID:String,completion: @escaping (Place) -> Void){
    if let place = DataCache.instance.readObject(forKey: ID) as? Place{
        completion(place)
    }
    else{
        
        let url = "https://api.yelp.com/v3/businesses/\(ID)"
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(AuthApi.getYelpToken()!)",
            "cache-contro": "no-cache"
        ]
        
        Alamofire.request(url, method: .get, parameters:nil, headers: headers).responseJSON { response in
            let json = JSON(data: response.data!)
            let id = json["id"].stringValue
            let name = json["name"].stringValue
            let image_url = json["image_url"].stringValue
            let isClosed = json["is_closed"].boolValue
            let reviewCount = json["review_count"].intValue
            let rating = json["rating"].floatValue
            let latitude = json["coordinates"]["latitude"].doubleValue
            let longitude = json["coordinates"]["longitude"].doubleValue
            let price = json["price"].stringValue
            let address_json = json["location"]["display_address"].arrayValue
            let phone = json["display_phone"].stringValue
            let categories_json = json["categories"].arrayValue
            let url = json["url"].stringValue
            let plain_phone = json["phone"].stringValue
            let is_closed = json["is_closed"].boolValue
            
            var address = [String]()
            for raw_address in address_json{
                address.append(raw_address.stringValue)
            }
            
            var categories = [Category]()
            for raw_category in categories_json as [JSON]{
                let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                categories.append(category)
            }
            
            let distance = AuthApi.getLocation()!.distance(from: CLLocation(latitude: latitude, longitude: longitude))
            
            let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
            
//            DataCache.instance.write(object: place, forKey: ID)
            completion(place)
            
        }
    }

    
}

func dropfromTop(view: UIView){
//    let transition = CATransition()
//    transition.duration = 0.3
//    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
//    transition.type = kCATransitionMoveIn
//    transition.subtype = kCATransitionFromBottom
//    
//    view.window!.layer.add(transition, forKey: kCATransition)
}

func getUserInterests() -> String{
    if let interests = AuthApi.getInterests(){
        let selected = interests.components(separatedBy: ",")
        
        var final_interest = [String]()
        for interest in selected{
            final_interest.append(interest.components(separatedBy: "-")[0])
        }
        return final_interest.joined(separator: ",")
    }
    return ""
}
    
func crop(image: UIImage, width: Double, height: Double) -> UIImage? {
    
    if let cgImage = image.cgImage {
        
        let contextImage: UIImage = UIImage(cgImage: cgImage)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        var croppedContextImage: CGImage? = nil
        if let contextImage = contextImage.cgImage {
            if let croppedImage = contextImage.cropping(to: rect) {
                croppedContextImage = croppedImage
            }
        }
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        if let croppedImage:CGImage = croppedContextImage {
            let image: UIImage = UIImage(cgImage: croppedImage, scale: image.scale, orientation: image.imageOrientation)
            return image
        }
        
    }
    
    return nil
}

func getUserData(uid: String, gotInfo: @escaping (_ user: NotificationUser) -> Void){
    Constants.DB.user.child(uid).observeSingleEvent(of: .value, with: { snapshot in
        
        if let data = snapshot.value as? [String:Any]{
            let user = NotificationUser(username: data["username"] as? String, uuid: data["firebaseUserId"] as? String, imageURL: data["image_string"] as! String)
            
            gotInfo(user)
        }
    })
}

func matchingUserInterest(user: User) -> Int{
    let user_interest = AuthApi.getInterests()
    
    var user_interests = [Interest]()
    for interest in (user_interest?.components(separatedBy: ","))!{
        let interest_name = interest.components(separatedBy: "-")[0]
        
        user_interests.append(Interest(name: interest_name, category: nil, image: nil, imageString: nil))
    }
    
    let user_interest_set:Set<Interest> = Set(user_interests)
    let other_user:Set<Interest> = Set<Interest>(user.interests!)

    
    return other_user.intersection(user_interest_set).count
}

func getSuggestedEvents(interests: String, limit: Int, gotEvents: @escaping (_ user: [Event]) -> Void){
    var eventCount = 0
    var suggestions = [Event]()
    var eventDF = DateFormatter()
    eventDF.dateFormat = "MMM d, h:mm a"
    
    for interest in interests.components(separatedBy: ","){
        if interest.characters.count > 0{
            Constants.DB.event_interests.child(interest).observeSingleEvent(of: .value, with: {snapshot in
                if let events = snapshot.value as? [String:Any]{
                    
                    for (id, event) in events{
                        if let event = event as? [String:Any]{
                            if let id = event["event-id"] as? String{
                                Constants.DB.event.child(id).observeSingleEvent(of: .value, with: {snapshot in
                                    if let info = snapshot.value as? [String:Any]{
                                        if let event = Event.toEvent(info: info){
                                            event.id = id
                                            
                                            if let startDate = eventDF.date(from: event.date!), startDate > Date(){
                                                eventCount += 1
                                                suggestions.append(event)
                                            }
                                        }
                                        
                                        if eventCount == suggestions.count || suggestions.count == limit{
                                            suggestions.sort(by: {
                                                if let event1 = eventDF.date(from: $0.date!), let event2 = eventDF.date(from: $1.date!){
                                                    return event1 < event2
                                                }
                                                return true
                                            })
                                            gotEvents(suggestions)
                                        }
                                    }
                                })
                            }
                        }
                    }
                    
                }       
            })
        }
    }
}
   
func getSuggestedPlaces(interests: String, limit: Int, gotPlaces: @escaping (_ user: [Place]) -> Void){
    var suggestions = [Place]()
    var categories = Set<String>()
    
    for interest in interests.components(separatedBy: ","){
        if let category = Constants.interests.yelpMapping[interest]{
            categories.insert(category)
        }
    }
    
    for interest in categories{
        yelpSearch(interest: interest, location: AuthApi.getLocation()!, gotPlaces: { places in
            for place in places{
                getPlaceHours(id: place.id, gotHour: {hours, is_closed in
                    if hours != nil && !is_closed{
                        place.hours = hours
                        place.is_closed = is_closed
                        
                        if !place.is_closed{
                            suggestions.append(place)
                        }
                        
                        if suggestions.count == limit{
                            gotPlaces(suggestions)
                        }
                    }
                })
            }
        })
    }
}
   
func yelpSearch(interest: String, location: CLLocation, gotPlaces: @escaping (_ user: [Place]) -> Void){
    var places = [Place]()
    let url = "https://api.yelp.com/v3/businesses/search"
    let parameters: [String: Any] = [
        "categories": interest,
        "latitude" : Double(location.coordinate.latitude),
        "longitude" : Double(location.coordinate.longitude)
    ]
    
    let headers: HTTPHeaders = [
        "authorization": "Bearer \(AuthApi.getYelpToken()!)",
        "cache-contro": "no-cache"
    ]
    
    Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
        let json = JSON(data: response.data!)
        
        for (index, business) in json["businesses"].enumerated(){
            let id = business.1["id"].stringValue
            let name = business.1["name"].stringValue
            let image_url = business.1["image_url"].stringValue
            let isClosed = business.1["is_closed"].boolValue
            let reviewCount = business.1["review_count"].intValue
            let rating = business.1["rating"].floatValue
            let latitude = business.1["coordinates"]["latitude"].doubleValue
            let longitude = business.1["coordinates"]["longitude"].doubleValue
            let price = business.1["price"].stringValue
            let address_json = business.1["location"]["display_address"].arrayValue
            let phone = business.1["display_phone"].stringValue
            let distance = business.1["distance"].doubleValue
            let categories_json = business.1["categories"].arrayValue
            let url = business.1["url"].stringValue
            let plain_phone = business.1["phone"].stringValue
            let is_closed = business.1["is_closed"].boolValue
            
            var address = [String]()
            for raw_address in address_json{
                address.append(raw_address.stringValue)
            }
            
            var categories = [Category]()
            for raw_category in categories_json as [JSON]{
                let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                categories.append(category)
            }
            
            let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
            places.append(place)
        }
        
        gotPlaces(places)
    }
}

func getAttendingEvent(uid: String, gotEvents: @escaping (_ events: [Event]) -> Void){
    var eventCount = 0
    var events = [Event]()
    
    let DF = DateFormatter()
    DF.dateFormat = "MMM d, h:mm a"
    
    let timeDF = DateFormatter()
    timeDF.dateFormat = "h:mm a"
    
    Constants.DB.user.child(uid).child("invitations/event").observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? NSDictionary
        
        if let value = value{
            eventCount = value.count
            for (_,event) in value{
                let event_id = (event as? [String:Any])?["ID"]
                
                Constants.DB.event.child((event_id as? String)!).observeSingleEvent(of: .value, with: {snapshot in
                    let info = snapshot.value as? [String : Any]
                    
                    let event = Event.toEvent(info: info!)
                    
                    if let end = timeDF.date(from: (event?.endTime)!){
                        let start = DF.date(from: (event?.date!)!)!
                        if start < Date() && end > Date() && !(event?.privateEvent)!{
                            event?.id = event_id as! String
                            
                            events.append(event!)
                        }
                    }
                        
                    else if DF.date(from: (event?.date!)!)! > Date() && !(event?.privateEvent)!{
                        if Calendar.current.dateComponents([.day], from: DF.date(from: (event?.date!)!)!, to: Date()).day ?? 0 <= 7{
                            event?.id = event_id as! String
                            
                            events.append(event!)
                        }
                    }
                    
                    if eventCount == events.count{
                        gotEvents(events)
                    }
                })
            }
            
        }
        else{
            gotEvents(events)
        }
    })
}
   
   
func getFollowingAttendingEvent(uid: String, gotEvents: @escaping (_ events: [Event]) -> Void){
    var eventCount = 0
    var followers = [String]()
    var followingAttendingEvents = [Event]()
    var gotPlace = 0
    
    let DF = DateFormatter()
    DF.dateFormat = "MMM d, h:mm a"
    
    let timeDF = DateFormatter()
    timeDF.dateFormat = "h:mm a"
    
    
    Constants.DB.user.child(uid).child("following/people").observeSingleEvent(of: .value, with: { (snapshot) in
        if let value = snapshot.value as? [String:Any]{
            for (_, people) in value{
                let followingCount = value.count
                if let peopleData = people as? [String:Any]{
                    let UID = peopleData["UID"] as! String
                    followers.append(UID)
                    
                    getAttendingEvent(uid: UID, gotEvents: { events in
                        
                        for event in events{
                            if let end = timeDF.date(from: event.endTime){
                                let start = DF.date(from: event.date!)!
                                if start < Date() && end > Date() && !event.privateEvent{
                                    
                                    followingAttendingEvents.append(event)
                                }
                            }
                                
                            else if DF.date(from: event.date!)! > Date() && !event.privateEvent{
                                if Calendar.current.dateComponents([.day], from: DF.date(from: event.date!)!, to: Date()).day ?? 0 <= 7{
                                    
                                    followingAttendingEvents.append(event)
                                }
                            }
                            
                        }
                        
                        
                        
                        if followers.count == followingCount{
                            gotEvents(followingAttendingEvents)
                        }
                    })
                }
            }
        }
        else{
            gotPlace += 1
            
            if gotPlace == 2{
                gotEvents(followingAttendingEvents)
            }
        }
    })
    
    Constants.DB.user.child(uid).child("invitations/event").observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? NSDictionary
        
        if let value = value{
            eventCount = value.count
            for (_,event) in value{
                let event_id = (event as? [String:Any])?["ID"]
                
                Constants.DB.event.child((event_id as? String)!).observeSingleEvent(of: .value, with: {snapshot in
                    let info = snapshot.value as? [String : Any]
                    
                    let event = Event.toEvent(info: info!)
                    
                    if let end = timeDF.date(from: (event?.endTime)!){
                        let start = DF.date(from: (event?.date!)!)!
                        if start < Date() && end > Date() && !(event?.privateEvent)!{
                            
                        event?.id = event_id as! String
                        
                        followingAttendingEvents.append(event!)
                            
                        }
                    }
                        
                    else if DF.date(from: (event?.date!)!)! > Date() && !(event?.privateEvent)!{
                        if Calendar.current.dateComponents([.day], from: DF.date(from: (event?.date!)!)!, to: Date()).day ?? 0 <= 7{
                            
                            event?.id = event_id as! String
                            
                            followingAttendingEvents.append(event!)
                            
                        }
                    }
                    if eventCount == followingAttendingEvents.count{
                        gotEvents(followingAttendingEvents)
                    }
                })
            }
            
        }
        else{
            gotPlace += 1
            
            if gotPlace == 2{
                gotEvents(followingAttendingEvents)
            }
        }
    })
}
   
func getFollowingPlace(uid: String, gotPlaces: @escaping (_ place: [Place]) -> Void){
    var places = [Place]()
    var placeCount = 0
    
    Constants.DB.user.child(uid).child("following/places").observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? NSDictionary
        
        if let placeData = value{
            placeCount = placeData.count
            //                self.places.removeAll()
            for (_,place) in placeData
            {
                let place_id = (place as? [String:Any])?["placeID"]
                getYelpByID(ID: place_id as! String, completion: {place in
                    
                    getPlaceHours(id: place.id, gotHour: {hours, open in
                        if !places.contains(place){
                            place.hours = hours
                            place.set_is_open(is_open: open)
                            places.append(place)
                        }
                        
                        if places.count == placeCount{
                            gotPlaces(places)
                        }
                    })
                })
            }
        }
        else{
            gotPlaces(places)
        }
    })
}
   
func getPlaceHours(id: String, gotHour: @escaping (_ hour: [Hours]?, _ open: Bool) -> Void){
    if let token = AuthApi.getYelpToken(){
        let url = "https://api.yelp.com/v3/businesses/\(id)"
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(token)",
            "cache-contro": "no-cache"
        ]
        
        Alamofire.request(url, method: .get, parameters:nil, headers: headers).responseJSON { response in
            let json = JSON(data: response.data!)
            
            if json["hours"].arrayValue.count > 0{
                let open_hours = json["hours"].arrayValue[0].dictionaryValue
                var hours = [Hours]()
                for hour in (open_hours["open"]?.arrayValue)!{
                    let hour = Hours(start: hour["start"].stringValue, end: hour["end"].stringValue, day: hour["day"].intValue)
                    hours.append(hour)
                }
                
                gotHour(hours, json["hours"][0]["is_open_now"].boolValue)
                
            }
            gotHour(nil, json["hours"][0]["is_open_now"].boolValue)
        }
    }
}
   
func fetchAllPins(gotPin: @escaping (_ place: [pinData]) -> Void){
    var pins = [pinData]()
    
    Constants.DB.pins.observeSingleEvent(of: .value, with: { (snapshot) in
        let value = snapshot.value as? NSDictionary
        if value != nil
        {
           
            
            for (key,_) in (value)!
            {
                let data = pinData(UID: (value?[key] as! NSDictionary)["fromUID"] as! String, dateTS: (value?[key] as! NSDictionary)["time"] as! Double, pin: (value?[key] as! NSDictionary)["pin"] as! String, location: (value?[key] as! NSDictionary)["formattedAddress"] as! String, lat: (value?[key] as! NSDictionary)["lat"] as! Double, lng: (value?[key] as! NSDictionary)["lng"] as! Double, path: Constants.DB.pins.child(key as! String), focus: (value?[key] as! NSDictionary)["focus"] as? String ?? "")
                
                Constants.DB.user.child(data.fromUID).observeSingleEvent(of: .value, with: {snapshot in
                    
                    if let info = snapshot.value as? [String:Any]{
                        if let username = info["username"] as? String{
                            
                            
                            if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: data.dateTimeStamp), to: Date()).hour ?? 0 < 24{
                                data.username = username
                                pins.append(data)
                            }
                        }
                    }
                    
                })
                
            }
        }
    })
}
   
func setRatingAmountImage(ratingAmount: Double, ratingsStarImage: UIImageView){
    switch ratingAmount{
    case 0.0...0.9:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_0")
    case 1.0...1.4:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_1")
    case 1.5...1.9:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_1_half")
    case 2.0...2.4:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_2")
    case 2.5...2.9:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_2_half")
    case 3.0...3.4:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_3")
    case 3.5...3.9:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_3_half")
    case 4.0...4.4:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_4")
    case 4.5...4.9:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_4_half")
    case 5.0:
        ratingsStarImage.image = #imageLiteral(resourceName: "small_5")
    default:
        break
    }
}
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
