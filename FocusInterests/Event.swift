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
class Event{
    let title: String?
    let description: String?
    let fullAddress: String?
    let shortAddress: String?
    let latitude: String?
    let longitude: String?
    let date: String?
    let creator: String?
    
    init(title: String, description: String, fullAddress: String, shortAddress: String, latitude: String, longitude: String, date: String, creator: String) {
        self.title = title
        self.description = description
        self.fullAddress = fullAddress
        self.shortAddress = shortAddress
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.creator = creator
    }
    
    func saveToDB(ref: FIRDatabaseReference){
        let newEvent = ref.childByAutoId()
        
        let event = [
            "title": self.title!,
            "description": self.description!,
            "fullAddress": self.fullAddress!,
            "shortAddress": self.shortAddress!,
            "latitude": self.latitude!,
            "longitude": self.longitude!,
            "date": self.date!,
            
            // creating dummy events by mary
            "creator": Constants.dummyUsers.mary.uuid!
            
            
            
            // Original creator
//            "creator": self.creator
        ] as [String : String]
        newEvent.setValue(event)
    }
}
