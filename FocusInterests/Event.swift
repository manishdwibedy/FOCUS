//
//  Event.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import GooglePlaces
import FirebaseDatabase
import Alamofire
import SwiftyJSON

class Event: NSObject, NSCoding{
    var title: String?
    var eventDescription: String?
    var fullAddress: String?
    var shortAddress: String?
    var latitude: String?
    var longitude: String?
    var date: String?
    var creator: String?
    var id: String?
    var attendeeCount = 0
    var category: String?
    var image_url: String? = nil
    var endTime: String = ""
    var price: Double? = 0
    var distance = 0.0
    var privateEvent = true
    var url: String? = nil
    
    init(title: String, description: String, fullAddress: String?, shortAddress: String?, latitude: String?, longitude: String?, date: String, creator: String?, id: String? = nil, category: String?, privateEvent: Bool) {
        self.title = title
        self.eventDescription = description
        self.fullAddress = fullAddress
        self.shortAddress = shortAddress
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.creator = creator
        self.id = id
        self.category = category
        self.privateEvent = privateEvent
    }
    
    func saveToDB(ref: DatabaseReference) -> String{
        let newEvent = ref.childByAutoId()
        
        let event = [
            "title": self.title!,
            "title_lowered": self.title!.lowercased(),
            "description": self.eventDescription!,
            "fullAddress": self.fullAddress!,
            "shortAddress": self.shortAddress!,
            "latitude": self.latitude!,
            "longitude": self.longitude!,
            "date": self.date!,
            "endtime": self.endTime,
            "price": self.price ?? 0,
            "creator": self.creator!,
            "interests": self.category!,
            "private": privateEvent
        ] as [String : Any] 
        newEvent.setValue(event)
        
        return newEvent.key
    }
    
    func setEndTime(endTime: String){
        self.endTime = endTime
    }
    
    func setAttendessCount(count: Int){
        attendeeCount = count
    }
    
    func setPrice(price: Double){
        self.price = price
    }
    
    func setImageURL(url: String){
        self.image_url = url
    }
    
    required init(coder decoder: NSCoder) {
        self.title = decoder.decodeObject(forKey: "title") as? String ?? ""
        self.eventDescription = decoder.decodeObject(forKey: "description") as? String ?? ""
        self.fullAddress = decoder.decodeObject(forKey: "fullAddress") as? String ?? ""
        self.shortAddress = decoder.decodeObject(forKey: "shortAddress") as? String ?? ""
        self.latitude = decoder.decodeObject(forKey: "latitude") as? String ?? ""
        self.longitude = decoder.decodeObject(forKey: "longitude") as? String ?? ""
        self.date = decoder.decodeObject(forKey: "date") as? String ?? ""
        self.creator = decoder.decodeObject(forKey: "creator") as? String ?? ""
        self.id = decoder.decodeObject(forKey: "id") as? String ?? ""
        self.attendeeCount = decoder.decodeObject(forKey: "attendeeCount") as? Int ?? 0
        self.category = decoder.decodeObject(forKey: "category") as? String ?? ""
        self.endTime = decoder.decodeObject(forKey: "endTime") as? String ?? ""
        self.price = decoder.decodeObject(forKey: "price") as? Double ?? 0
        self.privateEvent = decoder.decodeObject(forKey: "privateEvent") as? Bool ?? true
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: "title")
        coder.encode(self.eventDescription, forKey: "description")
        coder.encode(self.fullAddress, forKey: "fullAddress")
        coder.encode(self.shortAddress, forKey: "shortAddress")
        coder.encode(self.latitude, forKey: "latitude")
        coder.encode(self.longitude, forKey: "longitude")
        coder.encode(self.date, forKey: "date")
        coder.encode(self.creator, forKey: "creator")
        coder.encode(self.id, forKey: "id")
        coder.encode(self.attendeeCount, forKey: "attendeeCount")
        coder.encode(self.category, forKey: "category")
        coder.encode(self.endTime, forKey: "endTime")
        coder.encode(self.price, forKey: "price")
        coder.encode(self.price, forKey: "privateEvent")
    }
    
    static func cacheEvent(event: Event){
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: event)
        UserDefaults.standard.set(encodedData, forKey: "new_event")
        
    }
    
    static func fetchEvent() -> Event?{
        if let data = UserDefaults.standard.data(forKey: "new_event"),
            let event = NSKeyedUnarchiver.unarchiveObject(with: data) as? Event {
            return event
        }
        return nil
    }
    
    static func clearCache(){
        UserDefaults.standard.set(nil, forKey: "new_event")
    }
    
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func toEvent(info: [String: Any]) -> Event?{
        if !info.keys.contains("title"){
            return nil
        }
        
        guard let title = info["title"]! as? String else{
            return nil
        }
        
        guard let description = info["description"]! as? String else{
            return nil
        }
        
        guard let fullAddress = info["fullAddress"]! as? String else{
            return nil
        }
        
        guard let shortAddress = info["shortAddress"]! as? String else{
            return nil
        }
        
        guard let latitude = info["latitude"]! as? String else{
            return nil
        }
        
        guard let longitude = info["longitude"]! as? String else{
            return nil
        }
        
        guard let date = info["date"]! as? String else{
            return nil
        }
        
        guard let creator = info["creator"]! as? String else{
            return nil
        }
        
        guard let interest = info["interests"]! as? String else{
            return nil
        }
        
        guard let privateEvent = info["private"]! as? Bool else{
            return nil
        }
        
        let event = Event(title: title, description: description, fullAddress: fullAddress, shortAddress: shortAddress, latitude: latitude, longitude: longitude, date: date, creator: creator, id: nil, category: interest, privateEvent: privateEvent)
        
        if let attending = info["attendingList"] as? [String:Any]{
            event.setAttendessCount(count: attending.count)
        }
        
        return event
    }
}

