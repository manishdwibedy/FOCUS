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
    var id: String?
    
    init(title: String, description: String, fullAddress: String, shortAddress: String, latitude: String, longitude: String, date: String, creator: String, id: String? = nil) {
        self.title = title
        self.description = description
        self.fullAddress = fullAddress
        self.shortAddress = shortAddress
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.creator = creator
        self.id = id
    }
    
    func saveToDB(ref: FIRDatabaseReference) -> String{
        let newEvent = ref.childByAutoId()
        
        let event = [
            "title": self.title!,
            "description": self.description!,
            "fullAddress": self.fullAddress!,
            "shortAddress": self.shortAddress!,
            "latitude": self.latitude!,
            "longitude": self.longitude!,
            "date": self.date!,
            "creator": self.creator!
        ] as [String : String]
        newEvent.setValue(event)
        
        return newEvent.key
    }
}
