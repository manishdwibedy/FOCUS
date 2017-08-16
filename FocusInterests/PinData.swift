//
//  PinData.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 6/30/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import FirebaseDatabase

class pinData: NSObject, NSCoding{
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
    
    required init?(coder aDecoder: NSCoder) {
        self.fromUID = aDecoder.decodeObject(forKey: "fromUID") as! String

        self.dateTimeStamp = aDecoder.decodeDouble(forKey: "date") as! Double
        self.pinMessage = aDecoder.decodeObject(forKey: "pinMessage") as! String
        self.locationAddress = aDecoder.decodeObject(forKey: "locationAddress") as! String
        
        let lat = aDecoder.decodeDouble(forKey: "lat") as! Double
        let long = aDecoder.decodeDouble(forKey: "long") as! Double
        self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        
        self.focus = aDecoder.decodeObject(forKey: "focus") as! String
        self.username = aDecoder.decodeObject(forKey: "username") as! String
        self.dbPath = Constants.DB.pins.child(self.username)
       
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.fromUID, forKey: "fromUID")
        aCoder.encode(self.dateTimeStamp, forKey: "date")
        aCoder.encode(self.pinMessage, forKey: "pinMessage")
        aCoder.encode(self.locationAddress, forKey: "locationAddress")
        aCoder.encode(self.coordinates.latitude, forKey: "lat")
        aCoder.encode(self.coordinates.longitude, forKey: "long")
        aCoder.encode(self.focus, forKey: "focus")
        aCoder.encode(self.username, forKey: "username")
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
