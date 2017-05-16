//
//  Place.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class Place: Equatable{
    let id: String
    let name: String
    let image_url: String
    let isClosed: Bool
    let reviewCount: Int
    let rating: Float
    let latitude: Double
    let longitude: Double
    let price: String
    let address: [String]
    let phone: String
    let distance: Double
    let categories: [Category]
    
    init(id:String, name:String, image_url: String, isClosed: Bool, reviewCount: Int, rating: Float, latitude: Double, longitude: Double, price: String, address: [String], phone: String, distance: Double, categories: [Category]){
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
    }
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Category {
    let name: String
    let alias: String
}
