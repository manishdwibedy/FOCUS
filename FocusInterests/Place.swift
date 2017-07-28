//
//  Place.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class Place: Equatable, NSCoding{
    var id: String
    var name: String
    var image_url: String
    var isClosed: Bool
    var reviewCount: Int
    var rating: Float
    var latitude: Double
    var longitude: Double
    var price: String
    var address: [String]
    var phone: String
    var plainPhone: String
    var distance: Double
    var categories: [Category]
    var hours: [Hours]?
    var url: String
    var is_closed = false
    
    init(id:String, name:String, image_url: String, isClosed: Bool, reviewCount: Int, rating: Float, latitude: Double, longitude: Double, price: String, address: [String], phone: String, distance: Double, categories: [Category], url: String, plainPhone: String){
        self.id = id
        self.name = name
        self.image_url = image_url
        self.isClosed = isClosed
        self.reviewCount = reviewCount
        self.rating = rating
        self.latitude = latitude
        self.longitude = longitude
        self.price = price
        self.address = address
        self.phone = phone
        self.distance = distance
        self.categories = categories
        self.url = url
        self.plainPhone = plainPhone
    }
    
    func set_is_open(is_open: Bool){
        self.is_closed = !is_open
    }
    
    func setHours(hours: [Hours]){
        self.hours = hours
    }
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getHour(day: Int) -> Hours?{
        if let hours = self.hours{
            for hour in hours{
                if hour.day == day{
                    return hour
                }
            }
        }
        
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.image_url = aDecoder.decodeObject(forKey: "image_url") as! String
        self.isClosed = aDecoder.decodeBool(forKey: "isClosed") as! Bool
        self.reviewCount = aDecoder.decodeInt32(forKey: "reviewCount") as! Int
        self.rating = aDecoder.decodeFloat(forKey: "rating") as! Float
        self.latitude = aDecoder.decodeDouble(forKey: "latitude") as! Double
        self.longitude = aDecoder.decodeDouble(forKey: "longitude") as! Double
        self.price = aDecoder.decodeObject(forKey: "price") as! String
        self.address = aDecoder.decodeObject(forKey: "address") as! [String]
        self.phone = aDecoder.decodeObject(forKey: "phone") as! String
        self.plainPhone = aDecoder.decodeObject(forKey: "plainPhone") as! String
        self.distance = aDecoder.decodeDouble(forKey: "distance") as! Double
        self.categories = aDecoder.decodeObject(forKey: "categories") as! [Category]
        self.hours = aDecoder.decodeObject(forKey: "hours") as! [Hours]
        self.url = aDecoder.decodeObject(forKey: "url") as! String
        self.is_closed = aDecoder.decodeBool(forKey: "is_closed") as! Bool
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.image_url, forKey: "image_url")
        aCoder.encode(self.is_closed, forKey: "isClosed")
        aCoder.encode(self.reviewCount, forKey: "reviewCount")
        aCoder.encode(self.rating, forKey: "rating")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.price, forKey: "price")
        aCoder.encode(self.address, forKey: "address")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.plainPhone, forKey: "plainPhone")
        aCoder.encode(self.distance, forKey: "distance")
        aCoder.encode(self.categories, forKey: "categories")
        aCoder.encode(self.hours, forKey: "hours")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.is_closed, forKey: "is_closed")
    }
}

struct Category {
    let name: String
    let alias: String
    
//    public required init?(coder aDecoder: NSCoder) {
//        self.alias = aDecoder.decodeObject(forKey: "alias") as! String
//        self.name = aDecoder.decodeObject(forKey: "name") as! String
//    
//    }
//    open func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.alias, forKey: "alias")
//        aCoder.encode(self.name, forKey: "name")
//    }
}

struct Hours{
    let start: String
    let end: String
    let day: Int
    
//    public required init?(coder aDecoder: NSCoder) {
//        self.start = aDecoder.decodeObject(forKey: "start") as! String
//        self.end = aDecoder.decodeObject(forKey: "end") as! String
//        self.day = aDecoder.decodeInt32(forKey: "day") as! String
//        
//    }
//    open func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.start, forKey: "start")
//        aCoder.encode(self.end, forKey: "end")
//        aCoder.encode(self.day, forKey: "day")
//    }
}
