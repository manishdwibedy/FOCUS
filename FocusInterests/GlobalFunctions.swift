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

func featuresToString(features: [Feature]) -> String {
    var strArray = [String]()
    for f in features {
        strArray.append(f.featureName!)
    }
    let joinedStr = strArray.joined(separator: ", ")
    return joinedStr
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
                result.append("\(days[last_day_start]) \(last_start) - \(last_end)")
            }
            else{
                result.append("\(days[last_day_start]) - \(days[last_day_end]) \(last_start) - \(last_end)")
            }
            last_day_start = hour.day
            last_day_end = hour.day
            last_start = hour.start
            last_end = hour.end
        }
    }
    return result
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

    var count = 0
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

                let event = Event(title: eventJson["name"]["text"].stringValue, description: eventJson["description"]["text"].stringValue, fullAddress: nil, shortAddress: nil, latitude: nil, longitude: nil, date: eventJson["start"]["local"].stringValue, creator: "", category: getInterest(eventBriteId: category_id))
                
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

func getDistance(fromLocation: CLLocation, toLocation: CLLocation, addBracket: Bool = false) -> String{
    let distanceInMeters = fromLocation.distance(from: toLocation)
    let distance = distanceInMeters/1609.344
    
    if addBracket{
        return "(\(distance.roundTo(places: 1)) mi)"
    }
    else{
        return "\(distance.roundTo(places: 1)) mi"
    }
    
}

func sendNotification(to id: String, title: String, body: String){
    let url = "http://focus-notifications.3hwampgg8c.us-west-2.elasticbeanstalk.com/sendMessage"
    
    let time = NSDate().timeIntervalSince1970
    
    Constants.DB.user.child("\(id)/notifications").childByAutoId().setValue([
        "title": title,
        "body": body,
        "time": Double(time)
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
    
    Constants.DB.user.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
        
        
        let user = snapshot.value as? [String : Any]
        
        let followers = user?["followers"] as? [String : Any]
        let people = followers?["people"] as? [String : [String: Any]] ?? [:]
        
        followerCount = (people.count)!
        for (_, follower) in people{
            let followerID = follower["UID"] as! String
//            let username = follower["username"] as! String
//            let imageURL = follower["imageURL"] as? String
//            let followerID = "0wOmLiHD6jWg33qyz0DxJ0BAEDy1"
            
            
            let followerUser = NotificationUser(username: "username", uuid: followerID, imageURL: nil)
            Constants.DB.pins.child(followerID).observeSingleEvent(of: .value, with: { snapshot in
                let pin11 = snapshot.value as? [String : Any]
                
                if let pin = pin11{
                    let time = Date(timeIntervalSince1970: pin["time"] as! Double)
                    let address = pin["formattedAddress"] as! String
                    let place = ItemOfInterest(itemName: address, imageURL: nil)
                    let pinFeed = FocusNotification(type: NotificationType.Pin, sender: followerUser, item: place, time: time)
                    pins.append(pinFeed)
                }
                
                pinCount += 1
                if pinCount == followerCount{
                    gotPins(pins)
                    print("pin done \(pinCount)")
                }
            })
            
            
            Constants.DB.event.queryOrdered(byChild: "creator").queryEqual(toValue: followerID).observeSingleEvent(of: .value, with: { snapshot in
                let eventInfo = snapshot.value as? [String : Any]
                
                if let eventInfo = eventInfo{
                    for (id, event) in eventInfo{
                        let info = event as? [String:Any]
                        let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id, category: info?["interest"] as? String)
//                        MMM dd, hh:mm
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM d, h:mm a"
                        
                        let time = dateFormatter.date(from: event.date!)
                        let address = event.shortAddress
                        let place = ItemOfInterest(itemName: address, imageURL: nil)
                        if let time = time{
                            let eventFeed = FocusNotification(type: NotificationType.Going, sender: followerUser, item: place, time: time)
                            events.append(eventFeed)
    
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
                        totalInvitation += event.count
                        
                        for (id,invite) in event{
                            let id = invite["ID"]  as! String
                            
                            
                            Constants.DB.event.child(id).observeSingleEvent(of: .value, with: { snapshot in
                                let info = snapshot.value as? [String : Any]
                                
                                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id, category: info?["interest"] as? String)
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM d, h:mm a"
                                
                                let time = dateFormatter.date(from: event.date!)
                                let address = event.shortAddress
                                let place = ItemOfInterest(itemName: address, imageURL: nil)
                                if let time = time{
                                    let eventFeed = FocusNotification(type: NotificationType.Going, sender: followerUser, item: place, time: time)
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
                    
//                    if let place = invitations["place"] as? [String:[String:Any]]{
//                        
//                        
//                        for (id,invite) in place{
//                            let id = invite["ID"]  as! String
                    
                            
//                            Constants.DB.place.child(id).observeSingleEvent(of: .value, with: { snapshot in
//                                let info = snapshot.value as? [String : Any]
//                                
//                                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id, category: info?["interest"] as? String)
//                                
//                                let dateFormatter = DateFormatter()
//                                dateFormatter.dateFormat = "MMM d, h:mm a"
//                                
//                                let time = dateFormatter.date(from: event.date!)
//                                let address = event.shortAddress
//                                let place = ItemOfInterest(itemName: address, imageURL: nil)
//                                if let time = time{
//                                    let eventFeed = FocusNotification(type: NotificationType.Going, sender: followerUser, item: place, time: time)
//                                    invitations.append(eventFeed)
//                                    
//                                }
//                                invitationCount += 1
//                                if invitationCount == totalInvitation{
//                                    print("invitation done \(invitationCount)")
//                                }
//                            })
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
    let yelpParent = Constants.interests.yelpParent[yelpCategory]
    for (interest, ids) in Constants.interests.yelpMapping{
        let id_list = ids.components(separatedBy: ",")
        for id in id_list{
            if id == yelpParent{
                return interest
            }
        }
    }
    return ""
}

func getEventBriteCategories() -> String{
    let interests = AuthApi.getInterests()?.components(separatedBy: ",")
    var categories = Set<String>()
    
    for interest in interests!{
        if let category = Constants.interests.eventBriteMapping[interest]{
            categories.insert(category)
        }
    }
    return categories.joined(separator: ",")
}

func getYelpCategories() -> String{
    let interests = AuthApi.getInterests()?.components(separatedBy: ",")
    var categories = Set<String>()
    
    for interest in interests!{
        if let category = Constants.interests.yelpMapping[interest]{
            categories.insert(category)
        }
    }
    return categories.joined(separator: ",")
}
