//
//  MapViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import FirebaseDatabase
import Alamofire
import SwiftyJSON
import PopupDialog
import FirebaseMessaging
import SDWebImage
import MessageUI
import ChameleonFramework
import SCLAlertView
import FirebaseStorage
import Crashlytics
import GeoFire

protocol showMarkerDelegate{
    func showPinMarker(pin: pinData)
    func showPlaceMarker(place: Place)
    func showEventMarker(event: Event)
}

class MapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, NavigationInteraction,GMUClusterManagerDelegate, GMUClusterRendererDelegate, switchPinTabDelegate, UIPopoverPresentationControllerDelegate, showMarkerDelegate{
    
    @IBOutlet weak var settingGearButton: UIButton!
    @IBOutlet weak var mapViewSettings: UIView!
    @IBOutlet weak var followYourFriendsView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var usernameInputView: UIView!
    
    @IBOutlet weak var popupArrowImage: UIImageView!
    var createdEvent: Event?
    
    private var clusterManager: GMUClusterManager!
    @IBOutlet weak var photoInputView: UIView!

    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var events = [Event]()
    var places = [Place]()
    var placeMapping = [String: Place]()
    var hasCustomProfileImage = false
    
    var locationFromPlaceDetails = ""
    
    var willShowEvent = false
    var showEvent: Event? = nil
    var willShowPin = false
    var showPin: pinData? = nil
    var willShowPlace = false
    var showPlace: Place? = nil
    
    var pins = [pinData]()
    var userLocation: GMSMarker? = nil
    var showTutorial = false
    
    var exploreTab: InvitePeopleViewController? = nil
    var searchEventsTab: SearchEventsViewController? = nil
    var createEventPopover: CreateEventOnMapViewController? = nil
    var notifs = [FocusNotification]()
    var invites = [FocusNotification]()
    var feeds = [FocusNotification]()
    
    var eventPlaceMarker: GMSMarker? = nil
    var viewingPlace: Place? = nil
    var viewingEvent: Event? = nil
    
    var followingPlacesMarker = [GMSMarker]()
    var allPlacesMarker = [GMSMarker]()
    
    @IBOutlet weak var navigationView: MapNavigationView!
    
    @IBOutlet weak var invitePopupView: UIView!
    @IBOutlet weak var invitePopupViewBottomConstraint: NSLayoutConstraint!
    var showInvitePopupView = false
    let screenSize = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    
    var popUpScreen: MapPopUpScreenView!
    var placePins = [String:GMSMarker]()
    var lastPins = [GMSMarker]()
    var friends = [FollowNewUser]()
    
    func hideFollowFriendPopup(){
        self.followYourFriendsView.isHidden = true
        self.followYourFriendsView.sendSubview(toBack: self.followYourFriendsView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.invitePopupView.layer.cornerRadius = 10.0
        
        hideFollowFriendPopup()
        Share.getMatchingUsers(gotUsers: {users in
            if users.count > 0{
                self.friends = users
            }
        })
        
        self.view.backgroundColor = Constants.color.navy
        popUpScreen = MapPopUpScreenView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: popUpView.frame.width))
        popUpScreen.parentVC = self
        self.popUpView.addSubview(popUpScreen)
        self.mapViewSettings.layer.cornerRadius = 10.0
        
        if AuthApi.getUserImage() != nil && (AuthApi.getUserImage()?.characters.count)! > 0{
            
            SDWebImageManager.shared().downloadImage(with: URL(string: AuthApi.getUserImage()!), options: .continueInBackground, progress: {
                (receivedSize :Int, ExpectedSize :Int) in
                
            }, completed: {
                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                
            })
            
        }
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: {snapshot in
            if let info = snapshot.value as? [String:Any]{
                if let interests = info["interests"] as? String{
                    AuthApi.set(interests: interests)
                }
            }
        })
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        mapView.delegate = self
        navigationView.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        if AuthApi.getYelpToken() == nil || AuthApi.getYelpToken()?.characters.count == 0{
            getYelpToken(completion: { token in
                AuthApi.set(yelpAccessToken: token)
            })
        }
        
        if self.currentLocation == nil{
            self.currentLocation = AuthApi.getLocation()
        }
        
        if let last_pos = AuthApi.getLocation(){
            
            if !willShowEvent && !willShowPin && !willShowPlace{
                let camera = GMSCameraPosition.camera(withLatitude: last_pos.coordinate.latitude,
                                                      longitude: last_pos.coordinate.longitude,
                                                      zoom: 13)
                
                if mapView.isHidden {
                    mapView.isHidden = false
                    mapView.camera = camera
                } else {
                    mapView.animate(to: camera)
                }
            }
        }
        
        
        
        // Set up the cluster manager with default icon generator and renderer.
