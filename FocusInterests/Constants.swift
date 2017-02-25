//
//  Constants.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct tableCellReuseIDs {
        public static let notificationCellId = "NotificationCell"
    }
    
    struct otherIds {
        public static let loginSB = "Login"
        public static let openingLoginVC = "FirstLoginViewController"
        public static let mainSB = "Main"
        public static let openingMainVC = "OpeningTabBarController"
        
    }
    
    struct keys {
        public static let googleMapsAPIKey = "AIzaSyCcfvYP6NRSYLJkvf3SAmIGBiQfdLWRqEM"
    }
    
    struct dummyFeatures {
        
        public static let feature1 = Feature(featureName: "Babies")
        public static let feature2 = Feature(featureName: "Food Obsession")
        public static let feature3 = Feature(featureName: "Meadows")
        public static let feature4 = Feature(featureName: "Knife skills")
        public static let feature5 = Feature(featureName: "Storm chasing")
        public static let feature6 = Feature(featureName: "Painting")
        
    }
    
    struct interests {
        public static let football = Interest(name: "Football", category: InterestCategory.Sports)
        public static let basketball = Interest(name: "Basketball", category: InterestCategory.Sports)
        public static let soccer = Interest(name: "Soccer", category: InterestCategory.Sports)
        public static let music = Interest(name: "Music", category: InterestCategory.Art)
        public static let modernArt = Interest(name: "Modern Art", category: InterestCategory.Art)
        public static let museums = Interest(name: "Museums", category: InterestCategory.Art)
        public static let bars = Interest(name: "Bars", category: InterestCategory.Nightlife)
        public static let clubs = Interest(name: "Clubs", category: InterestCategory.Nightlife)
        public static let events = Interest(name: "Events", category: InterestCategory.Nightlife)
        public static let italian = Interest(name: "Italian", category: InterestCategory.Food)
        public static let mexican = Interest(name: "Mexican", category: InterestCategory.Food)
        public static let french = Interest(name: "French", category: InterestCategory.Food)
        public static let clothing = Interest(name: "Clothing", category: InterestCategory.Shopping)
        public static let electronics = Interest(name: "Electronics", category: InterestCategory.Shopping)
        public static let furniture = Interest(name: "Furniture", category: InterestCategory.Shopping)
    }
    
    struct dummyItemsOInterest {
        public static let item1 = ItemOfInterest(itemName: "Lalapalooza", features: [Constants.dummyFeatures.feature3, Constants.dummyFeatures.feature5], mainImage: UIImage(named: "pumpkins"), distance: "3.4 mi")
        public static let item2 = ItemOfInterest(itemName: "Sado County Auto Show", features: [Constants.dummyFeatures.feature3, Constants.dummyFeatures.feature5], mainImage: UIImage(named: "Humes"), distance: "5.0 mi")
        public static let item3 = ItemOfInterest(itemName: "Apiary Convention", features: [Constants.dummyFeatures.feature1, Constants.dummyFeatures.feature6], mainImage: UIImage(named: "Shroom"), distance: "3.4 mi")
    }
    
    struct dummyUsers {
        public static let mary = User(username: "Amanda", uuid: "neafsh8387uh4iw4fh", userImage: UIImage(named: "FamHalloween"), interests: [Constants.interests.football, Constants.interests.bars, Constants.interests.events])
        public static let al = User(username: "Al", uuid: "aksdjf93488743q7bp", userImage: UIImage(named: "pumpkins"), interests: [Constants.interests.furniture, Constants.interests.electronics, Constants.interests.bars])
        public static let yoon = User(username: "Yoon", uuid: "ashf94uhw9e8hf39", userImage: UIImage(named: "Lopart"), interests: [Constants.interests.football, Constants.interests.soccer, Constants.interests.clothing])
    }
    
    struct notifications {
        public static let notification1 = Notification(type: NotificationType.Invite, sender: Constants.dummyUsers.al, item: Constants.dummyItemsOInterest.item2)
        public static let notification2 = Notification(type: NotificationType.Like, sender: Constants.dummyUsers.mary, item: Constants.dummyItemsOInterest.item1)
        public static let notification3 = Notification(type: NotificationType.Tag, sender: Constants.dummyUsers.yoon, item: Constants.dummyItemsOInterest.item3)
        
    }
    
    struct settings {
        public static let cellTitles = ["Choose Interests", "Invite Friends", "Change Username & Password", "Tutorial", "Help", "Terms", "Logout"]
    }
    
    struct defaultsKeys {
        public static let loggedIn = "isLoggedIn"
    }
    
    struct textfieldPlaceholers {
        public static let logVCUname = "Username"
        public static let logVCPword = "Password"
        public static let signFName = "First name"
        public static let signLName = "Last name"
        public static let signEmail = "Email"
        public static let signPword = "Password"
        public static let signUName = "Choose Username"
        public static let signLocation = "Location"
        public static let signPhoto = "Upload Photo"
    }
}

