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

func getDistance(fromLocation: CLLocation, toLocation: CLLocation) -> String{
    let distanceInMeters = fromLocation.distance(from: toLocation)
    let distance = distanceInMeters/1609.344
    
    return "(\(distance.roundTo(places: 1)) mi)"
}

func sendNotification(to id: String, title: String, body: String){
    let url = "http://focus-notifications.3hwampgg8c.us-west-2.elasticbeanstalk.com/sendMessage"
    
    Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/notifications").childByAutoId().setValue([
        "title": title,
        "body": body,
        "time": 1
        ])
    
    Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
        
        
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
