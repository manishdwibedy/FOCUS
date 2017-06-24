//
//  search_place.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON

class SearchPlacesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    @IBOutlet weak var invitePopup: UIView!
    var places = [Place]()
    var filtered = [Place]()
    var location: CLLocation?
    var showPopup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")

        self.searchBar.delegate = self
        
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
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showPopup{
            invitePopup.alpha = 1
            invitePopup.allCornersRounded(radius: 10)
            
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:  Selector("hidePopup"), userInfo: nil, repeats: false)

        }
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            
            if let placeData = value{
                let count = placeData.count
                self.places.removeAll()
                for (_,place) in placeData
                {
                    let place_id = (place as? [String:Any])?["placeID"]
                    getYelpByID(ID: place_id as! String, completion: {place in
                        self.places.append(place)
                        
                        if self.places.count == count{
                            self.filtered = self.places
                            self.tableView.reloadData()
                        }
                    })
                
                }
                
            }
        })
    }
    
    func hidePopup(){
        invitePopup.alpha = 0
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
        cell.parentVC = self
        
        let place = filtered[indexPath.row]
        cell.placeNameLabel.text = place.name
        cell.place = place
        if place.address.count > 0{
            if place.address.count == 1{
                cell.addressTextView.text = "\(place.address[0])"
            }
            else{
                cell.addressTextView.text = "\(place.address[0])\n\(place.address[1])"
            }
        }
        let place_location = CLLocation(latitude: place.latitude, longitude: place.longitude)
        cell.distanceLabel.text = getDistance(fromLocation: place_location, toLocation: AuthApi.getLocation()!)
        cell.placeID = place.id
        cell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) ratings)"
        if place.categories.count > 0{
            
            addGreenDot(label: cell.categoryLabel, content: getInterest(yelpCategory: place.categories[0].alias))
//            cell.categoryLabel.text =
        }
        
        cell.parentVC = self
        cell.checkForFollow(id: place.id)
        let placeHolderImage = UIImage(named: "empty_event")
        cell.placeImage.sd_setImage(with: URL(string :place.image_url), placeholderImage: placeHolderImage)
        cell.checkForFollow(id: place.id)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.filtered[indexPath.row]
        let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
        controller.place = place
        self.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var results = [String: [Place]]()
        if(searchText.characters.count > 0){
            
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
            print(location?.coordinate)
            Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
                let json = JSON(data: response.data!)["businesses"]
                
                var result = [Place]()
                
                _ = self.places.count
                for (_, business) in json.enumerated(){
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
                    
                    if !result.contains(place){
                        result.append(place)
                    }
                }
                results[searchText] = result
                print("searching - \(searchText)")
                
                if self.searchBar.text == searchText{
                    print(results[searchText])
                    self.filtered = results[searchText]!
                    
                    self.filtered.sort{ //sort(_:) in Swift 3
                            if $0.name != $1.name {
                                return $0.name < $1.name
                            }
                            
                        else { // All other fields are tied, break ties by last name
                            return $0.distance < $1.distance
                        }
                    }
                    
                    print("searching finally - \(searchText)")
//                    print(self.filtered[0].name)
                    self.tableView.reloadData()
                }
                
            }
        }
        else{
            self.filtered = self.places
            self.tableView.reloadData()
        }
        
        
    }
}
