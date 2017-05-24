//
//  SearchEventsViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON

class SearchEventsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var createEventButton: UIButton!
    var events = [Event]()
    var filtered = [Event]()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.clipsToBounds = true
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        
        self.searchBar.delegate = self
        
        createEventButton.roundCorners(radius: 10)
        tableHeader.topCornersRounded(radius: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.filtered = events
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchPlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPlaceCell!
        let event = filtered[indexPath.row]
        cell.placeNameLabel.text = event.title
        
//        if event..count > 0{
//            if event.address.count == 1{
//                cell.addressTextView.text = "\(event.address[0])"
//            }
//            else{
//                cell.addressTextView.text = "\(event.address[0])\n\(event.address[1])"
//            }
//        }
//        
//        event.shortAddress
        
//        cell.ratingLabel.text = "\(event.rating) (\(event.reviewCount) ratings)"
//        cell.categoryLabel.text = event.categories[0].name
//        cell.checkForFollow(id: event.id)
//        let placeHolderImage = UIImage(named: "empty_event")
//        cell.placeImage.sd_setImage(with: URL(string :event.image_url), placeholderImage: placeHolderImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
                "radius": 1000
                ] as [String : Any]
            
            Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
                let json = JSON(data: response.data!)
                
                let initial = self.events.count
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
                    
//                    if !self.filtered.contains(place){
//                        self.filtered.append(place)
//                    }
                }
                self.tableView.reloadData()
            }
        }
        else{
            self.filtered = self.events
            self.tableView.reloadData()
        }
        
        
    }
    @IBAction func showCreateEvent(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
        self.present(controller, animated: true, completion: nil)

        
    }

}
