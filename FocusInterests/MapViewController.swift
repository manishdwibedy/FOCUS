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
import Solar
import TwitterKit
import FirebaseAuth

class MapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, NavigationInteraction, GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    
    var createdEvent: Event?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 5.0
    var events = [Event]()
    private var clusterManager: GMUClusterManager!

    
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
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
//        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)

        let renderer = CustomClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        
        Constants.DB.event.observe(FIRDataEventType.value, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            
            for (id, event) in events{
                let info = event as? [String:Any]
                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id)
        
                let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
//                let marker = GMSMarker(position: position)
//                marker.icon = UIImage(named: "addUser")
//                marker.title = event.title
//                marker.map = self.mapView
//                marker.accessibilityLabel = String(describing: self.events.count)
                self.events.append(event)
                let item = MapCluster(position: position, name: event.title!, icon: UIImage(named: "addUser")!, id: String(describing: self.events.count))
                self.clusterManager.add(item)
                
                
            }
            // Call cluster() after items have been added to perform the clustering and rendering on map.
            self.clusterManager.cluster()
            
            // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
            self.clusterManager.setDelegate(self, mapDelegate: self)
            
            
        })
        
//        self.generateClusterItems()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        let data = (marker.userData as! MapCluster)
        let index:Int! = Int(data.id)
        let infoWindow = Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil)?[0] as! MapInfoView
        let event = self.events[index]
        infoWindow.name.text = event.title
        infoWindow.address.text  = event.shortAddress
        infoWindow.time.text = event.date?.components(separatedBy: ",")[1]
        infoWindow.attendees.text = "No one joining"
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let data = (marker.userData as! MapCluster)
        let index:Int! = Int(data.id)
        let event = self.events[index]
        //self.performSegue(withIdentifier: "show_event_details", sender: event)
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
        controller.event = event
        self.present(controller, animated: true, completion: nil)
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
                                              zoom: self.zoomLevel)
        
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
    
    // MARK: - GMUClusterManagerDelegate
    
    func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                           zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
    // MARK: - GMUMapViewDelegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? MapCluster {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        marker.icon = UIImage(named: "addUser")
    }
    
    func messagesClicked() {
        let VC:UIViewController = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UINavigationController
        
        self.present(VC, animated:true, completion:nil)
    }
    
    func notificationsClicked() {
//        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
//        self.present(vc, animated: true, completion: nil)
    
        if AuthApi.getTwitterToken() == nil{
            Twitter.sharedInstance().logIn { session, error in
                if (session != nil)
                {
                    print("signed in as \(session!.userName)");
                    if (session != nil) {
                        let authToken = session?.authToken
                        let authTokenSecret = session?.authTokenSecret
                        let credential = FIRTwitterAuthProvider.credential(withToken: authToken!, secret: authTokenSecret!)
                        
                        let user = FIRAuth.auth()?.currentUser
                        user?.link(with: credential, completion: { (user, error) in
                            if let error = error {
                                // ...
                                return
                            }
                            AuthApi.set(twitterToken: authToken!)
                        })
                        
                    }
                }
                else
                {
                    print("error: \(error!.localizedDescription)");
                }
            }
        }
        else{
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_event_details"{
            let destinationVC = segue.destination as! EventDetailViewController
            destinationVC.event = sender as! Event
        }
        
    }
    
//    let kCameraLatitude = 34.03
//    let kCameraLongitude = -118.28
//    
//    private func generateClusterItems() {
//        let extent = 0.2
//        for index in 1...100 {
//            let lat = kCameraLatitude + extent * randomScale()
//            let lng = kCameraLongitude + extent * randomScale()
//            let name = "Item \(index)"
//            let icon = UIImage(named: "addUser")
//            let item = MapCluster(position: CLLocationCoordinate2DMake(lat, lng), name: name, icon: icon!)
//            clusterManager.add(item)
//        }
//    }
//    
//    /// Returns a random value between -1.0 and 1.0.
//    private func randomScale() -> Double {
//        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
//    }
}
