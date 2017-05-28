//
//  Constants.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage

struct Constants {
    
    struct tableCellReuseIDs {
        public static let notificationCellId = "NotificationCell"
        public static let chooseInterestId = "ChooseInterest"
        public static let collectionCellId = "CollectionCell"
    }
    
    struct otherIds {
        public static let loginSB = "Login"
        public static let openingLoginVC = "FirstLoginViewController"
        public static let mainSB = "Main"
        public static let openingMainVC = "OpeningTabBarController"
        
    }
    
    struct keys {
        public static let googleMapsAPIKey = "AIzaSyCcfvYP6NRSYLJkvf3SAmIGBiQfdLWRqEM"
        public static let eventBriteToken = "366MU6UCBA72BO3LJTHL"
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
        
//        Meet up
//        Coffee
//        Chill
//        Celebration
//        Food
//        Drinks
//        Work
//        Learn
//        Entertainment
//        Arts
//        Music
//        Beauty
//        Fashion
//        Networking
//        Exercise
//        Wellness
//        Sports
//        Outdoors
//        Views
//        Causes
        
        public static let football = Interest(name: "Football", category: InterestCategory.Sports, image: nil, imageString: nil)
        public static let basketball = Interest(name: "Basketball", category: InterestCategory.Sports, image: nil, imageString: nil)
        public static let soccer = Interest(name: "Soccer", category: InterestCategory.Sports, image: UIImage(named: "blackSoccer"), imageString: nil)
        public static let bike = Interest(name: "Bike", category: InterestCategory.Sports, image: nil, imageString: nil)
        public static let music = Interest(name: "Music", category: InterestCategory.Art, image: nil, imageString: nil)
        public static let modernArt = Interest(name: "Modern Art", category: InterestCategory.Art, image: nil, imageString: nil)
        public static let murals = Interest(name: "Murals", category: InterestCategory.Art, image: nil, imageString: nil)
        public static let museums = Interest(name: "Museums", category: InterestCategory.Art, image: nil, imageString: nil)
        public static let bars = Interest(name: "Bars", category: InterestCategory.Nightlife, image: nil, imageString: nil)
        public static let clubs = Interest(name: "Clubs", category: InterestCategory.Nightlife, image: nil, imageString: nil)
        public static let events = Interest(name: "Events", category: InterestCategory.Nightlife, image: nil, imageString: nil)
        public static let italian = Interest(name: "Italian", category: InterestCategory.Food, image: nil, imageString: nil)
        public static let mexican = Interest(name: "Mexican", category: InterestCategory.Food, image: nil, imageString: nil)
        public static let french = Interest(name: "French", category: InterestCategory.Food, image: nil, imageString: nil)
        public static let clothing = Interest(name: "Clothing", category: InterestCategory.Shopping, image: nil, imageString: nil)
        public static let electronics = Interest(name: "Electronics", category: InterestCategory.Shopping, image: nil, imageString: nil)
        public static let furniture = Interest(name: "Furniture", category: InterestCategory.Shopping, image: nil, imageString: nil)
        
        
        public static let interest_list = [interests.football, interests.basketball, interests.soccer, interests.bike, interests.music, interests.modernArt]
        
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
    
    struct dummyFocusUsers {
        public static let mary = FocusUser(userName: "Mary Jones", firebaseId: nil, imageString: nil, currentLocation: nil)
        public static let bill = FocusUser(userName: "Bill Brasky", firebaseId: nil, imageString: nil, currentLocation: nil)
        public static let ellie = FocusUser(userName: "Ellie Jacoby", firebaseId: nil, imageString: nil, currentLocation: nil)
        public static let albert = FocusUser(userName: "Albert Schloss", firebaseId: nil, imageString: nil, currentLocation: nil)
        public static let amanda = FocusUser(userName: "Amanda Thornburg", firebaseId: nil, imageString: nil, currentLocation: nil)
        public static let Joe = FocusUser(userName: "Joe Hynes", firebaseId: nil, imageString: nil, currentLocation: nil)
        public static let chris = FocusUser(userName: "Chris Hynes", firebaseId: nil, imageString: nil, currentLocation: nil)
        public static let patty = FocusUser(userName: "Patricia Blackmore", firebaseId: nil, imageString: nil, currentLocation: nil)
        
    }
    
    struct FollowArrays {
        public static let followers = [dummyFocusUsers.albert, dummyFocusUsers.mary, dummyFocusUsers.chris, dummyFocusUsers.Joe, dummyFocusUsers.amanda]
        public static let followings = [dummyFocusUsers.ellie, dummyFocusUsers.albert, dummyFocusUsers.bill, dummyFocusUsers.mary, dummyFocusUsers.chris, dummyFocusUsers.patty]
    }
    
    struct notifications {
       
        public static let notification1 = FocusNotification(type: NotificationType.Invite, sender: Constants.dummyUsers.al, item: Constants.dummyItemsOInterest.item2)
        public static let notification2 = FocusNotification(type: NotificationType.Like, sender: Constants.dummyUsers.mary, item: Constants.dummyItemsOInterest.item1)
        public static let notification3 = FocusNotification(type: NotificationType.Tag, sender: Constants.dummyUsers.yoon, item: Constants.dummyItemsOInterest.item3)
    }
    
    struct settings {
        public static let cellTitles = ["Choose Interests", "Invite Facebook Friends", "Invite Contacts", "Change Username & Password", "Private Profile", "Tutorial", "Help and Support", "Send Feedback", "Open source libraries", "Terms", "Privacy Policy", "Clear Search History", "Logout"]
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
    
    struct DB {
        public static let event = FIRDatabase.database().reference().child("events")
        public static let user = FIRDatabase.database().reference().child("users")
        public static let messages = FIRDatabase.database().reference().child("messages")
        public static let message_content = FIRDatabase.database().reference().child("message_content")
        public static let places = FIRDatabase.database().reference().child("places")
        public static let following_place = FIRDatabase.database().reference().child("following_place")
        public static let pins = FIRDatabase.database().reference().child("pins")
        public static let feedback = FIRDatabase.database().reference().child("feedback")
    }
    
    struct storage{
        public static let event = FIRStorage.storage().reference().child("events")
        public static let messages = FIRStorage.storage().reference().child("messages")
        public static let pins = FIRStorage.storage().reference().child("pins")
    }
    
    struct Twitter{
        public static let consumerKey = "kDcg3AljHuqwQkS7ZYvo6aqzz"
        public static let consumerSecret = "SibT0zEI9tnoqwQddABKMzf6nel16oCoHDvti8fFWYKWufFHIp"
    }
}

