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

class MapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    
    var createdEvent: Event?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.primaryGreen()
        toolbar.barTintColor = UIColor.primaryGreen()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        mapView.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        Constants.DB.event.observe(FIRDataEventType.value, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            
            for (_, event) in events{
                let info = event as? [String:String]
                let event = Event(title: (info?["title"])!, description: (info?["description"])!, fullAddress: (info?["fullAddress"])!, shortAddress: (info?["shortAddress"])!, latitude: (info?["latitude"])!, longitude: (info?["longitude"])!, date: (info?["date"])!, creator: (info?["creator"])!
                )
        
                
                
                let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                let marker = GMSMarker(position: position)
                marker.icon = UIImage(named: "addUser")
                marker.title = event.title
                marker.map = self.mapView
                marker.accessibilityLabel = String(describing: self.events.count)
                self.events.append(event)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        let index:Int! = Int(marker.accessibilityLabel!)
        let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
        let event = self.events[index]
        infoWindow.name.text = event.title
        infoWindow.address.text  = event.shortAddress
        infoWindow.time.text = event.date?.components(separatedBy: ",")[1]
        infoWindow.attendees.text = "No one joining"
        return infoWindow
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let index:Int! = Int(marker.accessibilityLabel!)
        let event = self.events[index]
        self.performSegue(withIdentifier: "show_event_details", sender: event)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_event_detail"{
            let destinationVC = segue.destination as! EventDetailViewController
            destinationVC.event = sender as! Event?
        }
        
    }
}
