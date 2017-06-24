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
import Solar
import PopupDialog
import FirebaseMessaging
import SDWebImage
import MessageUI
import ChameleonFramework
import SCLAlertView

class MapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, NavigationInteraction,GMUClusterManagerDelegate, GMUClusterRendererDelegate, switchPinTabDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var popupArrowImage: UIImageView!
    var createdEvent: Event?
    
    private var clusterManager: GMUClusterManager!

    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var events = [Event]()
    var places = [Place]()
    var placeMapping = [String: Place]()
    var hasCustomProfileImage = false
    var showEvent = false
    var pins = [pinData]()
    var userLocation: GMSMarker? = nil
    
    var searchPlacesTab: SearchPlacesViewController? = nil
    var searchEventsTab: SearchEventsViewController? = nil
    
    @IBOutlet weak var navigationView: MapNavigationView!
    
    @IBOutlet weak var webView: UIWebView!
    
    var popUpScreen: MapPopUpScreenView!
    
    var lastPins = [GMSMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        FirebaseDownstream.shared.getCurrentUser {[unowned self] (dictionnary) in
//            if dictionnary != nil {
//                if let image_str = dictionnary!["image_string"] as? String{
//                    if image_str.characters.count > 0{
//                        self.navigationView.userProfileButton.sd_setImage(with: URL(string: image_str), for: .normal)
//                        self.hasCustomProfileImage = true
//                        self.navigationView.userProfileButton.imageView?.roundedImage()
//                    }
//                }
//                
//                
//                
//            }
//            
//        }
        
//        UserDefaults.standard.set(nil, forKey: "eventBriteToken")
//        webView.isHidden = true
//        if AuthApi.getEventBriteToken() == nil{
//            let url = URL(string: "https://www.eventbrite.com/oauth/authorize?response_type=token&client_id=34IONXEGBQSXJGZXWO&client_secret=FU6FJALJ6DBE6RCVZY2Q7QE73PQIFJRDSPMIAWBUK6XIOY4M3Q")
//            let requestObj = URLRequest(url: url!)
//            webView.loadRequest(requestObj)
//            webView.delegate = self
//        }
        
        
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
                //self.fetchPlaces(around: self.currentLocation!, token: token)
            })
        }
        
        if self.currentLocation == nil{
            self.currentLocation = AuthApi.getLocation()
        }
        
        if let last_pos = AuthApi.getLocation(){
            
            let camera = GMSCameraPosition.camera(withLatitude: last_pos.coordinate.latitude,
                                                  longitude: last_pos.coordinate.longitude,
                                                  zoom: 15)
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        }
        
        
        
        // Set up the cluster manager with default icon generator and renderer.
