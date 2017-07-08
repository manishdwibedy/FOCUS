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
            "privateEvent": privateEvent
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
