//
//  InvitePeopleViewController.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON

class InvitePeopleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedOut: UISegmentedControl!
    
    
    var UID = ""
    var filtered = [Place]()
    var places = [Place]()
    var events = [Event]()
    var location: CLLocation?
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.clipsToBounds = true
        let nib = UINib(nibName: "InvitePeoplePlaceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InvitePeoplePlaceCell")
        let nib2 = UINib(nibName: "InvitePeopleEventCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "InvitePeopleEventCell")

        
        searchBar.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.filtered = places
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        self.location = location
        updatePlaces()
        print("got location")
        locationManager.stopUpdatingLocation()
        
        
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func segmentedChanged(_ sender: Any) {
        searchBar.text = nil
        places.removeAll()
        events.removeAll()
        if segmentedOut.selectedSegmentIndex == 0
        {
            updatePlaces()
        }else if segmentedOut.selectedSegmentIndex == 1
        {
            updateEvents()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedOut.selectedSegmentIndex == 0
        {
        return filtered.count
        }else
        {
            return events.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedOut.selectedSegmentIndex == 0
        {
            let cell:InvitePeoplePlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "InvitePeoplePlaceCell") as! InvitePeoplePlaceCell!
            
            let place = filtered[indexPath.row]
            cell.place = place
            cell.placeNameLabel.text = place.name
           // cell.place = place
            if place.address.count > 0{
                if place.address.count == 1{
                    cell.addressTextView.text = "\(place.address[0])"
                }
                else{
                    cell.addressTextView.text = "\(place.address[0])\n\(place.address[1])"
                }
            }
            //cell.placeID = place.id
            cell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) ratings)"
            cell.categoryLabel.text = place.categories[0].name
            //cell.checkForFollow(id: place.id)
            let placeHolderImage = UIImage(named: "empty_event")
            cell.placeImage.sd_setImage(with: URL(string :place.image_url), placeholderImage: placeHolderImage)
            cell.UID = UID
            cell.parentVC = self
            return cell
        }else
        {
            let cell:InvitePeopleEventCell = self.tableView.dequeueReusableCell(withIdentifier: "InvitePeopleEventCell") as! InvitePeopleEventCell!
            cell.name.text = events[indexPath.row].title
            cell.address.text = events[indexPath.row].fullAddress
            cell.interest.text = events[indexPath.row].category
            cell.event = events[indexPath.row]
            cell.UID = UID
            cell.parentVC = self
            cell.loadLikes()
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.places[indexPath.row]
        let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
        controller.place = place
        self.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if segmentedOut.selectedSegmentIndex == 0
        {
            if(searchText.characters.count > 0){
                self.filtered.removeAll()
                let url = "https://api.yelp.com/v3/businesses/search"
                
                let headers: HTTPHeaders = [
                    "authorization": "Bearer \(AuthApi.getYelpToken()!)",
                    "cache-contro": "no-cache"
                ]
                
                let parameters = [
                    "term": searchText,
                    "latitude": location?.coordinate.latitude,
                    "longitude": location?.coordinate.longitude,
                    ] as [String : Any]
                
                
                Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
                    let json = JSON(data: response.data!)
                    print(json)
                    _ = self.places.count
                    for (_, business) in json["businesses"].enumerated(){
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
                        
                        if !self.filtered.contains(place){
                            self.filtered.append(place)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            else{
                self.filtered = self.places
                self.tableView.reloadData()
            }
        }else if segmentedOut.selectedSegmentIndex == 1
        {
            
        
            
        }
        
        
    }
    
    func updateEvents()
    {
        Constants.DB.event.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                for (id, event) in value!
                {
                    let info = event as? [String:Any]
                    let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id as! String, category: info?["interest"] as? String)
                    self.events.append(event)
                }
            }
            self.tableView.reloadData()
        })
        
        
    }
    
    func updatePlaces()
    {
        self.filtered.removeAll()
        let url = "https://api.yelp.com/v3/businesses/search"
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(AuthApi.getYelpToken()!)",
            "cache-contro": "no-cache"
        ]
        
        let parameters = [
            "latitude": location?.coordinate.latitude,
            "longitude": location?.coordinate.longitude,
            ] as [String : Any]
        
        
        Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
            let json = JSON(data: response.data!)
            print(json)
            _ = self.places.count
            for (_, business) in json["businesses"].enumerated(){
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
                
                if !self.filtered.contains(place){
                    self.filtered.append(place)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    


   

}