//        let iconGenerator = GMUDefaultClusterIconGenerator()
//        
//        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        
//        let renderer = CustomClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
//        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        
        let DF = DateFormatter()
        DF.dateFormat = "MMM d, h:mm a"
        
        let timeDF = DateFormatter()
        timeDF.dateFormat = "h:mm a"
        
        Constants.DB.event.keepSynced(true)
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).keepSynced(true)
        
        Constants.DB.event.observe(DataEventType.childAdded, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            let info = events// as? [String:Any]
//            for (id, event) in events{
            
            if let event = Event.toEvent(info: info){
                if let attending = info["attendingList"] as? [String:Any]{
                    event.setAttendessCount(count: attending.count)
                }
                
                if let end = timeDF.date(from: event.endTime){
                    let start = DF.date(from: event.date!)!
                    if start < Date() && end > Date() && !event.privateEvent{
                        let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                        let marker = GMSMarker(position: position)
                        marker.icon = UIImage(named: "Event")
                        marker.title = event.title
                        marker.map = self.mapView
                        marker.accessibilityLabel = "event_\(self.events.count)"
                        
                        self.events.append(event)
                    }
                }
                
                else if DF.date(from: event.date!)! > Date() && !event.privateEvent{
                    if Calendar.current.dateComponents([.day], from: DF.date(from: event.date!)!, to: Date()).day ?? 0 <= 7{
                        let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                        let marker = GMSMarker(position: position)
                        marker.icon = UIImage(named: "Event")
                        marker.title = event.title
                        marker.map = self.mapView
                        marker.accessibilityLabel = "event_\(self.events.count)"
                        
                        self.events.append(event)
                    }
                    if !(self.exploreTab?.attendingEvent.contains(event))!{
                        self.exploreTab?.attendingEvent.append(event)
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
                for event in events{
                    if !(self.exploreTab?.events.contains(event))!{
                        self.exploreTab?.events.append(event)
                    }
                }
                
            })
        }
        
        self.exploreTab = self.tabBarController?.viewControllers?[3] as? InvitePeopleViewController
        self.searchEventsTab = self.tabBarController?.viewControllers?[4] as? SearchEventsViewController
        
        
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!,
            NSForegroundColorAttributeName : UIColor(hexString: "7ac901")
            ], for: .selected)

        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!,
            NSForegroundColorAttributeName : UIColor.white
            ], for: .normal)
        
        self.invitePopupView.isHidden = true
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.settingGearButton.isHidden = false
        self.mapViewSettings.isHidden = true
        
        Answers.logCustomEvent(withName: "Screen",
                                       customAttributes: [
                                        "Name": "Map View"
            ])
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).keepSynced(true)
        Constants.DB.pins.keepSynced(true)
        
        navigationView.messagesButton.badgeString = ""
        getUnreadCount(count: {number in
            if number > 0{
                self.navigationView.messagesButton.badgeString = "\(number)"
            }
            else{
                self.navigationView.messagesButton.badgeString = ""
            }
            
        })
        self.searchEventsTab?.feeds.removeAll()
        
        navigationView.notificationsButton.badgeString = ""
        var not_count = 0
        var count_received = 0
        var read_notifications = AuthApi.getUnreadNotifications()
        
        let now = Date()
        let six_am = now.dateAt(hours: 6, minutes: 0)
        let six_pm = now.dateAt(hours: 18, minutes: 0)
        
        if now > six_pm &&
            now < six_am{
            
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "night_style", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        else{
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "day_style", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        
        if AuthApi.getYelpToken() == nil || AuthApi.getYelpToken()?.characters.count == 0{
            getYelpToken(completion: { token in
                AuthApi.set(yelpAccessToken: token)
                
                not_count = 0
                NotificationUtil.getNotificationCount(gotNotification: {notif in
                    
                    self.notifs.append(contentsOf: Array(Set<FocusNotification>(notif)))
                    
                    count_received += 1
                    if count_received == 5 + 1{
                        not_count += Array(Set<FocusNotification>(self.notifs)).count
                        
                        not_count -= read_notifications
                        if not_count > 0{
                            if not_count > 9{
                                self.navigationView.notificationsButton.badgeString = "9+"
                            }
                            else{
                                self.navigationView.notificationsButton.badgeString = "\(not_count)"
                            }
                        }
                        else{
                            self.navigationView.notificationsButton.badgeString = ""
                        }
                        count_received = 0
                    }
                }, gotInvites: {invites in
                    self.invites.append(contentsOf: Array(Set<FocusNotification>(invites)))
                    
                    count_received += 1
                    if count_received == 5 + 1{
                        not_count += Array(Set<FocusNotification>(self.notifs)).count
                        
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
                        if not_count > 0{
                            if not_count > 9{
                                self.navigationView.notificationsButton.badgeString = "9+"
                            }
                            else{
                                self.navigationView.notificationsButton.badgeString = "\(not_count)"
                            }
                        }
                        else{
                            self.navigationView.notificationsButton.badgeString = ""
                        }
                        count_received = 0
                    }
                } , gotFeed: {feed in
                    self.searchEventsTab?.feeds.append(contentsOf: Array(Set<FocusNotification>(feed)))
                    
                    if count_received == 5 + 1{
                        not_count += Array(Set<FocusNotification>(self.notifs)).count
                        
                        not_count -= read_notifications
                        if not_count > 0{
                            if not_count > 9{
                                self.navigationView.notificationsButton.badgeString = "9+"
                            }
                            else{
                                self.navigationView.notificationsButton.badgeString = "\(not_count)"
                            }
                        }
                        else{
                            self.navigationView.notificationsButton.badgeString = ""
                        }
                        count_received = 0
                    }
                })

            })
        }
        else{
            not_count = 0
            NotificationUtil.getNotificationCount(gotNotification: {notif in
                self.notifs.append(contentsOf: notif)
                
                count_received += 1
                if count_received == 5 + 1{
                    not_count += Array(Set<FocusNotification>(self.notifs)).count
                    
                    for invite in (self.invites as? [FocusNotification])!{
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
                    if not_count > 0{
                        if not_count > 9{
                            self.navigationView.notificationsButton.badgeString = "9+"
                        }
                        else{
                            self.navigationView.notificationsButton.badgeString = "\(not_count)"
                        }
                    }
                    else{
                        self.navigationView.notificationsButton.badgeString = ""
                    }
                    count_received = 0
                }
            }, gotInvites: {invite in
                
                self.invites.append(contentsOf: invite)
                count_received += 1
                if count_received == 5 + 1{
                    not_count += Array(Set<FocusNotification>(self.notifs)).count
                    
                    for invite in (self.invites as? [FocusNotification])!{
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
                    if not_count > 0{
                        if not_count > 9{
                            self.navigationView.notificationsButton.badgeString = "9+"
                        }
                        else{
                            self.navigationView.notificationsButton.badgeString = "\(not_count)"
                        }
                    }
                    else{
                        self.navigationView.notificationsButton.badgeString = ""
                    }
                    count_received = 0
                }
                
            } , gotFeed: {feed in
                self.searchEventsTab?.feeds.append(contentsOf: feed)
                
                if count_received == 5 + 1{
                    not_count += Array(Set<FocusNotification>(self.notifs)).count
                    
                    not_count -= read_notifications
                    if not_count > 0{
                        if not_count > 9{
                            self.navigationView.notificationsButton.badgeString = "9+"
                        }
                        else{
                            self.navigationView.notificationsButton.badgeString = "\(not_count)"
                        }
                    }
                    else{
                        self.navigationView.notificationsButton.badgeString = ""
                    }
                    count_received = 0
                }
            })
        }
        
        saveUserInfo()
        
        if AuthApi.getLocation() != nil{
            showEvents()    
        }
        
        
        let token = Messaging.messaging().fcmToken
        Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/token").setValue(token)
        AuthApi.set(FCMToken: token)
        
        if AuthApi.isNotificationAvailable(){
//            navigationView.notificationsButton.set
        }
        if willShowEvent || willShowPin || willShowPlace || AuthApi.showPin(){
            
            var camera: GMSCameraPosition? = nil
            
            if let pin = self.showPin, willShowPin{
                
                let position = CLLocationCoordinate2D(latitude: pin.coordinates.latitude, longitude: pin.coordinates.longitude)
                camera = GMSCameraPosition.camera(withLatitude: pin.coordinates.latitude,
                                         longitude: pin.coordinates.longitude,
                                         zoom: 13)
                self.eventPlaceMarker = GMSMarker(position: position)
                self.eventPlaceMarker?.icon = #imageLiteral(resourceName: "pin")
                self.eventPlaceMarker?.title = pin.pinMessage
                self.eventPlaceMarker?.map = self.mapView

                eventPlaceMarker?.accessibilityLabel = "pin_\(self.pins.count)"
                
                self.pins.append(showPin!)
                
                tapPin(pin: self.showPin!)
            }
            else if willShowPlace{
                let place = self.showPlace!
                
                let position = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                camera = GMSCameraPosition.camera(withLatitude: place.latitude,
                                                  longitude: place.longitude,
                                                  zoom: 13)
                self.eventPlaceMarker = GMSMarker(position: position)
                self.eventPlaceMarker?.icon = #imageLiteral(resourceName: "place_icon")
                self.eventPlaceMarker?.title = place.name
                self.eventPlaceMarker?.map = self.mapView
                
                eventPlaceMarker?.accessibilityLabel = "place_\(self.places.count)"
                
                self.places.append(place)
                
                tapPlace(place: place, marker: self.eventPlaceMarker!)
            }
            else if willShowEvent{
                let event = self.showEvent
                
                let position = CLLocationCoordinate2D(latitude: Double(event!.latitude!)!, longitude: Double(event!.longitude!)!)
                camera = GMSCameraPosition.camera(withLatitude: Double(event!.latitude!)!,
                                                  longitude: Double((event?.longitude!)!)!,
                                                  zoom: 13)
                self.eventPlaceMarker = GMSMarker(position: position)
                self.eventPlaceMarker?.icon = #imageLiteral(resourceName: "Event")
                self.eventPlaceMarker?.title = event?.title
                self.eventPlaceMarker?.map = self.mapView
                
                eventPlaceMarker?.accessibilityLabel = "event_\(self.events.count)"
                
                self.events.append(event!)
                
                tapEvent(event: event!)
            }

            
            if let camera = camera{
                if mapView.isHidden {
                    mapView.isHidden = false
                    mapView.camera = camera
                } else {
                    mapView.animate(to: camera)
                }
            }
            else{
                camera = GMSCameraPosition.camera(withLatitude: AuthApi.getLocation()!.coordinate.latitude,
                                                  longitude: AuthApi.getLocation()!.coordinate.longitude,
                                                  zoom: 13)
                
                if mapView.isHidden {
                    mapView.isHidden = false
                    mapView.camera = camera!
                } else {
                    mapView.animate(to: camera!)
                }

            }
            
            currentLocation = AuthApi.getLocation()
        }
        
        showPins(showAll: true, interests: "")
        
        if let token = AuthApi.getYelpToken(){
        }
        else{
            getYelpToken(completion: {token in
                AuthApi.set(yelpAccessToken: token)
            })
        }
        
        if showTutorial{
            self.showPopup()
        }
        
        self.mapViewSettings.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.invites.removeAll()
        self.notifs.removeAll()
        
        willShowPin = false
        willShowPlace = false
        willShowEvent = false
        popUpView.isHidden = true
        eventPlaceMarker?.map = nil
        eventPlaceMarker = nil
        
        if self.eventPlaceMarker != nil{
            eventPlaceMarker?.map = nil
            
            if let place = viewingPlace{
                if let index = places.index(of: place){
                    places.remove(at: index)
                }
            }
            if let event = viewingEvent{
                if let index = events.index(of: event){
                    events.remove(at: index)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if showInvitePopupView {
            self.invitePopupView.isHidden = false
            UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.invitePopupView.center.y -= (self.invitePopupView.frame.size.height + (self.tabBarController?.tabBar.frame.height)!)
                self.invitePopupViewBottomConstraint.constant += (self.invitePopupView.frame.size.height + (self.tabBarController?.tabBar.frame.height)!)
            }, completion: { animate in
                UIView.animate(withDuration: 1.5, delay: 3.0, options: .curveEaseInOut, animations: {
                    self.invitePopupView.center.y += (self.invitePopupView.frame.size.height + (self.tabBarController?.tabBar.frame.height)!)
                    self.invitePopupViewBottomConstraint.constant -= (
                        self.invitePopupView.frame.size.height + (self.tabBarController?.tabBar.frame.height)!)
                }, completion: nil)
            })
            self.showInvitePopupView = false
        }
        
        Constants.DB.user_mapping.keepSynced(true)
        
        Share.getFacebookFriends(completion: {friends in
        
        })
        
        if AuthApi.getUserName()?.characters.count == 0 || AuthApi.getUserName() == nil{
            print("username is nil")
            
            let usernameView = UsernameInputView(frame: CGRect(x:self.usernameInputView.frame.origin.x, y:self.usernameInputView.frame.origin.y, width:self.usernameInputView.frame.size.width, height: self.usernameInputView.frame.size.height))
            
            self.usernameInputView = usernameView
            self.view.addSubview(usernameView)

            
            usernameView.completion = { (username) in
                print(username)
                
                
                
                Constants.DB.user_mapping.observeSingleEvent(of: .value, with: {snapshot in
                    let value = snapshot.value as? String
                    if value != nil {
                        SCLAlertView().showCustom("Oops!", subTitle: "That username is already taken.", color: UIColor.orange, icon: #imageLiteral(resourceName: "error"))
                    }
                    else{
                        Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/username").setValue(username)
                        Constants.DB.user_mapping.child(username).setValue("")
                        Constants.DB.user_mapping.child(username).setValue(AuthApi.getUserEmail())
                        AuthApi.set(username: username)
                        UIView.animate(withDuration: 0.4, animations: {
                            self.usernameInputView.alpha = 0
                        }, completion: { compl in
                            self.usernameInputView.isHidden = true
                            self.usernameInputView.sendSubview(toBack: self.mapView)
                        })
                        print("Text value: \(username)")
                        
                        if AuthApi.getUserImage() == nil || AuthApi.getUserImage()?.characters.count == 0{
                            let photoViewInput = PhotoInputView(frame: CGRect(x: self.photoInputView.frame.origin.x, y:self.photoInputView.frame.origin.y, width: self.photoInputView.frame.size.width, height: self.photoInputView.frame.size.height))
                            
                            photoViewInput.cameraRollButton.addTarget(self, action: #selector(MapViewController.showCameraRoll), for: UIControlEvents.touchUpInside)
                            
                            
                            photoViewInput.takePhotoButton.addTarget(self, action: #selector(MapViewController.showCamera), for: UIControlEvents.touchUpInside)
                            
                            
                            self.view.addSubview(photoViewInput)
                        }
                        
                        //self.photoView.isHidden = false
                    }
                })
            }
            usernameView.error = { (error) in
                
                SCLAlertView().showError("Error", subTitle: "Please add a username so friends can find you.")
                
            }
        }
        else if AuthApi.getUserImage() == nil || AuthApi.getUserImage()?.characters.count == 0 {
            let photoViewInput = PhotoInputView(frame: CGRect(x: self.photoInputView.frame.origin.x, y:self.photoInputView.frame.origin.y, width: self.photoInputView.frame.size.width, height: self.photoInputView.frame.size.height))
            
            photoViewInput.cameraRollButton.addTarget(self, action: #selector(MapViewController.showCameraRoll), for: UIControlEvents.touchUpInside)
            
            
            photoViewInput.takePhotoButton.addTarget(self, action: #selector(MapViewController.showCamera), for: UIControlEvents.touchUpInside)
            
            
            self.view.addSubview(photoViewInput)
        }
        else if AuthApi.isNewUser(){
            self.showPopup()
        }
    }
    
    func showCameraRoll() {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        self.present(photoPicker, animated: true, completion: {
            self.showPopup()
        })
    }
    
    func showCamera() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.delegate = self
            picker.modalPresentationStyle = .fullScreen
            self.present(picker,animated: true,completion: {
                self.showPopup()
            })
        } else {
            self.noCamera()
        }
    }
    
    func noCamera() {
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if self.mapViewSettings.isHidden == true{
            self.settingGearButton.isHidden = false
        }else{
            self.settingGearButton.isHidden = true
        }
        
        if self.settingGearButton.isHidden && self.popUpView.isHidden && (self.mapViewSettings.isHidden == false){
            self.mapViewSettings.isHidden = true
            self.settingGearButton.isHidden = false
        }
        
        popUpView.isHidden = true
        
        if let username = usernameInputView as? UsernameInputView{
            username.usernameInputField.resignFirstResponder()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.settingGearButton.isHidden = true
    
        let accessibilityLabel = marker.accessibilityLabel
        marker.tracksInfoWindowChanges = true
        
        let parts = accessibilityLabel?.components(separatedBy: "_")
        if parts?[0] == "event"{
            let index: Int! = Int(parts![1])
            let event = self.events[index-1]
            
            tapEvent(event: event)
            return true
        }
        else if parts?[0] == "place"{
            let index:Int! = Int(parts![1])
            let place = self.places[index]
            
            tapPlace(place: place, marker: marker)
            return true
        }
        else if parts?[0] == "pin"{
            let index:Int! = Int(parts![1])
            let pin = self.pins[index]
            
            tapPin(pin: pin)
            return true
        }
        
        return true

        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        let lat: CLLocationDegrees = mapView.camera.target.latitude
        let long: CLLocationDegrees = mapView.camera.target.longitude
        
        
        let currentLocation =  CLLocation(latitude: lat, longitude: long)

        
        if let token = AuthApi.getYelpToken(){
            self.fetchPlaces(around: currentLocation, token: token)
        }
        else{
            getYelpToken(completion: {(token) in
                self.fetchPlaces(around: currentLocation, token: token)
            })
        }
        
        if AuthApi.getEventBriteToken() != nil{
            getEvents(around: currentLocation, completion: { events in
                for event in events{
                    let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                    let marker = GMSMarker(position: position)
                    marker.icon = UIImage(named: "Event")
                    marker.title = event.title
                    marker.map = self.mapView
                    marker.accessibilityLabel = "event_\(self.events.count)"
                    self.events.append(event)
                }
            })
        }
    }
    
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("NotDetermined")
        
        
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager.startUpdatingLocation()
        }
    }
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: 13)
        
        AuthApi.set(location: location)
        
        let current = changeTimeZone(of: Date(), from: TimeZone(abbreviation: "GMT")!, to: TimeZone.current)
        
        let now = Date()
        let six_am = now.dateAt(hours: 6, minutes: 0)
        let six_pm = now.dateAt(hours: 18, minutes: 0)
        
        
        if now > six_pm &&
            now < six_am{
            
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "night_style", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        else{
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "day_style", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        
        self.currentLocation = location
//        self.searchPlacesTab?.location = location
        
        if let token = AuthApi.getYelpToken(){
            self.fetchPlaces(around: self.currentLocation!, token: token)
        }
        else{
            getYelpToken(completion: {(token) in
                self.fetchPlaces(around: self.currentLocation!, token: token)
            })
        }
        
        if !willShowEvent && !willShowPin && !willShowPlace{
            mapView.settings.myLocationButton = true

            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        }
        

    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        let status = CLLocationManager.authorizationStatus()
        
        print("The status of autjorization is \(status.rawValue)")
    
        if (!(status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways)) {
            let alert = UIAlertController(title: "Location Authorization", message:"Please authorize use of your location in settings" , preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Go to settings", style: .default) { _ in
                print("J'ouvre les settings")
                UIApplication.shared.open(URL(string:"App-Prefs:root=Privacy&path=LOCATION")!, completionHandler: nil)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude)!,
                                              longitude: (currentLocation?.coordinate.longitude)!,
                                              zoom: 13)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        willShowPin = false
        willShowEvent = false
        willShowPlace = false
        AuthApi.setShowPin(show: false)
        return true
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func messagesClicked() {
        
        let VC:UIViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UINavigationController
        
        dropfromTop(view: self.view)
        
        self.present(VC, animated:true, completion:nil)
    }
    
    func notificationsClicked() {
        let storyboard = UIStoryboard(name: "Notif_Invite_Feed", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotifViewController") as! NotificationFeedViewController
        vc.nofArray = self.notifs + self.invites
        
        dropfromTop(view: self.view)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func invitationClicked()  {
        // show invitation screen
        
        let vc = InvitationsViewController(nibName: "InvitationsViewController", bundle: nil)
        vc.invArray = self.invites
        dropfromTop(view: self.view)
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func fetchPlaces(around location: CLLocation, token: String){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if let placeData = value{
                for (_,place) in placeData
                {
                    let place_id = (place as? [String:Any])?["placeID"]
                    getYelpByID(ID: place_id as! String, completion: {place in
                        
                        if !self.places.contains(place){
                            
                            
                            let position = CLLocationCoordinate2D(latitude: Double(place.latitude), longitude: Double(place.longitude))
                            let marker = GMSMarker(position: position)
                            marker.icon = UIImage(named: "place_icon")
                            marker.title = place.name
                            marker.map = self.mapView
                            marker.isTappable = true
                            marker.accessibilityLabel = "place_\(self.places.count)"
                            if let earlier = self.placePins[place.id]{
                                earlier.map = nil
                            }
                            
                            self.followingPlacesMarker.append(marker)
                            self.placePins[place.id] = marker
                            
                            self.placeMapping[place.id] = place
                            self.getPlaceHours(id: place.id)
                            self.places.append(place)
                            if !(self.exploreTab?.followingPlaces.contains(place))!{
                                self.exploreTab?.followingPlaces.append(place)
                            }
                            print("places count - \(self.places.count)")
                        }
                    })
                    
                }
            }
        })

        for interest in getYelpCategories().components(separatedBy: ","){
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
                        let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                        categories.append(category)
                    }
                    
                    let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
                    
//                    if !(self.searchPlacesTab?.places.contains(place))!{
                    
//                        let position = CLLocationCoordinate2D(latitude: Double(place.latitude), longitude: Double(place.longitude))
//                        let marker = GMSMarker(position: position)
//                        marker.icon = UIImage(named: "place_icon")
//                        marker.title = place.name
//                        marker.map = self.mapView
//                        marker.isTappable = true
//                        marker.accessibilityLabel = "place_\(self.places.count)"
                        
                        //                    let item = MapCluster(position: position, name: place.name, icon: UIImage(named: "place_icon")!, id: String(self.places.count), type: "place")
                        //                    self.clusterManager.add(item)
//                        self.places.append(place)
//                        self.placeMapping[place.id] = place
//                        self.getPlaceHours(id: place.id)
//                        
//                        self.searchPlacesTab?.places.append(place)
                    
//                    }
                }
                //            self.clusterManager.cluster()
            }
        }
    }
    
    func showPins(showAll: Bool, interests: String){
        if showAll{
            fetchAllPins(gotPin: {pins in
                
                // remove any old pins
                for marker in self.lastPins{
                    marker.map = nil
                }
                
                for pin in pins{
                    let position = CLLocationCoordinate2D(latitude: Double(pin.coordinates.latitude), longitude: Double(pin.coordinates.longitude))
                    let marker = GMSMarker(position: position)
                    marker.title = pin.pinMessage
                    marker.map = self.mapView
                    let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
                    image.image = UIImage(named: "pin")
                    image.contentMode = .scaleAspectFit
                    marker.iconView = image
                    marker.accessibilityLabel = "pin_\(self.pins.count)"
                    
                    self.lastPins.append(marker)
                    self.pins.append(pin)
                }
            })
            
        }
        else{
            // remove any old pins
            for marker in self.lastPins{
                marker.map = nil
            }
            
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").observeSingleEvent(of: .value, with: {snapshot in
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
                                                    
                                                    let position = CLLocationCoordinate2D(latitude: Double(pin.coordinates.latitude), longitude: Double(pin.coordinates.longitude))
                                                    let marker = GMSMarker(position: position)
                                                    marker.title = pin.pinMessage
                                                    marker.map = self.mapView
                                                    let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
                                                    image.image = UIImage(named: "pin")
                                                    image.contentMode = .scaleAspectFit
                                                    marker.iconView = image
                                                    marker.accessibilityLabel = "pin_\(self.pins.count)"
                                                    
                                                    self.lastPins.append(marker)
                                                    self.pins.append(pin)
                                                }
                                            }
                                        }
                                        
                                    })
                                    
                                }
                            }
                        })
                    }
                }
                
            })
        }
    }
    func showPlaces(showAll: Bool, interests: String){
        if showAll{
            // get all places on map of selected interest
            for marker in self.followingPlacesMarker{
                marker.map = nil
            }
            
            for interest in interests.components(separatedBy: ","){
                let yelpInterst = Constants.interests.yelpMapping[interest]
            
                yelpSearch(interest: yelpInterst!, location: currentLocation!, gotPlaces: {nearByPlaces in
                    for place in nearByPlaces{
                        let position = CLLocationCoordinate2D(latitude: Double(place.latitude), longitude: Double(place.longitude))
                        let marker = GMSMarker(position: position)
                        marker.icon = UIImage(named: "place_icon")
                        marker.title = place.name
                        marker.map = self.mapView
                        marker.isTappable = true
                        marker.accessibilityLabel = "place_\(self.places.count)"
                        if let earlier = self.placePins[place.id]{
                            earlier.map = nil
                        }
                        
                        self.allPlacesMarker.append(marker)
                        self.placePins[place.id] = marker
                        
                        self.placeMapping[place.id] = place
                        self.getPlaceHours(id: place.id)
                        self.places.append(place)
                        if !(self.exploreTab?.followingPlaces.contains(place))!{
                            self.exploreTab?.followingPlaces.append(place)
                        }
                    }
                })
            }
        }
        else{
            // pending remove all marker pins
            for marker in self.allPlacesMarker{
                marker.map = nil
            }
            
            if let token = AuthApi.getYelpToken(){
                self.fetchPlaces(around: currentLocation!, token: token)
            }
            else{
                getYelpToken(completion: {(token) in
                    self.fetchPlaces(around:
                        self.currentLocation!, token: token)
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
    
    
    func showPopup(){
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        
        overlayAppearance.color       = UIColor.black
        overlayAppearance.blurRadius  = 20
        overlayAppearance.blurEnabled = false
        overlayAppearance.liveBlur    = false
        overlayAppearance.opacity     = 0.85
        
        var dialogAppearance = PopupDialogDefaultView.appearance()
        
        dialogAppearance.backgroundColor      = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        dialogAppearance.titleFont            = UIFont(name: "Avenir-Book", size: 15)!
        dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont(name: "Avenir-Book", size: 15)!
        dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        dialogAppearance.messageTextAlignment = .center
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:1.00)
        pcv.cornerRadius    = 10
        pcv.shadowEnabled   = true
        pcv.shadowColor     = UIColor.black
        
        // Create a custom view controller
        let onboardingVC = NewUserPopupViewController(nibName: "NewUserPopupViewController", bundle: nil)
        onboardingVC.arrowImage = self.popupArrowImage
        onboardingVC.delegate = self
//        onboardingVC.testImage = self.testImage
        
        // Create the dialog
        let popup = PopupDialog(viewController: onboardingVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: false)
        
        
        popup.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        AuthApi.setNewUser()
        Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/isNewUser").setValue(false)
        // Present dialog
        present(popup, animated: true, completion: nil)
    }
    
    func changeTab(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "home") as! UITabBarController
        vc.selectedIndex = 2
        self.present(vc, animated: true, completion: nil)

    }
    
    @IBAction func unwindToMapViewController(segue:UIStoryboardSegue) { }
    
    @IBAction func unwindToMapViewControllerFromPersonalUserProfilePlaceDetailsOrEventDetails(segue:UIStoryboardSegue) {
        let popController = self.createPopOver()
        self.tabBarController?.present(popController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToMapViewControllerFromPlaceDetails(segue: UIStoryboardSegue){
        let popController = self.createPopOver()
        self.tabBarController?.present(popController, animated: true, completion: { completed in
            popController.searchLocationTextField.text = self.locationFromPlaceDetails
        })
    }
    
    func createPopOver() -> CreateEventOnMapViewController{
        let tabBarItemWidth = Int((self.tabBarController?.tabBar.frame.size.width)!) / (self.tabBarController?.tabBar.items?.count)!
        let x = tabBarItemWidth * 2
        let newRect = CGRect(x: x, y: 0, width: tabBarItemWidth, height: Int((self.tabBarController?.tabBar.frame.size.height)!))
        
        let popController = UIStoryboard(name: "CreateEventOnMapViewController", bundle: nil).instantiateViewController(withIdentifier: "CreateEventOnMapViewController") as! CreateEventOnMapViewController

        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.preferredContentSize = CGSize(width: 345, height: 354)
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.tabBarController?.tabBar
        
        popController.popoverPresentationController?.sourceRect = newRect
        return popController
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func mapSettingsPressed(_ sender: Any) {
        self.settingGearButton.isHidden = true
        self.mapViewSettings.isHidden = false
    }
    
    func showEvents(){
        for interest in AuthApi.getInterests()!.components(separatedBy: ","){
            if let ticketmaster_interest = Constants.interests.ticketMasterMapping[interest.components(separatedBy: "-")[0]]{
                Event.getNearyByEvents(query: "", category: ticketmaster_interest, location: AuthApi.getLocation()!.coordinate, gotEvents: { events in
                    for event in events{
                        let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                        
                        let marker = GMSMarker(position: position)
                        marker.icon = #imageLiteral(resourceName: "Event")
                        marker.title = event.title
                        marker.map = self.mapView
                        
                        marker.accessibilityLabel = "event_\(self.events.count)"
                        
                        self.events.append(event)
                    }
                })
            }
            
        }
        
    }
}

extension MapViewController{
    func tapEvent(event: Event){
    
        popUpView.isHidden = false
        
        popUpScreen.object = event
        popUpScreen.type = "event"
        
        var timeString = ""
        var distance = ""
        var start = ""
        var ticketMasterDF = DateFormatter()
        ticketMasterDF.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if event.date?.range(of:",") != nil{
            let time = event.date?.components(separatedBy: ",")[1]
            start = time!
            
        }
        else if let time = event.date?.components(separatedBy: "T"), time.count > 1{
                let date = dateFormatter.date(from: time[1])
                dateFormatter.dateFormat = "h:mm a"
                
                start = dateFormatter.string(from: date!)
        }
        else{
            if let time = ticketMasterDF.date(from: event.date!){
                
                start = dateFormatter.string(from: time)
            }
            
            
        }
    
        let placeholderImage = UIImage(named: "empty_event")

        if let id = event.id{
            let reference = Constants.storage.event.child("\(id).jpg")
            
            
            reference.downloadURL(completion: { (url, error) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "Error happend")
                    return
                }
                
                self.popUpScreen.profileImage.sd_setImage(with: url, placeholderImage: placeholderImage)
                self.popUpScreen.profileImage.setShowActivityIndicator(true)
                self.popUpScreen.profileImage.setIndicatorStyle(.gray)
            })
            
        }
        else{
            popUpScreen.profileImage.sd_setImage(with: URL(string:(event.image_url)!), placeholderImage: placeholderImage)
            popUpScreen.profileImage.setShowActivityIndicator(true)
            popUpScreen.profileImage.setIndicatorStyle(.gray)
            
        }
        
        
        distance = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!))
        
        var interestText = ""
        if let category = event.category{
            interestText = category.components(separatedBy: ",")[0]
        }
        popUpScreen.loadEvent(name: event.title!, date: start, miles: distance, interest: interestText, address: (event.fullAddress?.components(separatedBy: ";;")[0])!, event: event)
        
    }
    
    func tapPlace(place: Place, marker: GMSMarker){

        popUpView.isHidden = false
        
        popUpScreen.object = place
        popUpScreen.type = "place"
        
        var name = ""
        var rating = ""
        var reviews = ""
        var distance = ""
        
        name = place.name
        rating = String(place.rating)
        popUpScreen.checkReviewsAmount(reviewsAmount: Double(place.rating))
        reviews = "(\(place.reviewCount) reviews)"
        let category = place.categories.map(){ $0.alias }
        
        var interestText = getInterest(yelpCategory: category[0])
        
        if interestText.characters.count == 0 {
            interestText = "N.A."
        }
        let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
            marker.tracksInfoWindowChanges = false
            self.popUpScreen.profileImage.setShowActivityIndicator(false)
            
        }
        
        let placeholderImage = UIImage(named: "empty_event")
        
        popUpScreen.profileImage.sd_setImage(with: URL(string:(place.image_url)), placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: block)
        popUpScreen.profileImage.setShowActivityIndicator(true)
        popUpScreen.profileImage.setIndicatorStyle(.gray)
        
        
        distance = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: CLLocation(latitude: Double(place.latitude), longitude: Double(place.longitude)))
        
        print(place.id)
        popUpScreen.loadPlace(name: name, rating: rating, reviews: reviews, miles: distance, interest: interestText, address: place.address[0], is_closed: place.is_closed, place: place)
    }
    
    func tapPin(pin: pinData){
        popUpView.isHidden = false
        
        popUpScreen.object = pin
        popUpScreen.type = "pin"
        
        var distance = ""
        let pinMessage = pin.pinMessage
        let interest = pin.focus
        let name = pin.username
        
        
        distance = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: CLLocation(latitude: Double(pin.coordinates.latitude), longitude: Double(pin.coordinates.longitude)))
        
        Constants.DB.user.child(pin.fromUID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let value = value
            {
                
                self.popUpScreen.loadPin(name: name, pin: pinMessage, distance: distance, focus: interest, address: pin.locationAddress.components(separatedBy: ";;")[0], time: pin.dateTimeStamp, username: (value["username"] as? String)!, userImage: (value["image_string"] as? String)!)
            }
        })
    }
}

