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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var people_tableView: UITableView!
    @IBOutlet weak var place_tableView: UITableView!
    
    var location: CLLocation?
    var people = [User]()
    var filtered_user = [User]()
    var places = [Place]()
    var filtered_places = [Place]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        peopleHeaderView.topCornersRounded(radius: 20)
        people_tableView.tableFooterView = UIView()
        
        placeHeaderView.topCornersRounded(radius: 20)
        place_tableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
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
        else{
            return filtered_places.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if tableView == self.people_tableView{
            let user = self.filtered_user[indexPath.row]
            cell.textLabel?.text = user.username
        }
        else{
            let place = self.filtered_places[indexPath.row]
            cell.textLabel?.text = place.name
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

}
