//
//  PlaceCache.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 7/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import DataCache

class PlaceCache{
    static let defaults = UserDefaults.standard
//    static func set(userImage: String?) {
//        if let image = userImage {
//            defaults.set(image, forKey: "userImage")
//        }
//    }
//    
//    static func getUserImage() -> String? {
//        if let userImage = defaults.object(forKey: "userImage") as? String {
//            return userImage
//        }
//        return nil
//    }
    
//    private static func getLocations(location: CLLocation){
//        if let locations = defaults.object(forKey: "locations") as? String {
//            if let lat_long_pairs = locations.components(separatedBy: ";"){
//                for lat_long in lat_long_pairs{
//                    let coordinate = lat_long.components(separatedBy: ";")
//                    
//                    let loc = CLLocation(latitude: Double(coordinate[0]), longitude: Double(coordinate[0]))
//                    
//                    if loc.distance(location) < 50{
//                        return loc
//                    }
//                }
//                defaults.set(image, forKey: "locations")
//                //add location
//            }
//            //add location
//        }
//        //add location
//    }
    
    
    static func getPlace(location: CLLocation){
        
    }
}
