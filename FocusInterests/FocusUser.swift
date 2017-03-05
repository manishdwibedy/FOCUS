//
//  File.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/4/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import CoreLocation

class FocusUser {
    
    var userName: String?
    var firebaseId: String?
    var imageString: String?
    var currentLocation: CLLocationCoordinate2D?
    var interests: [Interest]?
    
    init(fakeDict: (String, AnyObject)) {
        fromFakeDict(fakeDict: fakeDict)
    }
    
    init(userName: String?, firebaseId: String?, imageString: String?, currentLocation: CLLocationCoordinate2D?, interests: [Interest]) {
        self.userName = userName
        self.firebaseId = firebaseId
        self.imageString = imageString
        self.currentLocation = currentLocation
        self.interests = interests
    }
    
    func fromFakeDict(fakeDict: (String, AnyObject)) {
        
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return currentLocation
    }
}