//        let iconGenerator = GMUDefaultClusterIconGenerator()
//        
//        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        
//        let renderer = CustomClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
//        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        Constants.DB.event.observe(DataEventType.childAdded, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            let info = events as? [String:Any]
//            for (id, event) in events{
            
                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: snapshot.key, category: info?["interests"] as? String)
        
                if let attending = info?["attendingList"] as? [String:Any]{
                    event.setAttendessCount(count: attending.count)
                }
                
                let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                let marker = GMSMarker(position: position)
                marker.icon = UIImage(named: "Event")
                marker.title = event.title
                marker.map = self.mapView
                marker.accessibilityLabel = "event_\(self.events.count)"
                self.events.append(event)
                
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
        
        self.searchPlacesTab = self.tabBarController?.viewControllers?[3] as? SearchPlacesViewController
        self.searchEventsTab = self.tabBarController?.viewControllers?[4] as? SearchEventsViewController
        
        let token = Messaging.messaging().fcmToken
        
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!,
            NSForegroundColorAttributeName : UIColor(hexString: "7ac901")
            ], for: .selected)

        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!,
            NSForegroundColorAttributeName : UIColor.white
            ], for: .normal)
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).keepSynced(true)
        Constants.DB.pins.keepSynced(true)
        
        saveUserInfo()
        if AuthApi.isNotificationAvailable(){
//            navigationView.notificationsButton.set
        }
        if showEvent{
            
            let camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude)!,
                                                  longitude: (currentLocation?.coordinate.longitude)!,
                                                  zoom: 17)
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        }
        
        fetchPins()
        
        if let token = AuthApi.getYelpToken(){
//            fetchPlaces(token: token)
        }
        else{
            getYelpToken(completion: {token in
//                self.fetchPlaces(token: token)
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        print(popUpView.frame.size)
        popUpScreen = MapPopUpScreenView(frame: CGRect(x: 0, y: 0, width: popUpView.frame.width, height: popUpView.frame.width))
        popUpScreen.parentVC = self
        self.popUpView.addSubview(popUpScreen)
    }
    

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        popUpView.isHidden = true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        popUpView.isHidden = false
        
        let accessibilityLabel = marker.accessibilityLabel
        
        marker.tracksInfoWindowChanges = true
        
        let parts = accessibilityLabel?.components(separatedBy: "_")
        
        if parts?[0] == "event"{
            let index: Int! = Int(parts![1])
            let event = self.events[index]
            
            popUpScreen.object = event
            popUpScreen.type = "event"
            
            
            //let infoWindow = Bundle.main.loadNibNamed("MapPopUpScreenView", owner: self, options: nil)?[0] as! MapPopUpScreenView
            
            var timeString = ""
            let imageView = UIImageView()
            var distance = ""
            let interest = UILabel()
            
            var start = ""
            var end = ""
            if event.date?.range(of:",") != nil{
                let time = event.date?.components(separatedBy: ",")[1]
                start = time!
                
            }
            else{
                let time = event.date?.components(separatedBy: "T")[1]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                let date = dateFormatter.date(from: time!)
                
                dateFormatter.dateFormat = "h:mm a"
                
                start = dateFormatter.string(from: date!)
            }
            
            
            if event.endTime.characters.count > 0{
                let time = event.endTime.components(separatedBy: "T")[1]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                let date = dateFormatter.date(from: time)
                
                dateFormatter.dateFormat = "h:mm a"
                
                end = dateFormatter.string(from: date!)
                timeString = "\(start) - \(end)"
            }
            else{
                timeString = "\(start) onwards"
            }
            
            let placeholderImage = UIImage(named: "empty_event")
            
            if let id = event.id{
                let reference = Constants.storage.event.child("\(id).jpg")
                
                
                reference.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
                    
                    self.popUpScreen.backImage.sd_setImage(with: url, placeholderImage: placeholderImage)
                    self.popUpScreen.backImage.setShowActivityIndicator(true)
                    self.popUpScreen.backImage.setIndicatorStyle(.gray)
                    
                    
                })
                
            }
            else{
                popUpScreen.backImage.sd_setImage(with: URL(string:(event.image_url)!), placeholderImage: placeholderImage)
                popUpScreen.backImage.setShowActivityIndicator(true)
                popUpScreen.backImage.setIndicatorStyle(.gray)
                
            }
            
            
            distance = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!))
            
            
            if let category = event.category{
                let focus = category.components(separatedBy: ",")[0]
                interest.text =  "\(focus)"
                
                
                
                let primaryFocus = NSMutableAttributedString(string: interest.text!)
                primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(interest.text?.characters.count)! - 1,length:1))
                interest.attributedText = primaryFocus
            }
            else{
                interest.text = "None"
            }
            popUpScreen.loadEvent(name: event.title!, date: timeString, miles: distance, interest: interest, address: event.shortAddress!)
            
            return true
            
            
            
        }else if parts?[0] == "place"{
            
            let index:Int! = Int(parts![1])
            let place = self.places[index % self.places.count]
            
            popUpScreen.object = place
            popUpScreen.type = "place"
            
            var name = ""
            var rating = ""
            var reviews = ""
            var interest = UILabel()
            var imageView = UIImageView()
            var distance = ""
            
            //let infoWindow = Bundle.main.loadNibNamed("MapPopUpScreenView", owner: self, options: nil)?[0] as! MapPopUpScreenView
            name = place.name
            rating = String(place.rating)
            reviews = "(\(place.reviewCount) reviews)"
            let category = place.categories.map(){ $0.alias }
            
            let interestText = getInterest(yelpCategory: category[0])
            
            if interestText.characters.count > 0 {
                interest.text =  "\(interestText)"
                let primaryFocus = NSMutableAttributedString(string: interest.text!)
                primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(interest.text?.characters.count)! - 1,length:1))
                interest.attributedText = primaryFocus
            }
            else{
                interest.text = "N.A."
            }
            
            let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
                marker.tracksInfoWindowChanges = false
                self.popUpScreen.backImage.setShowActivityIndicator(false)
                
            }
            
            let placeholderImage = UIImage(named: "empty_event")
            
            popUpScreen.backImage.sd_setImage(with: URL(string:(place.image_url)), placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: block)
            popUpScreen.backImage.setShowActivityIndicator(true)
            popUpScreen.backImage.setIndicatorStyle(.gray)
            
            distance = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(place.latitude), longitude: Double(place.longitude)))
            
            popUpScreen.loadPlace(name: name, rating: rating, reviews: reviews, miles: distance, interest: interest, address: place.address.joined(separator: " "))
            return true
            
            
            
            
            
        }else if parts?[0] == "pin"
        {
            let index:Int! = Int(parts![1])
            let pin = self.pins[index]
            
            popUpScreen.object = pin
            popUpScreen.type = "pin"
            
            //let infoWindow = Bundle.main.loadNibNamed("MapPopUpScreenView", owner: self, options: nil)?[0] as! MapPopUpScreenView
            var distance = ""
            var pinMessage = pin.pinMessage
            var interest = pin.focus
            var name = ""
            
            
            distance = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(pin.coordinates.latitude), longitude: Double(pin.coordinates.longitude)))
            
            Constants.DB.user.child(pin.fromUID).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    name = value?["username"] as! String
                    self.popUpScreen.loadPin(name: name, pin: pinMessage, distance: distance, focus: interest)
                }
            })
        
        
            
            return true
        }
        
        return true

        
    }
    
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
//        
//        let accessibilityLabel = marker.accessibilityLabel
//        
//        marker.tracksInfoWindowChanges = true
//
//        let parts = accessibilityLabel?.components(separatedBy: "_")
//        
//        if parts?[0] == "event"{
//            let index: Int! = Int(parts![1])
//            let event = self.events[index]
//            
//            
//            let infoWindow = Bundle.main.loadNibNamed("MapPopUpScreenView", owner: self, options: nil)?[0] as! MapPopUpScreenView
//            
//            var timeString = ""
//            let imageView = UIImageView()
//            var distance = ""
//            let interest = UILabel()
//
//            var start = ""
//            var end = ""
//            if event.date?.range(of:",") != nil{
//                let time = event.date?.components(separatedBy: ",")[1]
//                start = time!
//                
//            }
//            else{
//                let time = event.date?.components(separatedBy: "T")[1]
//                
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "HH:mm:ss"
//                let date = dateFormatter.date(from: time!)
//                
//                dateFormatter.dateFormat = "h:mm a"
//                
//                start = dateFormatter.string(from: date!)
//            }
//            
//            
//            if event.endTime.characters.count > 0{
//                let time = event.endTime.components(separatedBy: "T")[1]
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "HH:mm:ss"
//                let date = dateFormatter.date(from: time)
//                
//                dateFormatter.dateFormat = "h:mm a"
//                
//                end = dateFormatter.string(from: date!)
//                timeString = "\(start) - \(end)"
//            }
//            else{
//                timeString = "\(start) onwards"
//            }
//            
//            let placeholderImage = UIImage(named: "empty_event")
//            
//            if let id = event.id{
//                let reference = Constants.storage.event.child("\(id).jpg")
//                
//                
//                reference.downloadURL(completion: { (url, error) in
//                    
//                    if error != nil {
//                        print(error?.localizedDescription)
//                        return
//                    }
//                    
//                    infoWindow.backImage.sd_setImage(with: url, placeholderImage: placeholderImage)
//                    infoWindow.backImage.setShowActivityIndicator(true)
//                    infoWindow.backImage.setIndicatorStyle(.gray)
//                
//                    
//                })
//                
//            }
//            else{
//                infoWindow.backImage.sd_setImage(with: URL(string:(event.image_url)!), placeholderImage: placeholderImage)
//                infoWindow.backImage.setShowActivityIndicator(true)
//                infoWindow.backImage.setIndicatorStyle(.gray)
//                
//            }
//            
//            
//            distance = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!))
//            
//            
//            if let category = event.category{
//                let focus = category.components(separatedBy: ",")[0]
//                interest.text =  "\(focus)"
//                
//                
//                
//                let primaryFocus = NSMutableAttributedString(string: interest.text!)
//                primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(interest.text?.characters.count)! - 1,length:1))
//                interest.attributedText = primaryFocus
//            }
//            else{
//                interest.text = "None"
//            }
//            infoWindow.loadEvent(name: event.title!, date: timeString, miles: distance, interest: interest)
//            
//            return infoWindow
//            
//
//            
//        }else if parts?[0] == "place"{
//        
//            let index:Int! = Int(parts![1])
//            let place = self.places[index % self.places.count]
//            
//            var name = ""
//            var rating = ""
//            var reviews = ""
//            var interest = UILabel()
//            var imageView = UIImageView()
//            var distance = ""
//
//            let infoWindow = Bundle.main.loadNibNamed("MapPopUpScreenView", owner: self, options: nil)?[0] as! MapPopUpScreenView
//            name = place.name
//            rating = String(place.rating)
//            reviews = "(\(place.reviewCount) reviews)"
//            let category = place.categories.map(){ $0.alias }
//
//
//            interest.text =  "\(getInterest(yelpCategory: category[0])) ●"
//            let primaryFocus = NSMutableAttributedString(string: interest.text!)
//            primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(interest.text?.characters.count)! - 1,length:1))
//            interest.attributedText = primaryFocus
//
//            let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
//                marker.tracksInfoWindowChanges = false
//                infoWindow.backImage.setShowActivityIndicator(false)
//
//            }
//
//            let placeholderImage = UIImage(named: "empty_event")
//
//            infoWindow.backImage.sd_setImage(with: URL(string:(place.image_url)), placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: block)
//            infoWindow.backImage.setShowActivityIndicator(true)
//            infoWindow.backImage.setIndicatorStyle(.gray)
//            
//            distance = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(place.latitude), longitude: Double(place.longitude)))
//            
//            infoWindow.loadPlace(name: name, rating: rating, reviews: reviews, miles: distance, interest: interest)
//                return infoWindow
//            
//            
//            
//            
//
//        }else
//        {
//            let index:Int! = Int(parts![1])
//            let pin = self.pins[index]
//            
//            let infoWindow = Bundle.main.loadNibNamed("MapPopUpScreenView", owner: self, options: nil)?[0] as! MapPopUpScreenView
//            var distance = ""
//            var pinMessage = pin.pinMessage
//            //var inte
//            //let location = pin.locationAddress
//            var name = ""
//            //var timeAgo = ""
//        
//            distance = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(pin.coordinates.latitude), longitude: Double(pin.coordinates.longitude)))
//            
//            Constants.DB.user.child(pin.fromUID).observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                if value != nil
//                {
//                    name = value?["username"] as! String
//                    infoWindow.loadPin(name: name, pin: pinMessage, distance: distance)
//                }
//            })
//
//            
//            return infoWindow
//        }
    