extension MapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        
        // reducing the size of the image
        let reducedImage = chosenImage.resizeWithWidth(width: 750)
        let imageData = UIImagePNGRepresentation(reducedImage!)
        
        
        if let data = imageData{
            
            let imageRef = Constants.storage.user_profile.child("\(AuthApi.getFirebaseUid()!).jpg")
            
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = imageRef.putData(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                AuthApi.set(userImage: metadata.downloadURL()?.absoluteString)
                
            }
        }
//        self.photoInputView.isHidden = true
//        self.mapView.sendSubview(toBack: self.photoInputView)
        
        
        if self.friends.count > 0{
            let followYourFriendsSubView = FollowYourFriendsView(frame: CGRect(x: 0, y: 0, width: self.followYourFriendsView.frame.size.width, height: self.followYourFriendsView.frame.size.height))
            followYourFriendsSubView.users = self.friends
            followYourFriendsSubView.closeButton.addTarget(self, action: #selector(MapViewController.hideFollowFriendPopup), for: .touchUpInside)
            self.followYourFriendsView.addSubview(followYourFriendsSubView)
            self.followYourFriendsView.allCornersRounded(radius: 8.0)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("cancelled")
    }
    
    func showInvitePopup(){
        self.showInvitePopupView = true
        self.popUpView.isHidden = true
    }
    
    func showPinMarker(pin: pinData){
        willShowPin = true
        showPin = pin
    }
    
    func showPlaceMarker(place: Place){
        willShowPlace = true
        showPlace = place
    }
    
    func showEventMarker(event: Event){
        willShowEvent = true
        showEvent = event
    }
}
