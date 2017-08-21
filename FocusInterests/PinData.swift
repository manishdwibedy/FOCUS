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
//        self.dbPath = Constants.DB.pins.child(self.username)
       
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
    
    public static func toPin(uuid: String, value: NSDictionary) -> pinData?{
        
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
        
        guard let focus = value["focus"] as? String else{
            return nil
        }
        address = address.replacingOccurrences(of: ";;", with: "\n")
        
        let data = pinData(UID: uuid, dateTS: time, pin: caption, location: address, lat: lat, lng: lng, path: Constants.DB.pins.child(uuid), focus: focus)
        
        return data
    }
    
    public static func getPins(gotPin: @escaping (_ pin: pinData) -> Void) -> UInt{
        let ref = Constants.DB.pins.observe(.childAdded, with: {snapshot in
            if let value = snapshot.value as? [String:Any]{
                if let uuid = value["fromUID"] as? String{
                    if let data = pinData.toPin(uuid: uuid, value: value as NSDictionary){
                        Constants.DB.user.child(value["fromUID"] as! String).observeSingleEvent(of: .value, with: {snapshot in
                            
                            if let info = snapshot.value as? [String:Any]{
                                if let username = info["username"] as? String{
                                    
                                    if let privateProfile = info["private"] as? Bool{
                                        if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: data.dateTimeStamp), to: Date()).hour ?? 0 < 24{
                                            data.username = username
                                            if !privateProfile{
                                                gotPin(data)
                                            }
                                        }
                                        if let uid = info["firebaseUserId"] as? String{
                                            if uid == AuthApi.getFirebaseUid()!{
                                                if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: data.dateTimeStamp), to: Date()).hour ?? 0 < 24{
                                                    data.username = username
                                                    
                                                    gotPin(data)
                                                }
                                            }
                                        }
                                    }
                                    else if let uid = info["firebaseUserId"] as? String{
                                        if uid == AuthApi.getFirebaseUid()!{
                                            if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: data.dateTimeStamp), to: Date()).hour ?? 0 < 24{
                                                data.username = username
                                                
                                                gotPin(data)
                                            }
                                        }
                                    }
                                    else{
                                        if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: data.dateTimeStamp), to: Date()).hour ?? 0 < 24{
                                            data.username = username
                                            
                                            gotPin(data)
                                        }
                                    }
                                }
                            }
                            
                        })
                    }
                }
            }
        })
        
        return ref
    }
}
