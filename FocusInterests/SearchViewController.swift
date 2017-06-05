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
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.darkGray
        
        for view in searchBar.subviews.last!.subviews {
            if view.isKind(of: NSClassFromString("UISearchBarBackground")!)
            {
                view.removeFromSuperview()
            }
        }
        
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        place_tableView.register(nib, forCellReuseIdentifier: "cell")

        let nib1 = UINib(nibName: "SearchPeopleTableViewCell", bundle: nil)
        people_tableView.register(nib1, forCellReuseIdentifier: "cell")
        
        let nib2 = UINib(nibName: "SearchEventTableViewCell", bundle: nil)
        event_tableView.register(nib2, forCellReuseIdentifier: "cell")
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    override func dismissKeyboard() {
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
                
                if user.uuid != AuthApi.getFirebaseUid() && user.uuid != nil{
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
            self.getEvents(text: searchText)
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
        else if tableView == self.place_tableView{
            return filtered_places.count
        }
        else{
            return filtered_events.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == self.people_tableView{
            let people = self.filtered_user[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchPeopleTableViewCell!
            
            cell?.username.text = people.username
            cell?.fullName.text = "Full Name"
            
            cell?.address.text = ""
            cell?.distance.text = ""
            
            cell?.ID = people.uuid!
            cell?.checkFollow()
            cell?.interest.text = "Category"
        
            let placeHolderImage = UIImage(named: "empty_event")
            
            cell?.followButton.roundCorners(radius: 10)
            cell?.inviteButton.roundCorners(radius: 10)
            
            cell?.followButton.tag = indexPath.row
            cell?.followButton.addTarget(self, action: #selector(self.followUser), for: UIControlEvents.touchUpInside)
            
            cell?.inviteButton.tag = indexPath.row
            cell?.inviteButton.addTarget(self, action: #selector(self.inviteUser), for: UIControlEvents.touchUpInside)
            
            return cell!
        }
        else if tableView == self.place_tableView{
            
            let place = self.filtered_places[indexPath.row]
            
            let cell:SearchPlaceCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchPlaceCell!
            
            cell.searchVC = self
            
            cell.placeNameLabel.text = place.name
            
            if place.address.count > 0{
                if place.address.count == 1{
                    cell.addressTextView.text = "\(place.address[0])"
                }
                else{
                    cell.addressTextView.text = "\(place.address[0])\n\(place.address[1])"
                }
            }
            cell.placeID = place.id
            cell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) ratings)"
            cell.categoryLabel.text = place.categories[0].name
            cell.checkForFollow(id: place.id)
            let placeHolderImage = UIImage(named: "empty_event")
            cell.placeImage.sd_setImage(with: URL(string :place.image_url), placeholderImage: placeHolderImage)
            return cell
        }
        else{
            let event = self.filtered_events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchEventTableViewCell!
            
            cell?.name.text = event.title
            
            var addressComponents = event.fullAddress?.components(separatedBy: ",")
            let streetAddress = addressComponents?[0]
            
            addressComponents?.remove(at: 0)
            let city = addressComponents?.joined(separator: ", ")
            
            
            cell?.address.text = "\(streetAddress!)\n\(city!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))"
            cell?.address.textContainer.maximumNumberOfLines = 6
            
            
            cell?.guestCount.text = "\(event.attendeeCount) guests"
            cell?.interest.text = "Category"
            cell?.price.text = "Price"
            //cell.checkForFollow(id: event.id!)
            let placeHolderImage = UIImage(named: "empty_event")
            
            let reference = Constants.storage.event.child("\(event.id!).jpg")
            
            // Placeholder image
            _ = UIImage(named: "empty_event")
            
            reference.downloadURL(completion: { (url, error) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                cell?.eventImage?.sd_setImage(with: url, placeholderImage: placeHolderImage)
                
                cell?.eventImage?.setShowActivityIndicator(true)
                cell?.eventImage?.setIndicatorStyle(.gray)
                
            })
            
            //attending
            Constants.DB.event.child((event.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    cell?.attendButton.setTitle("Attending", for: UIControlState.normal)
                }
                
            })
            
            cell?.attendButton.roundCorners(radius: 10)
            cell?.inviteButton.roundCorners(radius: 10)
            
            cell?.attendButton.tag = indexPath.row
            cell?.attendButton.addTarget(self, action: #selector(self.attendEvent), for: UIControlEvents.touchUpInside)
            
            cell?.inviteButton.tag = indexPath.row
            cell?.inviteButton.addTarget(self, action: #selector(self.inviteUser), for: UIControlEvents.touchUpInside)
            
            return cell!
        }
        
    }
    
    func attendEvent(sender:UIButton){
        let buttonRow = sender.tag
        let event = self.events[buttonRow]
        
        if sender.title(for: .normal) == "Attend"{
            print("attending event \(event.title) ")
            
            Constants.DB.event.child((event.id)!).child("attendingList").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
            
            
            Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    let attendingAmount = value?["amount"] as! Int
                    Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount + 1])
                }
            })
            
            sender.setTitle("Attending", for: .normal)
        }
        else{
            Constants.DB.event.child((event.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                
                for (id,_) in value!{
                    Constants.DB.event.child("\(event.id!)/attendingList/\(id)").removeValue()
                }
                
            })
            
            Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    let attendingAmount = value?["amount"] as! Int
                    Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount - 1])
                }
            })
            
            sender.setTitle("Attend", for: .normal)
        }
        
    }
    
    
    func followUser(sender:UIButton){
        let buttonRow = sender.tag
        
        print("following user \(self.people[buttonRow].username) ")
    }
    
    func inviteUser(sender:UIButton){
        let buttonRow = sender.tag
        
        print("invite user \(self.people[buttonRow].username) ")
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
                if text.characters.count == 0{
                    self.events.append(event)
                }
            }
            self.event_tableView.reloadData()
        })
    }
}
