//
//  AnimationViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 8/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseMessaging
import Alamofire
import FirebaseDatabase
import SwiftyJSON
import DataCache

class AnimationViewController: UIViewController {

    @IBOutlet weak var loadingImage: UIImageView!
    
    var notificationCount = 0
    var messageCount = 0
    var notifications = [FocusNotification]()
    var feeds = [FocusNotification]()
    
    
    var pins = [pinData]()
    var attendingEvent = [Event]()
    var events = [Event]()
    var places = [Place]()
    var followingPlaces = [Place]()
    
    var placeMapping = [String: Place]()
    let DF = DateFormatter()
    let timeDF = DateFormatter()
    var dataCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DF.dateFormat = "MMM d, h:mm a"
        self.timeDF.dateFormat = "h:mm a"
        
        loadingImage.loadGif(name: "loading")
        loadingImage.backgroundColor = UIColor(hex: "8a94a0")
        
        DataCache.instance.write(object: events as NSCoding, forKey: "events")
        DataCache.instance.write(object: places as NSCoding, forKey: "places")
        DataCache.instance.write(object: pins as NSCoding, forKey: "pins")
        DataCache.instance.write(object: followingPlaces as NSCoding, forKey: "following_places")
        DataCache.instance.write(object: notifications as NSCoding, forKey: "notifications")
        
        loadMap()
        showPins(showAll: true, interests: "")
        getEvents()
        
//        User.getFollowing(gotFollowing: {users in
//            DataCache.instance.write(object: users as NSCoding, forKey: "following_users")
//        })
//        
//        User.getFollowers(gotFollowers: {users in
//            DataCache.instance.write(object: users as NSCoding, forKey: "followers_users")
//        })
        
