//
//  PinData.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 6/30/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import FirebaseDatabase

class pinData
{
    var fromUID = String()
    var dateTimeStamp = Double()
    var pinMessage = String()
    var locationAddress = String()
    var coordinates = CLLocationCoordinate2D()
    var dbPath = DatabaseReference()
    var focus = ""
    var username = ""
    
    init(UID:String, dateTS:Double, pin: String, location: String, lat: Double, lng: Double, path: DatabaseReference, focus: String) {
        self.fromUID = UID
        self.dateTimeStamp = dateTS
        self.pinMessage = pin
        self.locationAddress = location
        self.coordinates.latitude = lat
        self.coordinates.longitude = lng
        self.dbPath = path
        self.focus = focus
        
    }
    
    public static func toPin(user: User, value: NSDictionary) -> pinData?{
        
        guard let time = value["time"] as? Double else{
            return nil
        }
        
        guard let uid = value["fromUID"] as? String else{
            return nil
        }
        
        guard let caption = value["pin"] as? String else{
            return nil
        }
        
        guard var address = value["formattedAddress"] as? String else{
            return nil
        }
        
        guard let lat = value["lat"] as? Double else{
            return nil
        }
        
        guard let lng = value["lng"] as? Double else{
            return nil
        }
        
        guard let uuid = user.uuid else{
            return nil
        }
        
        guard let focus = value["focus"] as? String else{
            return nil
        }
        address = address.replacingOccurrences(of: ";;", with: "\n")
        
        let data = pinData(UID: uid, dateTS: time, pin: caption, location: address, lat: lat, lng: lng, path: Constants.DB.pins.child(uuid), focus: focus)
        
        return data
    }
}
