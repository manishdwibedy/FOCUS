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

class InvitePeopleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedOut: UISegmentedControl!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    var UID = ""
    var username = ""
    var filtered = [Any]()
    var places = [Place]()
    var events = [Event]()
    var location: CLLocation?
    var searchPeople: SearchPeopleViewController? = nil
    var mapView: MapViewController? = nil
    var searchPeopleDelegate: SearchPeopleViewControllerDelegate?
    
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
        
        //        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        
        //        search bar placeholder
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = Constants.color.navy
        textFieldInsideSearchBar?.attributedPlaceholder = attributedPlaceholder
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        //        search bar glass icon
        let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        glassIconView.tintColor = UIColor.white
        
        //        search bar clear button
        textFieldInsideSearchBar?.clearButtonMode = .whileEditing
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        UIBarButtonItem.appearance().setTitleTextAttributes(placeholderAttributes, for: .normal)
        
        self.segmentedOut.layer.cornerRadius = 5
        self.segmentedOut.layer.borderColor = UIColor.white.cgColor
        self.segmentedOut.layer.borderWidth = 1.0
        self.segmentedOut.layer.masksToBounds = true
        
        
        let sortedViews = segmentedOut.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        sortedViews[0].tintColor = Constants.color.green
        sortedViews[0].backgroundColor = UIColor.white
        
        sortedViews[1].tintColor = UIColor.white
        sortedViews[1].backgroundColor = UIColor.gray
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        navBar.barTintColor = Constants.color.navy
        self.view.backgroundColor = Constants.color.navy
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.filtered = places
        //self.tableView.reloadData()
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
//        places.removeAll()
//        events.removeAll()
        if segmentedOut.selectedSegmentIndex == 0
        {
            updatePlaces()
        }else if segmentedOut.selectedSegmentIndex == 1
        {
            updateEvents()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if segmentedOut.selectedSegmentIndex == 0
//        {
            return filtered.count
//        }else
//        {
//            return events.count
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedOut.selectedSegmentIndex == 0
        {
            let cell:InvitePeoplePlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "InvitePeoplePlaceCell") as! InvitePeoplePlaceCell!
            
            let place = filtered[indexPath.row] as! Place
            cell.place = place
            cell.placeNameLabel.text = place.name
           // cell.place = place
            if place.address.count > 0{
                if place.address.count == 1{
                    cell.addressTextView.text = "\(place.address[0])"
                }
                else{
                    cell.addressTextView.text = "\(place.address[0])\n\(place.address.last!)"
                }
            }
            //cell.placeID = place.id
            cell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) ratings)"
            
            let place_location = CLLocation(latitude: place.latitude, longitude: place.longitude)
            cell.distanceLabel.text = getDistance(fromLocation: place_location, toLocation: AuthApi.getLocation()!)
            if place.categories.count > 0{
                addGreenDot(label: cell.categoryLabel, content: getInterest(yelpCategory: place.categories[0].alias))
            }
        
            //cell.checkForFollow(id: place.id)
            let placeHolderImage = UIImage(named: "empty_event")
            cell.placeImage.sd_setImage(with: URL(string :place.image_url), placeholderImage: placeHolderImage)
            cell.UID = UID
            cell.username = username
            cell.parentVC = self
            return cell
        }else
        {
            let cell:InvitePeopleEventCell = self.tableView.dequeueReusableCell(withIdentifier: "InvitePeopleEventCell") as! InvitePeopleEventCell!
            let event = filtered[indexPath.row] as! Event
            cell.name.text = event.title
            cell.address.text = event.fullAddress?.replacingOccurrences(of: ";;", with: "\n")
            
            if let category = event.category{
                if category.contains(","){
                    addGreenDot(label: cell.interest, content: category.components(separatedBy: ",")[0])
                }
                else{
                    addGreenDot(label: cell.interest, content: category)
                }
            }
            
            cell.event = event
            cell.UID = UID
            cell.username = username
            cell.parentVC = self
            cell.guestCount.text = "\(event.attendeeCount) guests"
            
            cell.price.text = event.price == nil || event.price == 0 ? "Free" : "$\(event.price)"
            
            let eventLocation = CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
            cell.distance.text = getDistance(fromLocation: eventLocation, toLocation: AuthApi.getLocation()!)
        
            
            let reference = Constants.storage.event.child("\(event.id!).jpg")
            
            cell.eventImage.image = crop(image: #imageLiteral(resourceName: "empty_event"), width: 50, height: 50)
            
            reference.downloadURL(completion: { (url, error) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                
                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                    (receivedSize :Int, ExpectedSize :Int) in
                    
                }, completed: {
                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                    
                    if image != nil && finished{
                        cell.eventImage.image = crop(image: image!, width: 50, height: 50)
                    }
                })
                
                
            })
            
            cell.loadLikes()
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if segmentedOut.selectedSegmentIndex == 0{
//            let cell:InvitePeoplePlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "InvitePeoplePlaceCell") as! InvitePeoplePlaceCell!
//            let place = self.filtered[indexPath.row]
//            let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
//            controller.place = place as! Place
//            self.present(controller, animated: true, completion: nil)
//        }
//        else{
//            let event = self.filtered[indexPath.row]
//            let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
//            controller.event = event as! Event
//            self.present(controller, animated: true, completion: nil)
//        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedOut.selectedSegmentIndex == 0{
            return 115
        }
        else{
            return 105
        }
        
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
                    "latitude": location?.coordinate.latitude ?? 0,
                    "longitude": location?.coordinate.longitude ?? 0,
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
                        
                        let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone, is_closed: is_closed)
                        
//                        if !self.filtered.contains(where: place){
                            self.filtered.append(place)
//                        }
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func updateEvents()
    {
        Constants.DB.event.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.filtered.removeAll()
            if value != nil
            {
                for (id, event) in value!
                {
                    if let info = event as? [String:Any]{
                        let event = Event.toEvent(info: info)
//                        let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as? String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id as? String, category: info?["interest"] as? String, privateEvent: (info?["private"] as? Bool)!)
                        self.filtered.append(event)
                    }
                    
                }
                self.tableView.reloadData()
            }
            
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
            "latitude": location?.coordinate.latitude ?? 0,
            "longitude": location?.coordinate.longitude ?? 0,
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
                
                let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone, is_closed: is_closed)
                
//                if !self.filtered.contains(where: place){
                    self.filtered.append(place)
//                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        
        _ = sender as! UISegmentedControl
        
        
        let sortedViews = (sender as! UISegmentedControl).subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        
        for (index, view) in sortedViews.enumerated() {
            if index == (sender as! UISegmentedControl).selectedSegmentIndex {
                view.tintColor = Constants.color.green
                view.backgroundColor = UIColor.white
            } else {
                view.tintColor = UIColor.white
                view.backgroundColor = UIColor.gray
            }
        }
    }
}