        if let token = AuthApi.getYelpToken(){
            showPlaces(showAll: false, interests: "")
        }
        else{
            getYelpToken(completion: {(token) in
                AuthApi.set(yelpAccessToken: token)
                self.showPlaces(showAll: false, interests: "")
            })
        }
        
        
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToMap), userInfo: nil, repeats: false)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMap(){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).keepSynced(true)
        Constants.DB.pins.keepSynced(true)
        
        getUnreadCount(count: {number in
            self.messageCount = number
            
        })
        self.feeds.removeAll()
        
        var not_count = 0
        var count_received = 0
        var read_notifications = AuthApi.getUnreadNotifications()
        
        if AuthApi.getYelpToken() == nil || AuthApi.getYelpToken()?.characters.count == 0{
            getYelpToken(completion: { token in
                AuthApi.set(yelpAccessToken: token)
                
                not_count = 0
                NotificationUtil.getNotificationCount(gotNotification: {notif in
                    
                    self.notifications.append(contentsOf: Array(Set<FocusNotification>(notif)))
                    
                    count_received += 1
                    if count_received == 5 + 1{
                        not_count += Array(Set<FocusNotification>(self.notifications)).count
                        
                        not_count -= read_notifications
                        
                        let application = UIApplication.shared
                        application.applicationIconBadgeNumber = not_count + application.applicationIconBadgeNumber
                        
                        self.notificationCount = not_count
                    }
                }, gotInvites: {invites in
                    self.notifications.append(contentsOf: Array(Set<FocusNotification>(invites)))
                    
                    count_received += 1
                    if count_received == 5 + 1{
                        not_count += Array(Set<FocusNotification>(self.notifications)).count
                        
                        for invite in (invites as? [FocusNotification])!{
                            if let data = invite.item?.data as? [String:Any]{
                                if let status = data["status"] as? String{
                                    if status != "accepted" || status != "declined"{
                                        not_count += 1
                                    }
                                }
                            }
                            
                        }
                        
                        not_count -= read_notifications
                        
                        let application = UIApplication.shared
                        application.applicationIconBadgeNumber = not_count + application.applicationIconBadgeNumber
                        
                        self.notificationCount = not_count
                        count_received = 0
                    }
                } , gotFeed: {feed in
                    self.feeds.append(contentsOf: Array(Set<FocusNotification>(feed)))
                    
                    if count_received == 5 + 1{
                        not_count += Array(Set<FocusNotification>(self.notifications)).count
                        
                        not_count -= read_notifications
                        
                        let application = UIApplication.shared
                        application.applicationIconBadgeNumber = not_count + application.applicationIconBadgeNumber
                        count_received = 0
                    }
                })
                
            })
        }
        else{
            not_count = 0
            NotificationUtil.getNotificationCount(gotNotification: {notif in
                self.notifications.append(contentsOf: notif)
                
                count_received += 1
                if count_received == 5 + 1{
                    not_count += Array(Set<FocusNotification>(self.notifications)).count
                    
                    for invite in (self.notifications as? [FocusNotification])!{
                        if let data = invite.item?.data as? [String:Any]{
                            if let status = data["status"] as? String{
                                if status != "accepted" || status != "declined"{
                                    not_count += 1
                                }
                            }
                            else{
                                not_count += 1
                            }
                        }
                        
                    }
                    
                    not_count -= read_notifications
                    
                    let application = UIApplication.shared
                    application.applicationIconBadgeNumber = not_count + application.applicationIconBadgeNumber
                    
                    self.notificationCount = not_count
                    count_received = 0
                }
            }, gotInvites: {invite in
                self.notifications.append(contentsOf: invite)
                count_received += 1
                if count_received == 5 + 1{
                    not_count += Array(Set<FocusNotification>(self.notifications)).count
                    
                    for invite in (self.notifications as? [FocusNotification])!{
                        if let data = invite.item?.data as? [String:Any]{
                            if let status = data["status"] as? String{
                                if status != "accepted" || status != "declined"{
                                    self.notificationCount += 1
                                }
                            }
                            else{
                                self.notificationCount += 1
                            }
                        }
                        
                    }
                    
                    not_count -= read_notifications
                    
                    let application = UIApplication.shared
                    application.applicationIconBadgeNumber = not_count + application.applicationIconBadgeNumber
                    
                    self.notificationCount = not_count
                    count_received = 0
                }
                
            } , gotFeed: {feed in
                self.feeds.append(contentsOf: feed)
                
                if count_received == 5 + 1{
                    not_count += Array(Set<FocusNotification>(self.notifications)).count
                    
                    not_count -= read_notifications
                    
                    let application = UIApplication.shared
                    application.applicationIconBadgeNumber = not_count + application.applicationIconBadgeNumber
                    

                    count_received = 0
                }
            })
        }
        
        let token = Messaging.messaging().fcmToken
        Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/token").setValue(token)
        AuthApi.set(FCMToken: token)
    }
    
    func getEvents(){
        Constants.DB.event.keepSynced(true)
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).keepSynced(true)
        
        getAttendingEvent(uid: AuthApi.getFirebaseUid()!, gotEvents: {events in
            DataCache.instance.write(object: events as NSCoding, forKey: "attending_events")
        })
        
        Constants.DB.event.observeSingleEvent(of:.value, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            let info = events// as? [String:Any]
            //            for (id, event) in events{
            
            
            if let event = Event.toEvent(info: info){
                if let attending = info["attendingList"] as? [String:Any]{
                    event.setAttendessCount(count: attending.count)
                }
                
                if let end = self.timeDF.date(from: event.endTime){
                    let start = self.DF.date(from: event.date!)!
                    if start < Date() && end > Date() && !event.privateEvent{
                        self.events.append(event)
                    }
                }
                    
                else if self.DF.date(from: event.date!)! > Date() && !event.privateEvent{
                    if Calendar.current.dateComponents([.day], from: self.DF.date(from: event.date!)!, to: Date()).day ?? 0 <= 7{
                        self.events.append(event)
                    }
                    if !self.events.contains(event){
                        self.events.append(event)
                    }
                    
                    
                }
            }
            //            let event = Event(title: (info["title"])! as! String, description: (info["description"])! as! String, fullAddress: (info["fullAddress"])! as! String, shortAddress: (info["shortAddress"])! as! String, latitude: (info["latitude"])! as? String, longitude: (info["longitude"])! as? String, date: (info["date"])! as! String, creator: (info["creator"])! as? String, id: snapshot.key, category: info["interests"] as? String, privateEvent: (info["private"] as? Bool)!)
            //
            
            
            
            //                let item = MapCluster(position: position, name: event.title!, icon: UIImage(named: "Event")!, id: String(describing: self.events.count), type: "event")
            //                self.clusterManager.add(item)
            //                self.searchEventsTab?.events.append(event)
            //            }
            
            //            // Call cluster() after items have been added to perform the clustering and rendering on map.
            //            self.clusterManager.cluster()
            //
            //            // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
            //            self.clusterManager.setDelegate(self, mapDelegate: self)
            
        })
        
        if let location = AuthApi.getLocation(){
            Event.getNearyByEvents(query: "", category: "", location: location.coordinate, gotEvents: {events in
                
                var DF = DateFormatter()
                DF.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var dateOnlyDF = DateFormatter()
                dateOnlyDF.dateFormat = "yyyy-MM-dd "
                
                var sortedEvents = events.sorted(by: {
                    var date1: Date?, date2: Date?
                    if let date = DF.date(from: $0.0.date!){
                        date1 = date
                    }
                    else{
                        date1 = dateOnlyDF.date(from: $0.0.date!)
                    }
                    
                    if let date = DF.date(from: $0.1.date!){
                        date2 = date
                    }
                    else{
                        date2 = dateOnlyDF.date(from: $0.1.date!)
                    }
                    
                    return date1! < date2!
                })
                
                self.dataCount += 1
                self.events.append(contentsOf: sortedEvents)
//                self.moveToMap()
            })
        }
    }

    func showPins(showAll: Bool, interests: String){
        self.dataCount += 1
        if showAll{
            fetchAllPins(gotPin: {pins in
                self.pins = pins
                
//                self.moveToMap()
            })
            
        }
        else{
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").observeSingleEvent(of: .value, with: {snapshot in
                
                self.dataCount += 1
                
                if let people = snapshot.value as? [String:[String:Any]]{
                    let count = people.count
                    
                    for (id, value) in people{
                        let UID = (value["UID"] as? String)!
                        
                        Constants.DB.user.child(UID).observeSingleEvent(of: .value, with: {snapshot in
                            let value = snapshot.value as? NSDictionary
                            if value != nil
                            {
                                for (key,_) in (value)!
                                {
                                    let pin = pinData(UID: (value?[key] as! NSDictionary)["fromUID"] as! String, dateTS: (value?[key] as! NSDictionary)["time"] as! Double, pin: (value?[key] as! NSDictionary)["pin"] as! String, location: (value?[key] as! NSDictionary)["formattedAddress"] as! String, lat: (value?[key] as! NSDictionary)["lat"] as! Double, lng: (value?[key] as! NSDictionary)["lng"] as! Double, path: Constants.DB.pins.child(key as! String), focus: (value?[key] as! NSDictionary)["focus"] as? String ?? "")
                                    
                                    Constants.DB.user.child(pin.fromUID).observeSingleEvent(of: .value, with: {snapshot in
                                        
                                        if let info = snapshot.value as? [String:Any]{
                                            if let username = info["username"] as? String{
                                                
                                                
                                                if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: pin.dateTimeStamp), to: Date()).hour ?? 0 < 24{
                                                    pin.username = username
                                                    
                                                    self.pins.append(pin)
                                                }
                                            }
                                        }
                                        
                                    })
                                    
                                }
//                                self.moveToMap()
                            }
                        })
                    }
                }
                
            })
        }
    }
    
    func fetchPlaces(around location: CLLocation, token: String){
        let followingCount = 0
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if let placeData = value{
                for (_,place) in placeData
                {
                    let place_id = (place as? [String:Any])?["placeID"]
                    getYelpByID(ID: place_id as! String, completion: {place in
                        
                        if !self.followingPlaces.contains(place), place.id.characters.count > 0{
                            self.followingPlaces.append(place)
                        }
                    })
                    
                }
            }
        })
        
        var yelpIndex = 0
        let yelpInterests = getYelpCategories().components(separatedBy: ",")
        for interest in yelpInterests{
            
            let url = "https://api.yelp.com/v3/businesses/search"
            let parameters: [String: Any] = [
                "categories": interest,
                "latitude" : Double(location.coordinate.latitude),
                "longitude" : Double(location.coordinate.longitude)
            ]
            
            let headers: HTTPHeaders = [
                "authorization": "Bearer \(AuthApi.getYelpToken()!)",
                "cache-contro": "no-cache"
            ]
            
            Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
                let json = JSON(data: response.data!)
                yelpIndex += 1
                let initial = self.places.count
                for (index, business) in json["businesses"].enumerated(){
                    let id = business.1["id"].stringValue
                    let name = business.1["name"].stringValue
                    let image_url = business.1["image_url"].stringValue
                    let isClosed = business.1["is_closed"].boolValue
                    let reviewCount = business.1["review_count"].intValue
                    let rating = business.1["rating"].floatValue
                    let latitude = business.1["coordinates"]["latitude"].doubleValue
                    let longitude = business.1["coordinates"]["longitude"].doubleValue
                    let price = business.1["price"].stringValue
                    let address_json = business.1["location"]["display_address"].arrayValue
                    let phone = business.1["display_phone"].stringValue
                    let distance = business.1["distance"].doubleValue
                    let categories_json = business.1["categories"].arrayValue
                    let url = business.1["url"].stringValue
                    let plain_phone = business.1["phone"].stringValue
                    let is_closed = business.1["is_closed"].boolValue
                    
                    var address = [String]()
                    for raw_address in address_json{
                        address.append(raw_address.stringValue)
                    }
                    
                    var categories = [Category]()
                    for raw_category in categories_json as [JSON]{
                        let name = raw_category["title"].stringValue
                        let alias = raw_category["alias"].stringValue
                        let category = Category(name: name, alias: alias)
                        categories.append(category)
                    }
                    
                    let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
                    
                    self.placeMapping[place.id] = place
                    self.getPlaceHours(id: place.id)
                    self.places.append(place)
                    
                }
                if yelpIndex == yelpInterests.count{
//                    self.moveToMap()
                }
                
                
                //            self.clusterManager.cluster()
            }
        }
    }
    
    func showPlaces(showAll: Bool, interests: String){
        self.dataCount += 1
        if showAll{
            
            
            for interest in interests.components(separatedBy: ","){
                let yelpInterst = Constants.interests.yelpMapping[interest]
                
                yelpSearch(interest: yelpInterst!, location: AuthApi.getLocation()!, gotPlaces: {nearByPlaces in
                    for place in nearByPlaces{
                        self.getPlaceHours(id: place.id)
                        self.places.append(place)
                    }
//                    self.moveToMap()
                })
            }
        }
        else{
            
            if let token = AuthApi.getYelpToken(){
                self.fetchPlaces(around: AuthApi.getLocation()!, token: token)
            }
            else{
                getYelpToken(completion: {(token) in
                    AuthApi.set(yelpAccessToken: token)
                    self.fetchPlaces(around:
                        AuthApi.getLocation()!, token: token)
                })
            }
        }
    }
    
    func getPlaceHours(id: String){
        if let token = AuthApi.getYelpToken(){
            let url = "https://api.yelp.com/v3/businesses/\(id)"
            
            let headers: HTTPHeaders = [
                "authorization": "Bearer \(token)",
                "cache-contro": "no-cache"
            ]
            
            Alamofire.request(url, method: .get, parameters:nil, headers: headers).responseJSON { response in
                let json = JSON(data: response.data!)
                let place = self.placeMapping[id]
                
                if json["hours"].arrayValue.count > 0{
                    let open_hours = json["hours"].arrayValue[0].dictionaryValue
                    var hours = [Hours]()
                    for hour in (open_hours["open"]?.arrayValue)!{
                        let hour = Hours(start: hour["start"].stringValue, end: hour["end"].stringValue, day: hour["day"].intValue)
                        hours.append(hour)
                    }
                    
                    place?.setHours(hours: hours)
                }
                place?.set_is_open(is_open: json["hours"][0]["is_open_now"].boolValue)
            }
        }   
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tab = segue.destination as! UITabBarController
        let mapVC = tab.viewControllers?[0] as! MapViewController
        
//        if self.messageCount == 0{
//            mapVC.navigationView.messagesButton.badgeString = ""
//        }
//        else if self.messageCount < 10{
//            mapVC.navigationView.messagesButton.badgeString = "\(self.messageCount)"
//        }
//        else{
//            mapVC.navigationView.messagesButton.badgeString = "9+"
//        }
//        
//        if self.notificationCount == 0{
//            mapVC.navigationView.notificationsButton.badgeString = ""
//        }
//        else if self.notificationCount < 10{
//            mapVC.navigationView.notificationsButton.badgeString = "\(self.notificationCount)"
//        }
        
//        else{
//            mapVC.navigationView.notificationsButton.badgeString = "9+"
//        }
        
        mapVC.notificationCount = self.notificationCount
        mapVC.messageCount = self.messageCount
        
        DataCache.instance.write(object: self.events as NSCoding, forKey: "events")
        DataCache.instance.write(object: self.places as NSCoding, forKey: "places")
        DataCache.instance.write(object: self.pins as NSCoding, forKey: "pins")
        DataCache.instance.write(object: self.followingPlaces as NSCoding, forKey: "following_places")
        DataCache.instance.write(object: self.notifications as NSCoding, forKey: "notifications")
        
    }
    
    func moveToMap(){
//        if self.dataCount == 3{
            self.performSegue(withIdentifier: "loaded", sender: nil)
//        }
    }
    
    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destinationViewController.
         Pass the selected object to the new view controller.
    }
    */

}
