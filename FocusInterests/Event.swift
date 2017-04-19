//
//  Event.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import GooglePlaces

class Event{
    let title: String?
    let description: String?
    let place: GMSPlace?
    let date: Date?
    
    init(title: String, description: String, place: GMSPlace, date: Date) {
        self.title = title
        self.description = description
        self.place = place
        self.date = date
    }
}