extension Event{
    static func getEvents(gotEvents: @escaping (_ result: [Event]) -> Void){
        
        var eventList = [Event]()
        let DF = DateFormatter()
        DF.dateFormat = "MMM d, h:mm a"
        
        let timeDF = DateFormatter()
        timeDF.dateFormat = "h:mm a"
        
        var count = 0
        Constants.DB.event.observe(DataEventType.childAdded, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            let info = events// as? [String:Any]
            
            if let event = Event.toEvent(info: info){
                
                if let end = timeDF.date(from: event.endTime){
                    count += 1
                    let start = DF.date(from: event.date!)!
                    if start < Date() && end > Date() && !event.privateEvent{
                        eventList.append(event)
                    }
                }
                    
                else if DF.date(from: event.date!)! > Date() && !event.privateEvent{
                    if Calendar.current.dateComponents([.hour], from: DF.date(from: event.date!)!, to: Date()).hour ?? 0 < 24{
                        count += 1
                        eventList.append(event)
                    }
                }
                
                if count == eventList.count{
                    gotEvents(eventList)
                }
            }
        })
    }
    
    static func getNearyByEvents(query: String = "", category: String = "", location: CLLocationCoordinate2D = (AuthApi.getLocation()?.coordinate)!, gotEvents: @escaping (_ result: [Event]) -> Void){
        var events = [Event]()
        
        let url = "https://app.ticketmaster.com/discovery/v2/events.json"
        let parameters: [String: Any] = [
            "keyword": query,
            "size": 20,
            "latlong": "\(location.latitude),\(location.longitude)",
            "radius": 20,
            "classificationName": category,
            "apikey": "dScAOnFScudDodKZDJ47ehxcJ1pXnihD"
        ]
        
        Alamofire.request(url, method: .get, parameters:parameters, headers: nil).responseJSON { response in
            let json = JSON(data: response.data!)
            
            for data in json["_embedded"]["events"]{
                let name = data.1["name"].stringValue
                
                
                let address = data.1["_embedded"]["venues"].arrayValue[0]
                let fullAddress = "\(address["address"]["line1"].stringValue);;\(address["city"]["name"].stringValue)"
                let shortAddress = "\(address["name"].stringValue)"
                let lat = address["location"]["latitude"].stringValue
                let long = address["location"]["longitude"].stringValue
                let category = data.1["classifications"][0]["segment"]["name"].stringValue
                
                let start = data.1["dates"]["start"]
                let date = "\(start["localDate"].stringValue) \(start["localTime"].stringValue)"
                
                let price = data.1["priceRanges"][0]["min"].doubleValue
                let image = data.1["images"][0]["url"].stringValue
                
                let parkingInfo = address["parkingDetail"].stringValue
                let info = data.1["info"].stringValue
                let boxOfficeInfo = address["boxOfficeInfo"].stringValue
                let pleaseNoteInfo = data.1["pleaseNote"].stringValue
                let desc = "\(info)\n\(pleaseNoteInfo)\n\(boxOfficeInfo)\(parkingInfo)"
                
                let url = data.1["url"].stringValue
                
                let event = Event(title: name, description: desc, fullAddress: fullAddress, shortAddress: shortAddress, latitude: lat, longitude: long, date: date, creator: "", id: data.1["id"].stringValue, category: category, privateEvent: false)
                
                event.url = url
                event.price = price
                event.image_url = image
                
                events.append(event)
            }
            gotEvents(events)
            
            
        }

    }
}
