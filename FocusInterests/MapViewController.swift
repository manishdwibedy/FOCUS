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

class MapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, NavigationInteraction {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    
    var createdEvent: Event?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var events = [Event]()
    var places = [Place]()
    var placeMapping = [String: Place]()
    
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
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        Constants.DB.event.observe(FIRDataEventType.value, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            
            for (id, event) in events{
                let info = event as? [String:Any]
                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id)
        
                let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                let marker = GMSMarker(position: position)
                marker.icon = UIImage(named: "addUser")
                marker.title = event.title
                marker.map = self.mapView
                marker.accessibilityLabel = "event_\(self.events.count)"
                self.events.append(event)
            }
        })
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
        let accessibilityLabel = marker.accessibilityLabel
        
        let parts = accessibilityLabel?.components(separatedBy: "_")
        if parts?[0] == "event"{
            let index:Int! = Int(parts![1])
            let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
            let event = self.events[index]
            infoWindow.name.text = event.title
            infoWindow.address.text  = event.shortAddress
            infoWindow.time.text = event.date?.components(separatedBy: ",")[1]
            infoWindow.attendees.text = "No one joining"
            return infoWindow
        }
        else{
            let index:Int! = Int(parts![1])
            let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
            let place = self.places[index % self.places.count]
            infoWindow.name.text = place.name
            infoWindow.address.text  = "\(place.address[0]), \(place.address[1])"
            infoWindow.time.text = ""
            infoWindow.attendees.text = "No one joining"
            return infoWindow
        }
        
    }
    
    
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
        else{
            let index:Int! = Int(parts![1])
            let place = self.places[index % self.places.count]
            let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
            controller.place = place
            self.present(controller, animated: true, completion: nil)
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
        self.currentLocation = location
        print("got location")
        self.fetchPlaces(token: AuthApi.getYelpToken()!)
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
    
    func messagesClicked() {
        let VC:UIViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UINavigationController
        
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
                    let marker = GMSMarker(position: position)
                    marker.icon = UIImage(named: "place_icon")
                    marker.title = place.name
                    marker.map = self.mapView
                    marker.accessibilityLabel = "place_\(initial + index)"
                    
                    self.places.append(place)
                    self.placeMapping[place.id] = place
                    self.getPlaceHours(id: place.id)
                }
            }
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_event_details"{
            let destinationVC = segue.destination as! EventDetailViewController
            destinationVC.event = sender as! Event
        }
        else if segue.identifier == ""{
            let destinationVC = segue.destination as! PlaceViewController
            destinationVC.place = sender as! Place
        }
        
    }
}