//        if parts?[0] == "event"{
//            let index:Int! = Int(parts![1])
//            let event = self.events[index]
//            let infoWindow = Bundle.main.loadNibNamed("MapEventInfoView", owner: self, options: nil)?[0] as! MapEventInfoView
//            infoWindow.name.text = event.title
//            
//            var start = ""
//            var end = ""
//            if event.date?.range(of:",") != nil{
//                let time = event.date?.components(separatedBy: ",")[1]
//            
//                
//                start = time!
//
//            }
//            else{
//                let time = event.date?.components(separatedBy: "T")[1]
//                
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "HH:mm:ss"
//                let date = dateFormatter.date(from: time!)
//                
//                dateFormatter.dateFormat = "h:mm a"
//                
//                start = dateFormatter.string(from: date!)
//            }
//            
//            
//            if event.endTime.characters.count > 0{
//                let time = event.endTime.components(separatedBy: "T")[1]
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "HH:mm:ss"
//                let date = dateFormatter.date(from: time)
//                
//                dateFormatter.dateFormat = "h:mm a"
//                
//                end = dateFormatter.string(from: date!)
//                infoWindow.time.text = "\(start) - \(end)"
//            }
//            else{
//                infoWindow.time.text = "\(start) onwards"
//            }
//            
//            let placeholderImage = UIImage(named: "empty_event")
//        
//            if let id = event.id{
//                let reference = Constants.storage.event.child("\(id).jpg")
//                
//                
//                reference.downloadURL(completion: { (url, error) in
//                    
//                    if error != nil {
//                        print(error?.localizedDescription)
//                        return
//                    }
//
//                    let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
//                        marker.tracksInfoWindowChanges = false
//                        infoWindow.image.setShowActivityIndicator(false)
//                        
//                    }
//                    
//                    
//                    infoWindow.image.sd_setImage(with: url, placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: block)
//                    infoWindow.image.setShowActivityIndicator(true)
//                    infoWindow.image.setIndicatorStyle(.gray)
//                    
//
//                })
//                
//            }
//            else{
//                let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
//                    marker.tracksInfoWindowChanges = false
//                    infoWindow.image.setShowActivityIndicator(false)
//                    
//                }
//                
//                infoWindow.image.sd_setImage(with: URL(string:(event.image_url)!), placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: block)
//                infoWindow.image.setShowActivityIndicator(true)
//                infoWindow.image.setIndicatorStyle(.gray)
//            }
//            
//            infoWindow.distance.text = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!))
//            
//            if let category = event.category{
//                let focus = category.components(separatedBy: ",")[0]
//                infoWindow.category.text =  "\(focus) ●"
//                
//                
//                
//                let primaryFocus = NSMutableAttributedString(string: infoWindow.category.text!)
//                primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(infoWindow.category.text?.characters.count)! - 1,length:1))
//                infoWindow.category.attributedText = primaryFocus
//            }
//            else{
//                infoWindow.category.text = "None"
//            }
//            return infoWindow
//        }
//        else{
//            let index:Int! = Int(parts![1])
//            let place = self.places[index % self.places.count]
//            
//            let infoWindow = Bundle.main.loadNibNamed("MapPinInfoView", owner: self, options: nil)?[0] as! MapPinInfoView
//            infoWindow.name.text = place.name
//            infoWindow.rating.text = String(place.rating)
//            infoWindow.reviews.text = "(\(place.reviewCount) reviews)"
//            let category = place.categories.map(){ $0.alias }
//
//            
//            infoWindow.category.text =  "\(getInterest(yelpCategory: category[0])) ●" 
//            let primaryFocus = NSMutableAttributedString(string: infoWindow.category.text!)
//            primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(infoWindow.category.text?.characters.count)! - 1,length:1))
//            infoWindow.category.attributedText = primaryFocus
//            
//            let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
//                marker.tracksInfoWindowChanges = false
//                infoWindow.image.setShowActivityIndicator(false)
//                
//            }
//            
//            let placeholderImage = UIImage(named: "empty_event")
//            
//            infoWindow.image.sd_setImage(with: URL(string:(place.image_url)), placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: block)
//            infoWindow.image.setShowActivityIndicator(true)
//            infoWindow.image.setIndicatorStyle(.gray)
//            
//            infoWindow.distance.text = getDistance(fromLocation: self.currentLocation!, toLocation: CLLocation(latitude: Double(place.latitude), longitude: Double(place.longitude)))
//            
//            
//            return infoWindow
//            
//        }
        
