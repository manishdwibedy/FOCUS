//
//  AuthApi.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

struct AuthApi {
    
    static let defaults = UserDefaults.standard
    
    static func set(loggedIn: LoginTypes) {
        defaults.set(loggedIn.rawValue, forKey: "Login")
    }
    
    static func getLoginType() -> LoginTypes{
        return LoginTypes(rawValue: defaults.value(forKey: "Login") as! String)!
    }
    
    static func set(firebaseUid: String?) {
        if let id = firebaseUid {
            defaults.set(id, forKey: "firebaseUid")
        }
    }
    
    static func getFirebaseUid() -> String? {
        if let uid = defaults.object(forKey: "firebaseUid") as? String {
            return uid
        }
        return nil
    }
    
    static func set(userEmail: String?) {
        if let email = userEmail {
            defaults.set(email, forKey: "userEmail")
        }
    }
    
    static func getUserEmail() -> String? {
        if let email = defaults.object(forKey: "userEmail") as? String {
            return email
        }
        return nil
    }
    
    static func set(username: String?) {
        if let username = username {
            defaults.set(username, forKey: "username")
        }
    }
    
    static func getUserName() -> String? {
        if let username = defaults.object(forKey: "username") as? String {
            return username
        }
        return nil
    }
    
    static func set(facebookToken: String?) {
        defaults.set(facebookToken, forKey: "facebookAccessToken")
    }
    
    static func getFacebookToken() -> String? {
        if let facebookToken = defaults.object(forKey: "facebookAccessToken") as? String {
            return facebookToken
        }
        return nil
    }
    
    static func set(twitterToken: String?) {
        defaults.set(twitterToken, forKey: "twitterAccessToken")
    }
    
    static func set(twitterTokenSecret: String?) {
        defaults.set(twitterTokenSecret, forKey: "twitterAccessTokenSecret")
    }

    static func getTwitterToken() -> String? {
        if let twitterToken = defaults.object(forKey: "twitterAccessToken") as? String {
            return twitterToken
        }
        return nil
    }
    
    static func gettwitterTokenSecret() -> String? {
        if let twitterTokenSecret = defaults.object(forKey: "twitterAccessTokenSecret") as? String {
            return twitterTokenSecret
        }
        return nil
    }
    
    static func set(googleToken: String?) {
        if let token = googleToken {
            defaults.set(token, forKey: "googleAccessToken")
        }
    }
    
    static func getGoogleToken() -> String? {
        if let token = defaults.object(forKey: "googleAccessToken") as? String {
            return token
        }
        return nil
    }
    
    static func set(FCMToken: String?) {
        if let token = FCMToken {
            defaults.set(token, forKey: "FCMToken")
        }
    }
    
    static func getFCMToken() -> String? {
        if let token = defaults.object(forKey: "FCMToken") as? String {
            return token
        }
        return nil
    }
    
    static func getYelpToken() -> String?{
        if let token = defaults.object(forKey: "yelpAccessToken") as? String {
            return token
        }
        return nil
    }
    
    static func setDefaultsForLogout() {
        defaults.set(nil, forKey: "userEmail")
        defaults.set(nil, forKey: "facebookAccessToken")
        defaults.set(nil, forKey: "googleAccessToken")
        defaults.set(nil, forKey: "yelpAccessToken")
    }
    
    static func setEmailConfirmationSent() {
        defaults.set(true, forKey: "emailConfirmationSent")
    }
    
    static func getEmailConfirmationSent() -> Bool {
        return defaults.bool(forKey: "s")
    }
    
    static func setEmailConfirmed(confirmed: Bool) {
        defaults.set(confirmed, forKey: "emailConfirmed")
    }
    
    static func getEmailConfirmed() -> Bool {
        return defaults.bool(forKey: "emailConfirmed")
    }
    
    static func setPassword(password: String) {
        defaults.set(password, forKey: "password")
    }
    
    static func set(yelpAccessToken: String) {
        defaults.set(yelpAccessToken, forKey: "yelpAccessToken")
    }

    
    static func getPassword() -> String? {
        let pword: String? = defaults.object(forKey: "password") as? String
        return pword
    }
    
    
    static func isNewUser() -> Bool{
        if let userFlag = defaults.object(forKey: "newUser") as? Bool {
            return userFlag
        }
        return true
    }
    
    static func setNewUser(){
        defaults.set(false, forKey: "newUser")
    }
    
    static func set(interests: String?) {
        if let interests = interests {
            defaults.set(interests, forKey: "interests")
        }
    }
    
    static func getInterests() -> String? {
        if let interests = defaults.object(forKey: "interests") as? String {
            return interests
        }
        return nil
    }
    
    static func getEventBriteToken() -> String?{
        if let token = defaults.object(forKey: "eventBriteToken") as? String {
            return token
        }
        return nil
    }
    
    static func set(eventBriteAccessToken: String) {
        defaults.set(eventBriteAccessToken, forKey: "eventBriteToken")
    }
    
    static func getLocation() -> CLLocation?{
        if let location = defaults.object(forKey: "last_location") as? String {
            let coord = location.components(separatedBy: ";;")
            return CLLocation(latitude: Double(coord[0])!, longitude: Double(coord[1])!)
        }
        return nil

    }
    
    static func set(location: CLLocation){
        defaults.set("\(location.coordinate.latitude);;\(location.coordinate.longitude)", forKey: "last_location")
    }
}
