//
//  EventLocation.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/27/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class EventLocation{
    let address: String
    let latitude: String
    let longitude: String
    
    init(address: String, latitude: String, longitude: String) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
