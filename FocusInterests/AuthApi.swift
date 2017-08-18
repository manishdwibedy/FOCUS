//
//  AuthApi.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import DataCache

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
    
    static func set(privateProfile: Bool) {
        defaults.set(privateProfile, forKey: "private")
    }
    
    static func getPrivate() -> Bool {
        if let privateProfile = defaults.object(forKey: "private") as? Bool {
            return privateProfile
        }
        return false
    }
    
    static func set(unread: Int) {
        defaults.set(unread, forKey: "unread")
    }
    
    static func getUnread() -> Int {
        if let unread = defaults.object(forKey: "unread") as? Int {
            return unread
        }
        return 0
    }
    
    static func set(read: Int) {
        defaults.set(read, forKey: "read")
    }
    
    static func getRead() -> Int {
        if let read = defaults.object(forKey: "read") as? Int {
            return read
        }
        return 0
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

    static func set(userImage: String?) {
        if let image = userImage {
            defaults.set(image, forKey: "userImage")
        }
        else{
            defaults.set(nil, forKey: "userImage")
        }
    }
    
    static func getUserImage() -> String? {
        if let userImage = defaults.object(forKey: "userImage") as? String {
            return userImage
        }
        return nil
    }
    
    static func set(username: String?) {
        if let username = username {
            defaults.set(username, forKey: "username")
        }
    }
    
    static func isNewToPage(index: Int) -> Bool {
        if let isNewToPage = defaults.object(forKey: "isNewToPage") as? [Bool] {
            return isNewToPage[index]
        }
        return true
    }
    
    static func setIsNewToPage(index: Int) {
        if let isNewToPage = defaults.object(forKey: "isNewToPage") as? [Bool] {
            var modified = isNewToPage
            modified[index] = false
            defaults.set(modified, forKey: "isNewToPage")
        }
        else{
            var modified = [true,true,true,true,true,true]
            modified[index] = false
            defaults.set(modified, forKey: "isNewToPage")
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
        defaults.set(nil, forKey: "username")
        defaults.set(nil, forKey: "userImage")
        defaults.set(nil, forKey: "interests")
        defaults.set(nil, forKey: "userEmail")
        defaults.set(nil, forKey: "facebookAccessToken")
        defaults.set(nil, forKey: "googleAccessToken")
        defaults.set(nil, forKey: "yelpAccessToken")
        defaults.set(nil, forKey: "Login")
        
        DataCache.instance.cleanAll()
        
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
        
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
        return CLLocation(latitude: 34.062149, longitude: -118.448056)
    }
    
    static func set(location: CLLocation){
        defaults.set("\(location.coordinate.latitude);;\(location.coordinate.longitude)", forKey: "last_location")
    }
    
    static func isNotificationAvailable() -> Bool{
        if let notification = defaults.object(forKey: "notification") as? Bool {
            return notification
        }
        return false
    }
    
    static func gotNotification(){
        defaults.set(true, forKey: "notification")
    }
    
    static func clearNotifications(){
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
        
        defaults.set(false, forKey: "notification")
    }
    
    static func getUnreadNotifications() -> Int{
        if let count = defaults.object(forKey: "notification_count") as? Int {
            return count
        }
        return 0
    }
    
    
    static func showPin() -> Bool{
        if let showPin = defaults.object(forKey: "show_pin") as? Bool {
            return showPin
        }
        return false
    }
    
    static func setShowPin(show: Bool){
        defaults.set(show, forKey: "show_pin")
    }
    
    static func savePlace(places: [Place]){
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: places)
        defaults.set(encodedData, forKey: "places")
        
    }
    
    static func getPlaces() -> [Place]{
        return (defaults.object(forKey: "places") as? [Place])!
    }
}
