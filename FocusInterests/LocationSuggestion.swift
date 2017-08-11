//
//  LocationSuggestion.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 8/11/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LocationSuggestion{
    let name: String
    let address: String
    let distance: String
    let lat: Double
    let long: Double
    
    init(name: String, address: String, distance: String, lat: Double, long: Double) {
        self.name = name
        self.address = address
        self.distance = distance
        self.lat = lat
        self.long = long
    }
    
    static func getNearbyPlaces(location: CLLocation, gotSuggestions: @escaping (_ suggestions: [LocationSuggestion]) -> Void){
        var locationSuggestions = [LocationSuggestion]()
        let url = "https://api.foursquare.com/v2/venues/search"
        let parameters: [String: Any] = [
            "v": "20161016",
            "ll": "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "client_id": Constants.keys.fourSquareClientID,
            "client_secret": Constants.keys.fourSquareClientSecret
        ]
        
        Alamofire.request(url, method: .get, parameters:parameters, headers: nil).responseJSON { response in
            let json = JSON(data: response.data!)
            
            let suggestions = json["response"]["venues"]
            
            for suggestionData in suggestions{
                let name = suggestionData.1["name"].stringValue
                let location = suggestionData.1["location"].dictionaryValue
                let distance = (location["distance"]?.doubleValue)!/1609.344
                
                var adddress = [String]()
                for addressPart in (location["formattedAddress"]?.arrayValue)!{
                    adddress.append(addressPart.stringValue)
                }
                
                let lat = location["lat"]?.doubleValue
                let long = location["lng"]?.doubleValue
                let suggestion = LocationSuggestion(name: name, address: adddress.joined(separator: ", "), distance: "\(distance.roundTo(places: 2)) mi", lat: lat!, long: long!)
                    
                locationSuggestions.append(suggestion)
            }
            gotSuggestions(locationSuggestions)
            
        }
        
        
    }
}
