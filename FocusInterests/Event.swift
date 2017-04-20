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
    let place: GMSPlace?
    let date: Date?
    let creator: String?
    
    init(title: String, description: String, place: GMSPlace, date: Date, creator: String) {
        self.title = title
        self.description = description
        self.place = place
        self.date = date
        self.creator = creator
    }
    
    func saveToDB(ref: FIRDatabaseReference){
        let newEvent = ref.childByAutoId()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        let shortAddress = "\(self.place?.addressComponents?[0].name), \(self.place?.addressComponents?[0].name)"
        let event = [
            "title": self.title!,
            "description": self.description!,
            "fullAddress": (self.place?.formattedAddress)!,
            "shortAddress": shortAddress,
            "date": "\(dateFormatter.string(from: self.date!))",
            
            // creating dummy events by mary
            "creator": Constants.dummyUsers.mary.uuid!
            
            // Original creator
//            "creator": AuthApi.getFirebaseUid()!
        ] as [String : String]
        newEvent.setValue(event)
    }
}