//        let data = marker.userData as? MapCluster
//        
//        if let markerData = data{
//            if data?.type == "event"{
//                let index:Int! = Int(data!.id)
//                let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
//                let event = self.events[index]
//                infoWindow.name.text = event.title
//                infoWindow.address.text  = event.shortAddress
//                infoWindow.time.text = event.date?.components(separatedBy: ",")[1]
//                infoWindow.attendees.text = "No one joining"
//                return infoWindow
//            }
//            else{
//                let index:Int! = Int(data!.id)
//                let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
//                let place = self.places[index]
//                infoWindow.name.text = place.name
//                infoWindow.address.text  = place.address[0]
//                infoWindow.time.text = "\(place.rating) (\(place.reviewCount))"
//                
//                let categoryString = place.categories.map(){ $0.name }.joined(separator: ", ")
//                
//                infoWindow.attendees.text = categoryString
//                return infoWindow
//            }
//        }
//        else{
//            let newCamera = GMSCameraPosition.camera(withTarget: marker.position,
//                                                     zoom: mapView.camera.zoom + 1)
//            let update = GMSCameraUpdate.setCamera(newCamera)
//            mapView.moveCamera(update)
//            
//            print("cluster click")
//            return nil
//        }
    //}
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let accessibilityLabel = marker.accessibilityLabel
        
        
        let parts = accessibilityLabel?.components(separatedBy: "_")
        if parts?[0] == "event"{
            let index:Int! = Int(parts![1])
            let event = self.events[index]
            let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
            controller.event = event
            self.present(controller, animated: true, completion: nil)
        }
        else if parts?[0] == "place"{
            let index:Int! = Int(parts![1])
            let place = self.places[index % self.places.count]
            let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
            controller.place = place
            self.present(controller, animated: true, completion: nil)
        }
        else
        {
            let data = pins[Int((parts?[1])!)!]
            let storyboard = UIStoryboard(name: "Pin", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
            ivc.data = data
            self.present(ivc, animated: true, completion: { _ in })
            
        }
        
//        let data = marker.userData as? MapCluster
//        
//        if let markerData = data{
//            if data?.type == "event"{
//                let index:Int! = Int(data!.id)
//                let event = self.events[index]
//                let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
//                let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
//                controller.event = event
//                self.present(controller, animated: true, completion: nil)
//                
//            }
//            else{
//                let index:Int! = Int(data!.id)
//                let place = self.places[index]
//                let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
//                let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
//                controller.place = place
//                controller.currentLocation = self.currentLocation
//                self.present(controller, animated: true, completion: nil)
//            }
//        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        var lat: CLLocationDegrees = mapView.camera.target.latitude
        var long: CLLocationDegrees = mapView.camera.target.longitude
        
        
        var currentLocation =  CLLocation(latitude: lat, longitude: long)

        
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
    
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        if AuthApi.isNewUser(){
            AuthApi.setNewUser()
           
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            let username = alert.addTextField("Enter your username")
            username.autocapitalizationType = .none
            alert.addButton("Add user name") {
                if (username.text?.characters.count)! > 0{
                    
                    Constants.DB.user_mapping.child(username.text).observeSingleEvent(of: .value, with: {snapshot in
                        if snapshot.value == nil{
                            
                            Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/username").setValue(username.text)
                            AuthApi.set(username: username.text)
                            print("Text value: \(username.text!)")
                            alert.hideView()
                            self.showPopup()
                        }
                    })
                }
                
            }
            
            alert.showEdit("Username", subTitle: "Please add a username so friends can find you.")
            
            
            
        }
        else{
            
        }
//        changeTab()
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
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
                                              zoom: 15)
        
        let position = CLLocationCoordinate2D(latitude: Double(location.coordinate.latitude), longitude: Double(location.coordinate.longitude))
