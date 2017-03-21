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
    var description: String?
    var interests = [Interest]()
    
    init(fakeDict: (String, AnyObject)) {
        fromFakeDict(fakeDict: fakeDict)
    }
    
    init(userName: String?, firebaseId: String?, imageString: String?, currentLocation: CLLocationCoordinate2D?) {
        self.userName = userName
        self.firebaseId = firebaseId
        self.imageString = imageString
        self.currentLocation = currentLocation
    }
    
    init(){}
    
    func fromFakeDict(fakeDict: (String, AnyObject)) {
        
    }
    
    func setCurrentLocation(location: CLLocationCoordinate2D) {
        self.currentLocation = location
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return currentLocation
    }
    
    func setInterests(interests: [Interest]) {
        self.interests.append(contentsOf: interests)
    }
    
    func getInterests() -> [Interest]? {
        return self.interests
    }
    
    func setUsername(username: String) {
        self.userName = username
    }
    
    func getUsername() -> String? {
        return userName
    }
    
    func setImageString(imageString: String) {
        self.imageString = imageString
    }
    
    func getImageString() -> String? {
        return imageString
    }
    
    func setFirebaseId(firebaseId: String) {
        self.firebaseId = firebaseId
    }
    
    func getFirebaseId() -> String? {
        return firebaseId
    }
    
    func setDescription(description: String) {
        self.description = description
    }
}
