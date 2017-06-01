//
//  SearchViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/31/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var peopleHeaderView: UIView!
    @IBOutlet weak var placeHeaderView: UIView!
    @IBOutlet weak var eventHeaderView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var people_tableView: UITableView!
    @IBOutlet weak var place_tableView: UITableView!
    @IBOutlet weak var event_tableView: UITableView!
    
    var location: CLLocation?
    var people = [User]()
    var filtered_user = [User]()
    var places = [Place]()
    var filtered_places = [Place]()
    var events = [Event]()
    var filtered_events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        peopleHeaderView.topCornersRounded(radius: 20)
        people_tableView.tableFooterView = UIView()
        
        placeHeaderView.topCornersRounded(radius: 20)
        place_tableView.tableFooterView = UIView()
        
        eventHeaderView.topCornersRounded(radius: 20)
        event_tableView.tableFooterView = UIView()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ref = Constants.DB.user
        _ = ref.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as? [String : Any] ?? [:]
            
            for (_, user) in users{
                let info = user as? [String:Any]
                
                let user = User(username: info?["username"] as! String? , uuid: info?["firebaseUserId"] as! String?, userImage: nil, interests: nil)
                
                if user.uuid != AuthApi.getFirebaseUid(){
                    self.people.append(user)
                }
            }
            self.filtered_user = self.people
            self.people_tableView.reloadData()
        })
        
        getPlaces(text: "")
        getEvents(text: "")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let ref = Constants.DB.user
        _ = ref.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as? [String : Any] ?? [:]
            
            for (_, user) in users{
                let info = user as? [String:Any]
                
                let user = User(username: info?["username"] as! String? , uuid: info?["firebaseUserId"] as! String?, userImage: nil, interests: nil)
                
                if user.uuid != AuthApi.getFirebaseUid(){
                    self.people.append(user)
                }
            }
            self.filtered_user = self.people
            self.people_tableView.reloadData()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0){
            self.filtered_user.removeAll()
            
            let ref = Constants.DB.user
            let query = ref.queryOrdered(byChild: "username").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased()+"\u{f8ff}").observe(.value, with: { snapshot in
                let events = snapshot.value as? [String : Any] ?? [:]
                
                let users = snapshot.value as? [String : Any] ?? [:]
                
                for (_, user) in users{
                    let info = user as? [String:Any]
                    
                    let user = User(username: info?["username"] as! String? , uuid: info?["firebaseUserId"] as! String?, userImage: nil, interests: nil)
                    
                    if user.uuid != AuthApi.getFirebaseUid(){
                        self.filtered_user.append(user)
                    }
                }
                self.people_tableView.reloadData()
            })
            
            self.getPlaces(text: searchText)
        }
        else{
            self.filtered_user = self.people
            self.people_tableView.reloadData()
            
            self.filtered_places = self.places
            self.place_tableView.reloadData()
            
        }

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.people_tableView{
            return filtered_user.count
        }
        else if tableView == self.people_tableView{
            return filtered_places.count
        }
        else{
            return filtered_events.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if tableView == self.people_tableView{
            let user = self.filtered_user[indexPath.row]
            cell.textLabel?.text = user.username
        }
        else if tableView == self.place_tableView{
            let place = self.filtered_places[indexPath.row]
            cell.textLabel?.text = place.name
        }
        else{
            let event = self.filtered_events[indexPath.row]
            cell.textLabel?.text = event.title
        }
        return cell
    }
    
    func getPlaces(text: String){
        if text.characters.count == 0{
            if self.places.count > 0{
                return
            }
        }
        self.filtered_places.removeAll()
        let url = "https://api.yelp.com/v3/businesses/search"
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(AuthApi.getYelpToken()!)",
            "cache-contro": "no-cache"
        ]
        
        let parameters = [
            "term": text,
            "latitude": location?.coordinate.latitude,
            "longitude": location?.coordinate.longitude,
            ] as [String : Any]
        
        Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
            let json = JSON(data: response.data!)
            
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
                
                var address = [String]()
                for raw_address in address_json{
                    address.append(raw_address.stringValue)
                }
                
                var categories = [Category]()
                for raw_category in categories_json as [JSON]{
                    let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                    categories.append(category)
                }
                
                let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url)
                
                if !self.filtered_places.contains(place){
                    self.filtered_places.append(place)
                    if text.characters.count == 0{
                        self.places.append(place)
                    }
                }
            }
            self.place_tableView.reloadData()
        }
    }

    func getEvents(text: String){
        if text.characters.count == 0{
            if self.events.count > 0{
                return
            }
        }
        
        self.filtered_events.removeAll()
        
        let ref = Constants.DB.event
        let query = ref.queryOrdered(byChild: "title").queryStarting(atValue: text.lowercased()).queryEnding(atValue: text.lowercased()+"\u{f8ff}").observe(.value, with: { snapshot in
            let events = snapshot.value as? [String : Any] ?? [:]
            
            for (id, event) in events{
                let info = event as? [String:Any]
                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id, category: info?["interest"] as? String)
                
                if let attending = info?["attendingList"] as? [String:Any]{
                    event.setAttendessCount(count: attending.count)
                }
                
                self.filtered_events.append(event)
            }
            self.event_tableView.reloadData()
        })
    }
}