//        if self.userLocation == nil{
//            self.userLocation = GMSMarker(position: position)
//            self.userLocation?.icon = UIImage(named: "self_location")
//            self.userLocation?.map = self.mapView
//            self.userLocation?.zIndex = 1
//        }
//        else{
//            self.userLocation?.map = nil
//            
//            self.userLocation = GMSMarker(position: position)
//            self.userLocation?.icon = UIImage(named: "self_location")
//            self.userLocation?.map = self.mapView
//            self.userLocation?.zIndex = 1
//            
//        }
        
        
        
        AuthApi.set(location: location)
        
        let current = changeTimeZone(of: Date(), from: TimeZone(abbreviation: "GMT")!, to: TimeZone.current)
        
        let solar = Solar(for: current, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if (solar?.isNighttime)!{
            
//            if !hasCustomProfileImage{
//                navigationView.userProfileButton.setImage(UIImage(named: "User_Profile"), for: .normal)
//            }
//            
//            navigationView.messagesButton.setImage(UIImage(named: "Messages"), for: .normal)
//            navigationView.searchButton.setImage(UIImage(named: "Search"), for: .normal)
//            navigationView.notificationsButton.setImage(UIImage(named: "Notifications"), for: .normal)

            navigationView.view.backgroundColor = Constants.color.navy
            
//            self.tabBarController!.tabBar.backgroundColor = UIColor(hexString: "435366")


            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        self.currentLocation = location
        self.searchPlacesTab?.location = location
        
        if AuthApi.getEventBriteToken() != nil{
            getEvents(around: self.currentLocation!, completion: { events in
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
        
        if let token = AuthApi.getYelpToken(){
            self.fetchPlaces(around: self.currentLocation!, token: token)
        }
        else{
            getYelpToken(completion: {(token) in
                self.fetchPlaces(around: self.currentLocation!, token: token)
            })
        }
        
        if !showEvent{
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
        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude)!,
                                              longitude: (currentLocation?.coordinate.longitude)!,
                                              zoom: 15)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
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
    
    func userProfileClicked() {
        // testing create event
//        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
//        self.present(controller, animated: true, completion: nil)
        
        let VC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UserProfileViewController
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(VC, animated:true, completion:nil)        
    }
    
    func messagesClicked() {
        
        let VC:UIViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UINavigationController
        self.present(VC, animated:true, completion:nil)
    }
    
    func notificationsClicked() {
        
//        let selectInterests = InterestsViewController(nibName: "InterestsViewController", bundle: nil)
//        self.present(selectInterests, animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Notif_Invite_Feed", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotifViewController") as! NotificationFeedViewController
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func searchClicked() {
        let storyboard = UIStoryboard(name: "general_search", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "Home") as? SearchViewController
        VC?.location = self.currentLocation
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(VC!, animated: true, completion: nil)
        
        
    }
    
    func fetchPlaces(around location: CLLocation, token: String){
        let url = "https://api.yelp.com/v3/businesses/search"
        let parameters: [String: Any] = [
            "categories": getYelpCategories(),
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
                
                if !self.places.contains(place){
                    
                    let position = CLLocationCoordinate2D(latitude: Double(place.latitude), longitude: Double(place.longitude))
                    let marker = GMSMarker(position: position)
                    marker.icon = UIImage(named: "place_icon")
                    marker.title = place.name
                    marker.map = self.mapView
                    marker.accessibilityLabel = "place_\(self.places.count)"
                    
//                    let item = MapCluster(position: position, name: place.name, icon: UIImage(named: "place_icon")!, id: String(self.places.count), type: "place")
//                    self.clusterManager.add(item)
                    self.places.append(place)
                    self.placeMapping[place.id] = place
                    self.getPlaceHours(id: place.id)
                    
                    //self.searchPlacesTab?.places.append(place)
                    

                }
            }
//            self.clusterManager.cluster()
        }
    }
    
    func getPlaceHours(id: String){
        let url = "https://api.yelp.com/v3/businesses/\(id)"
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(AuthApi.getYelpToken()!)",
            "cache-contro": "no-cache"
        ]
        
        Alamofire.request(url, method: .get, parameters:nil, headers: headers).responseJSON { response in
            let json = JSON(data: response.data!)
            
            if json["hours"].arrayValue.count > 0{
                let open_hours = json["hours"].arrayValue[0].dictionaryValue
                var hours = [Hours]()
                for hour in (open_hours["open"]?.arrayValue)!{
                    let hour = Hours(start: hour["start"].stringValue, end: hour["end"].stringValue, day: hour["day"].intValue)
                    hours.append(hour)
                }
                let place = self.placeMapping[id]
                place?.setHours(hours: hours)
            }
            
        }
    }
    
    func fetchPins()
    {
        Constants.DB.pins.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                // remove any old pins
                for marker in self.lastPins{
                    marker.map = nil
                }
                
                for (key,_) in (value)!
                {
                    let data = pinData(UID: (value?[key] as! NSDictionary)["fromUID"] as! String, dateTS: (value?[key] as! NSDictionary)["time"] as! Double, pin: (value?[key] as! NSDictionary)["pin"] as! String, location: (value?[key] as! NSDictionary)["formattedAddress"] as! String, lat: (value?[key] as! NSDictionary)["lat"] as! Double, lng: (value?[key] as! NSDictionary)["lng"] as! Double, path: Constants.DB.pins.child(key as! String), focus: (value?[key] as! NSDictionary)["focus"] as? String ?? "")

                    let position = CLLocationCoordinate2D(latitude: Double(data.coordinates.latitude), longitude: Double(data.coordinates.longitude))
                    let marker = GMSMarker(position: position)
                    marker.title = data.pinMessage
                    marker.map = self.mapView
                    let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
                    image.image = UIImage(named: "pin")
                    image.contentMode = .scaleAspectFit
                    marker.iconView = image
                    marker.accessibilityLabel = "pin_\(self.pins.count)"
                    
                    self.lastPins.append(marker)
                    self.pins.append(data)
                }
            }
        })

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
        


        // Present dialog
        //present(popup, animated: true, completion: nil)
    }
    
    func changeTab(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "home") as! UITabBarController
        vc.selectedIndex = 2
        self.present(vc, animated: true, completion: nil)

    }
}

extension MapViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Loading")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if (webView.request?.url?.absoluteString.range(of: "access_token=") != nil) {
            let params = webView.request?.url?.absoluteString.components(separatedBy: "=")
            let access_token = (params?.last!)!
            AuthApi.set(eventBriteAccessToken: access_token)
            self.webView.isHidden = true
            
            getEvents(around: self.currentLocation!, completion: { events in
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
        else{
            self.webView.isHidden = false
        }
    }    
}
