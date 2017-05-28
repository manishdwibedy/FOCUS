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

class MapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, NavigationInteraction,GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    
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
    
    var searchPlacesTab: SearchPlacesViewController? = nil
    var searchEventsTab: SearchEventsViewController? = nil
    
    @IBOutlet weak var navigationView: MapNavigationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        
        
        if let last_pos = UserDefaults.standard.value(forKey: "last_location") as? String{
            let coord = last_pos.components(separatedBy: ";;")
            
            let camera = GMSCameraPosition.camera(withLatitude: Double(coord[0])!,
                                                  longitude: Double(coord[1])!,
                                                  zoom: 15)
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        }
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
        let renderer = CustomClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        Constants.DB.event.observe(FIRDataEventType.value, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            
            for (id, event) in events{
                let info = event as? [String:Any]
                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id, category: info?["interest"] as? String)
        
                if let attending = info?["attendingList"] as? [String:Any]{
                    event.setAttendessCount(count: attending.count)
                }
                
                let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                self.events.append(event)
                
                let item = MapCluster(position: position, name: event.title!, icon: UIImage(named: "Event")!, id: String(describing: self.events.count), type: "event")
                self.clusterManager.add(item)
                self.searchEventsTab?.events.append(event)
            }
            
            // Call cluster() after items have been added to perform the clustering and rendering on map.
            self.clusterManager.cluster()
            
            // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
            self.clusterManager.setDelegate(self, mapDelegate: self)
            
        })
        
        self.searchPlacesTab = self.tabBarController?.viewControllers?[3] as? SearchPlacesViewController
        self.searchEventsTab = self.tabBarController?.viewControllers?[4] as? SearchEventsViewController
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        let data = marker.userData as? MapCluster
        
        if let markerData = data{
            if data?.type == "event"{
                let index:Int! = Int(data!.id)
                let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
                let event = self.events[index]
                infoWindow.name.text = event.title
                infoWindow.address.text  = event.shortAddress
                infoWindow.time.text = event.date?.components(separatedBy: ",")[1]
                infoWindow.attendees.text = "No one joining"
                return infoWindow
            }
            else{
                let index:Int! = Int(data!.id)
                let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
                let place = self.places[index]
                infoWindow.name.text = place.name
                infoWindow.address.text  = place.address[0]
                infoWindow.time.text = "\(place.rating) (\(place.reviewCount))"
                
                let categoryString = place.categories.map(){ $0.name }.joined(separator: ", ")
                
                infoWindow.attendees.text = categoryString
                return infoWindow
            }
        }
        else{
            let newCamera = GMSCameraPosition.camera(withTarget: marker.position,
                                                     zoom: mapView.camera.zoom + 1)
            let update = GMSCameraUpdate.setCamera(newCamera)
            mapView.moveCamera(update)
            
            print("cluster click")
            return nil
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let data = marker.userData as? MapCluster
        
        if let markerData = data{
            if data?.type == "event"{
                let index:Int! = Int(data!.id)
                let event = self.events[index]
                let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
                controller.event = event
                self.present(controller, animated: true, completion: nil)
                
            }
            else{
                let index:Int! = Int(data!.id)
                let place = self.places[index]
                let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
                controller.place = place
                controller.currentLocation = self.currentLocation
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        if AuthApi.isNewUser(){
            AuthApi.setNewUser()
            self.showPopup()
        }
        
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
        
        UserDefaults.standard.set("last_location", forKey: "\(location.coordinate.latitude);;\(location.coordinate.longitude)")
        
        let current = changeTimeZone(of: Date(), from: TimeZone(abbreviation: "GMT")!, to: TimeZone.current)
        
        let solar = Solar(for: current, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if (solar?.isNighttime)!{
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
        
        
        getEvents(around: self.currentLocation!, completion: { events in
            for event in events{
                let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                let marker = GMSMarker(position: position)
                marker.icon = UIImage(named: "Event")
                marker.title = event.title
                marker.map = self.mapView
                marker.accessibilityLabel = "event_\(self.events.count)"
                
            }
        })
        
        print("got location")
        if let token = AuthApi.getYelpToken(){
            self.fetchPlaces(token: token)
        }
        else{
            getYelpToken(completion: {(token) in
                self.fetchPlaces(token: token)
            })
        }
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }

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
        
        
        let VC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UserProfileViewController
        
        self.present(VC, animated:true, completion:nil)
    }
    
    func messagesClicked() {
        let VC:UIViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UINavigationController
        
//        let newPerson = Event(title: "t", description: "d", fullAddress: "", shortAddress: "", latitude: "", longitude: "", date: "", creator: "", category: "")
//        let encodedData = NSKeyedArchiver.archivedData(withRootObject: newPerson)
//        UserDefaults.standard.set(encodedData, forKey: "people")
//        
//        // retrieving a value for a key
//        if let data = UserDefaults.standard.data(forKey: "people"),
//            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? Event {
//            print(myPeopleList)
//        } else {
//            print("There is an issue")
//        }
        
        self.present(VC, animated:true, completion:nil)
    }
    
    func notificationsClicked() {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    func fetchPlaces(token: String){
        let url = "https://api.yelp.com/v3/businesses/search"
        let parameters: [String: Double] = [
            "latitude" : Double(self.currentLocation!.coordinate.latitude),
            "longitude" : Double(self.currentLocation!.coordinate.longitude)
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
                
                var address = [String]()
                for raw_address in address_json{
                    address.append(raw_address.stringValue)
                }
                
                var categories = [Category]()
                for raw_category in categories_json as [JSON]{
                    let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                    categories.append(category)
                }
                
                let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories)
                
                if !self.places.contains(place){
                    
                    let position = CLLocationCoordinate2D(latitude: Double(place.latitude), longitude: Double(place.longitude))
                    
                    let item = MapCluster(position: position, name: place.name, icon: UIImage(named: "place_icon")!, id: String(self.places.count), type: "place")
                    self.clusterManager.add(item)
                    self.places.append(place)
                    self.placeMapping[place.id] = place
                    self.getPlaceHours(id: place.id)
                    
                    self.searchPlacesTab?.places.append(place)
                    

                }
            }
            self.clusterManager.cluster()
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
    
    func showPopup(){
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        
        overlayAppearance.color       = UIColor.black
        overlayAppearance.blurRadius  = 20
        overlayAppearance.blurEnabled = false
        overlayAppearance.liveBlur    = false
        overlayAppearance.opacity     = 0.4
        
        var dialogAppearance = PopupDialogDefaultView.appearance()
        
        dialogAppearance.backgroundColor      = UIColor.white
        dialogAppearance.titleFont            = UIFont.boldSystemFont(ofSize: 14)
        dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont.systemFont(ofSize: 14)
        dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        dialogAppearance.messageTextAlignment = .center
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 10
        pcv.shadowEnabled   = true
        pcv.shadowColor     = UIColor.black
        
        
        // Create a custom view controller
        let onboardingVC = NewUserPopupViewController(nibName: "NewUserPopupViewController", bundle: nil)
        onboardingVC.arrowImage = self.popupArrowImage
        
//        onboardingVC.testImage = self.testImage
        
        // Create the dialog
        let popup = PopupDialog(viewController: onboardingVC, buttonAlignment: .horizontal, transitionStyle: .bounceDown, gestureDismissal: true)
        
        
        
        // Present dialog
        present(popup, animated: true, completion: nil)
    }
}
