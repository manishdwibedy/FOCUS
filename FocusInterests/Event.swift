//
//  Event.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class Event{
    let title: String?
    let description: String?
    let place: String?
    let date: Date?
    let time: String?
    
    init(title: String, description: String, place: String, date: Date, time: String) {
        self.title = title
        self.description = description
        self.place = place
        self.date = date
        self.time = time
    }
}
