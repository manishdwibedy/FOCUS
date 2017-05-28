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

func getEvents(around location: CLLocation, completion: @escaping (_ result: String) -> Void){
    let url = "https://www.eventbriteapi.com/v3/events/search/"
    let parameters: [String: String] = [
        "token" : "R6U22QXZZZ52YX2XRTWX",
        "sort_by": "distance",
        "location.latitude": String(location.coordinate.latitude),
        "location.longitude" : String(location.coordinate.longitude),
        "location.within": "10mi"
    ]
    
    Alamofire.request(url, method: .get, parameters:parameters, headers: nil).responseJSON { response in
        let json = JSON(data: response.data!)
        let events = json["events"]
        
        for (_, eventJson) in events {
            
            print(eventJson)
            
//            let df: DateFormatter = DateFormatter()
//            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            let date: Date = df.date(from: eventJson["start"]["local"].stringValue)!
            let event = Event(title: eventJson["name"]["text"].stringValue, description: eventJson["description"]["text"].stringValue, fullAddress: "", shortAddress: "", latitude: "", longitude: "", date: eventJson["start"]["local"].stringValue, creator: "", category: "")
            
        }
        
        completion("")
        
    }
}

func isValidEmail(text:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: text)
}
