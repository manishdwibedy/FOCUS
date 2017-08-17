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
import GooglePlaces
import DataCache

protocol InvitePeopleViewControllerDelegate {
    func showPopupView()
}

class InvitePeopleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, gotLocationDelegate, InvitePeopleViewControllerDelegate{

    @IBOutlet weak var animationGif: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedOut: UISegmentedControl!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var currentLocation: UITextField!
    
    @IBOutlet weak var invitePopupViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var invitePopupView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var poweredByYelpImage: UIImageView!
    
    var pinData: pinData? = nil
    var showInvitePopup = false
    var selectedLocation = false
    var isMeetup = false
    var inviteFromMapView = false
    var inviteFromOtherUserProfile = false
    var UID = ""
    var username = ""
    var clearSearch = false
    
    var filtered = [Any]()
    var places = [Place]()
    var placeMapping = [String: Place]()
    
    var attendingEvent = [Event]()
    var events = [Event]()
    
    
    var location: CLLocation?
    var searchPeople: SearchPeopleViewController? = nil
    var otherUserProfile: OtherUserProfileViewController? = nil
    var mapView: MapViewController? = nil
    
    
    var otherUserProfileDelegate: OtherUserProfileViewControllerDelegate?
    var searchPeopleDelegate: SearchPeopleViewControllerDelegate?
    
    let locationManager = CLLocationManager()
    
    var place: GMSPlace? = nil
    
    var followingPlaces = [Place]()
    var otherFollowingPlaces: [Place]? = nil
    
    var attendingEvents: [Event]? = nil
    var followingAttendingEvents: [Event]? = nil
    var otherAttendingEvents: [Event]? = nil
    var otherEvents: [Event]? = nil
    
    var ticketMasterDF = DateFormatter()
    var eventDF = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        MARK: Location Manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

//        MARK: Table View
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 6
        tableView.clipsToBounds = true
        let nib = UINib(nibName: "InvitePeoplePlaceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InvitePeoplePlaceCell")
        
        let nib2 = UINib(nibName: "InvitePeopleEventCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "InvitePeopleEventCell")
        
//        MARK: Event and Location Bars
        self.currentLocation.backgroundColor = UIColor(red: 38/255.0, green: 83/255.0, blue: 126/255.0, alpha: 1.0)
        self.currentLocation.attributedPlaceholder = NSAttributedString(string: "Current Location", attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        let locationImageView = UIImageView(image: #imageLiteral(resourceName: "location").withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        locationImageView.backgroundColor = UIColor.white
        self.currentLocation.leftView = locationImageView
        
        self.searchBar.delegate = self
        // search bar attributes
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!]
        let cancelButtonsInSearchBar: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!]
        
//        MARK: Event Search Bar
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = UIColor.white
        self.searchBar.barTintColor = UIColor.white
        
        self.searchBar.clipsToBounds = true
        
        self.searchBar.setValue("Cancel", forKey:"_cancelButtonText")
        
        if let textFieldInsideSearchBar = self.searchBar.value(forKey: "_searchField") as? UITextField{
            let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
            
            textFieldInsideSearchBar.attributedPlaceholder = attributedPlaceholder
            textFieldInsideSearchBar.textColor = UIColor.white
            textFieldInsideSearchBar.backgroundColor = UIColor(red: 38/255.0, green: 83/255.0, blue: 126/255.0, alpha: 1.0)
            
            let glassIconView = textFieldInsideSearchBar.leftView as! UIImageView
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = UIColor.white
            
            textFieldInsideSearchBar.clearButtonMode = .whileEditing
            let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as! UIButton
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            clearButton.tintColor = UIColor.white
        }
        
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonsInSearchBar, for: .normal)
        
//        MARK: Segmented Control
        self.segmentedOut.layer.cornerRadius = 5
        self.segmentedOut.layer.borderColor = UIColor.white.cgColor
        self.segmentedOut.layer.borderWidth = 1.0
        self.segmentedOut.layer.masksToBounds = true
        
        if self.segmentedOut.selectedSegmentIndex == 0{
            self.createEventButton.isHidden = true
            self.poweredByYelpImage.isHidden = false
            self.tableViewBottomConstraint.constant = 35
        }
        
        let sortedViews = segmentedOut.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        sortedViews[0].tintColor = Constants.color.green
        sortedViews[0].backgroundColor = UIColor.white
        
        sortedViews[1].tintColor = UIColor.white
        sortedViews[1].backgroundColor = UIColor.gray
        
//        MARK: Nav Bar
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.view.backgroundColor = Constants.color.navy
        navBar.barTintColor = Constants.color.navy
        navBar.titleTextAttributes = attrs
        
        if isMeetup || inviteFromOtherUserProfile || inviteFromMapView{
            navBar.topItem?.title = "Meet up"
            self.backButton.isEnabled = true
            self.backButton.tintColor = UIColor.white
            self.createEventButton.isHidden = true
        }else{
            self.backButton.isEnabled = false
            self.backButton.tintColor = UIColor.clear
        }
        
//        MARK: Main View
        self.invitePopupView.layer.cornerRadius = 10.0
        self.view.backgroundColor = Constants.color.navy
        
        currentLocation.delegate = self
        hideKeyboardWhenTappedAround()
        
        ticketMasterDF.dateFormat = "yyyy-MM-dd HH:mm:ss"
        eventDF.dateFormat = "MMM d, hh:mm a"
        
        if let data = self.pinData{
            currentLocation.text = data.locationAddress.components(separatedBy: ";;")[0]
        }
        
        
        
        if isMeetup{
            getFollowingPlace(uid: UID, gotPlaces: {places in
                self.otherFollowingPlaces = places
                
                if self.followingPlaces != nil{
                    
                    var uniquePlaces = self.places
                    for place in self.followingPlaces{
                        if !uniquePlaces.contains(place){
                            uniquePlaces.append(place)
                        }
                    }
                    
                    for place in self.otherFollowingPlaces!{
                        if !uniquePlaces.contains(place){
                            uniquePlaces.append(place)
                        }
                    }
                    
                    
                    self.places = uniquePlaces
                    
                    self.filtered = self.places
                    self.tableView.reloadData()
                }
            })
        }
        
        
        getAttendingEvent(uid: AuthApi.getFirebaseUid()!, gotEvents: {events in
            self.attendingEvents = events
            
            if self.followingAttendingEvents != nil && self.otherEvents != nil{
                var uniqueEvents = self.attendingEvents!
                
                for event in self.followingAttendingEvents!{
                    if !uniqueEvents.contains(event){
                        uniqueEvents.append(event)
                    }
                }
                
                if !self.isMeetup, let otherAttendingEvents = self.otherAttendingEvents{
                    for event in otherAttendingEvents{
                        if !uniqueEvents.contains(event){
                            uniqueEvents.append(event)
                        }
                    }
                }
                for event in self.events{
                    if !uniqueEvents.contains(event){
                        uniqueEvents.append(event)
                    }
                }
                
                let events = uniqueEvents + self.otherEvents!
                self.events = events.sorted(by: {
                    if $0.category == $1.category{
                        return $0.distance < $1.distance
                    }
                    else{
                        return $0.category! < $1.category!
                    }
                })
                
                
                self.tableView.reloadData()
            }
        })
        
        getFollowingAttendingEvent(uid: AuthApi.getFirebaseUid()!, gotEvents: {events in
            self.followingAttendingEvents = events
            
            if self.attendingEvents != nil && self.otherEvents != nil{
                var uniqueEvents = self.attendingEvents!
                
                for event in self.followingAttendingEvents!{
                    if !uniqueEvents.contains(event){
                        uniqueEvents.append(event)
                    }
                }
                
                if !self.isMeetup, let otherAttendingEvents = self.otherAttendingEvents{
                    for event in otherAttendingEvents{
                        if !uniqueEvents.contains(event){
                            uniqueEvents.append(event)
                        }
                    }
                }
                
                for event in self.events{
                    if !uniqueEvents.contains(event){
                        uniqueEvents.append(event)
                    }
                }
                
                self.events = uniqueEvents + self.otherEvents!
                self.tableView.reloadData()
            }
        })
        
        if isMeetup{
            getAttendingEvent(uid: UID, gotEvents: {events in
                self.otherAttendingEvents = events
                
                if self.followingAttendingEvents != nil && self.otherEvents != nil{
                    var uniqueEvents = self.attendingEvents!
                    
                    for event in self.followingAttendingEvents!{
                        if !uniqueEvents.contains(event){
                            uniqueEvents.append(event)
                        }
                    }
                    
                    if let otherAttendingEvents = self.otherAttendingEvents{
                        for event in otherAttendingEvents{
                            if !uniqueEvents.contains(event){
                                uniqueEvents.append(event)
                            }
                        }
                    }
                    
                    for event in self.events{
                        if !uniqueEvents.contains(event){
                            uniqueEvents.append(event)
                        }
                    }
                    
                    self.events = uniqueEvents + self.otherEvents!
                    self.tableView.reloadData()
                }
            })
        }

        
//        if !isMeetup{
//            getFollowingPlace(uid: AuthApi.getFirebaseUid()!, gotPlaces: {places in
//                self.followingPlaces = places.sorted(by: {
//                    $0.distance < $1.distance
//                })
//                
//                if self.otherFollowingPlaces != nil{
//                    if self.isMeetup{
//                        var uniquePlaces = self.places
//                        for place in self.followingPlaces{
//                            if !uniquePlaces.contains(place){
//                                uniquePlaces.append(place)
//                            }
//                        }
//                        
//                        for place in self.otherFollowingPlaces!{
//                            if !uniquePlaces.contains(place){
//                                uniquePlaces.append(place)
//                            }
//                        }
//                        
//                        
//                        self.places = uniquePlaces
//                        
//                        self.filtered = self.places
//                        self.tableView.reloadData()
//                    }
//                    else{
//                        self.places = self.followingPlaces + self.places
//                        self.filtered = self.places
//                        self.tableView.reloadData()
//                    }
//                    
//                    self.updatePlaces()
//                }
//                if !self.isMeetup{
//                    self.followingPlaces = self.followingPlaces.sorted(by: {
//                        $0.distance < $1.distance
//                    })
//                    self.places = self.followingPlaces + self.places
//                    
//                    self.filtered = self.places
//                    self.tableView.reloadData()
//                }
//                
//                if self.segmentedOut.selectedSegmentIndex == 0{
//                    self.updatePlaces()
//                }
//            })
//            
//            getAttendingEvent(uid: AuthApi.getFirebaseUid()!, gotEvents: {events in
//                self.attendingEvents = events
//                
//                if self.followingAttendingEvents != nil && self.otherEvents != nil{
//                    var uniqueEvents = self.attendingEvents!
//                    
//                    for event in self.followingAttendingEvents!{
//                        if !uniqueEvents.contains(event){
//                            uniqueEvents.append(event)
//                        }
//                    }
//                    
//                    if !self.isMeetup, let otherAttendingEvents = self.otherAttendingEvents{
//                        for event in otherAttendingEvents{
//                            if !uniqueEvents.contains(event){
//                                uniqueEvents.append(event)
//                            }
//                        }
//                    }
//                    for event in self.events{
//                        if !uniqueEvents.contains(event){
//                            uniqueEvents.append(event)
//                        }
//                    }
//                    
//                    let events = uniqueEvents + self.otherEvents!
//                    self.events = events.sorted(by: {
//                        if $0.category == $1.category{
//                            return $0.distance < $1.distance
//                        }
//                        else{
//                            return $0.category! < $1.category!
//                        }
//                    })
//                    
//                    
//                    self.tableView.reloadData()
//                }
//            })
//            
//            getFollowingAttendingEvent(uid: AuthApi.getFirebaseUid()!, gotEvents: {events in
//                self.followingAttendingEvents = events
//                
//                if self.attendingEvents != nil && self.otherEvents != nil{
//                    var uniqueEvents = self.attendingEvents!
//                    
//                    for event in self.followingAttendingEvents!{
//                        if !uniqueEvents.contains(event){
//                            uniqueEvents.append(event)
//                        }
//                    }
//                    
//                    if !self.isMeetup, let otherAttendingEvents = self.otherAttendingEvents{
//                        for event in otherAttendingEvents{
//                            if !uniqueEvents.contains(event){
//                                uniqueEvents.append(event)
//                            }
//                        }
//                    }
//                    
//                    for event in self.events{
//                        if !uniqueEvents.contains(event){
//                            uniqueEvents.append(event)
//                        }
//                    }
//                    
//                    self.events = uniqueEvents + self.otherEvents!
//                    self.tableView.reloadData()
//                }
//            })
//        }
//        else{
//            getFollowingPlace(uid: UID, gotPlaces: { placesUserFollows in
//                print(placesUserFollows)
//                let user_interest_set = Set<Place>(self.followingPlaces)
//                let other_user = Set<Place>(placesUserFollows)
//                
//                let common = Array(other_user.intersection(user_interest_set))
//                if common.count > 0{
//                    self.places = Array(common)
//                    self.tableView.reloadData()
//                }
//                else{
//                    self.places.append(contentsOf: placesUserFollows)
//                    self.places.append(contentsOf: self.followingPlaces)
//                    
//                    Constants.DB.user.child(self.UID).observeSingleEvent(of: .value, with: {snapshot in
//                        if let data = snapshot.value as? [String:Any]{
//                            if let interests = data["interests"] as? String{
//                                
//                                var categories = [String]()
//                                for interest in interests.components(separatedBy: ","){
//                                    let interest_name = interest.components(separatedBy: "-")[0]
//                                    categories.append(interest_name)
//                                }
//                                
//                                getSuggestedPlaces(interests: categories.joined(separator: ","), limit: 30, gotPlaces: {places in
//                                    self.places.append(contentsOf: places)
//                                    
//                                    
//                                    if self.segmentedOut.selectedSegmentIndex == 0{
//                                        self.filtered = self.places
//                                    }
//                                    self.tableView.reloadData()
//                                    
//                                })
//                                
//                                
//                            }
//                        }
//                    })
//                }
//            })
//            
//            
//            getAttendingEvent(uid: UID, gotEvents: { eventsUserAttends in
//                let user_interest_set = Set<Event>(self.attendingEvent)
//                let other_user = Set<Event>(eventsUserAttends)
//                
//                let common = Array(other_user.intersection(user_interest_set))
//                if common.count > 0{
//                    self.events = Array(common)
//                }
//                else{
//                    self.events.append(contentsOf: self.attendingEvent)
//                    
//                    Constants.DB.user.child(self.UID).observeSingleEvent(of: .value, with: {snapshot in
//                        if let data = snapshot.value as? [String:Any]{
//                            if let interests = data["interests"] as? String{
//                                
//                                var categories = [String]()
//                                for interest in interests.components(separatedBy: ","){
//                                    let interest_name = interest.components(separatedBy: "-")[0]
//                                    categories.append(interest_name)
//                                }
//                                
//                                getSuggestedEvents(interests: categories.joined(separator: ","), limit: 30, gotEvents: {events in
//                                    self.events.append(contentsOf: events)
//                                    
//                                    
//                                    if self.segmentedOut.selectedSegmentIndex == 0{
//                                        self.filtered = self.events
//                                    }
//                                    self.tableView.reloadData()
//                                    
//                                })
//                                
//                                
//                            }
//                        }
//                    })
//                }
//            })
//        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.places = (DataCache.instance.readObject(forKey: "places") as? [Place])!
        self.followingPlaces = (DataCache.instance.readObject(forKey: "following_places") as? [Place])!
        self.events = (DataCache.instance.readObject(forKey: "events") as? [Event])!

        self.updatePlaces()
        
        if clearSearch{
            searchBar.text = ""
            self.currentLocation.text = "Current Location"
            
            if segmentedOut.selectedSegmentIndex == 0{
                self.filtered =  self.followingPlaces + self.places
                
                self.tableView.reloadData()
            }
            else{
                self.filtered = self.events
                self.tableView.reloadData()
            }
            clearSearch = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        self.location = location
        
        print("got location")
        locationManager.stopUpdatingLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.segmentedOut.selectedSegmentIndex == 0{
            self.filtered = self.followingPlaces + self.filtered
            self.tableView.reloadData()
        }
        else{
            self.filtered = self.attendingEvent + self.filtered
            self.tableView.reloadData()
        }
        
        if showInvitePopup {
            self.invitePopupView.isHidden = false
            UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.invitePopupView.center.y -= 125
                self.invitePopupViewBottomConstraint.constant += 125
            }, completion: { animate in
                UIView.animate(withDuration: 1.5, delay: 3.0, options: .curveEaseInOut, animations: {
                    self.invitePopupView.center.y += 125
                    self.invitePopupViewBottomConstraint.constant -= 125
                }, completion: nil)
            })
            self.showInvitePopup = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func segmentedChanged(_ sender: Any) {
        searchBar.text = nil
        if segmentedOut.selectedSegmentIndex == 0{
            self.filtered = self.places
            tableView.reloadData()
            self.createEventButton.isHidden = true
            self.poweredByYelpImage.isHidden = false
            self.tableViewBottomConstraint.constant = 35
        }else if segmentedOut.selectedSegmentIndex == 1{
            self.filtered = self.events
            tableView.reloadData()
            
            if isMeetup || inviteFromOtherUserProfile || inviteFromMapView{
                self.createEventButton.isHidden = true
            }else{
                self.createEventButton.isHidden = false
            }
            
            self.poweredByYelpImage.isHidden = true
            self.tableViewBottomConstraint.constant = 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedOut.selectedSegmentIndex == 0
        {
            let cell:InvitePeoplePlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "InvitePeoplePlaceCell") as! InvitePeoplePlaceCell!
            
            let place_cell = filtered[indexPath.row] as! Place
            cell.place = place_cell
            cell.placeNameLabel.text = place_cell.name
           // cell.place = place
            
            if place_cell.address.count > 0{
                if place_cell.address.count == 1{
                    cell.addressTextView.text = "\(place_cell.address[0])"
                }
                else{
                    cell.addressTextView.text = "\(place_cell.address[0])\n\(place_cell.address.last!)"
                }
            }
            
            cell.setRatingAmount(ratingAmount: Double(place_cell.rating))
            
            cell.ratingLabel.text = "\(place_cell.rating) (\(place_cell.reviewCount) reviews)"
            
            let date = Date()
            let calendar = Calendar.current
            
            let day = calendar.component(.weekday, from: date)
            
            if !place_cell.is_closed{
                if let hour = place_cell.getHour(day: day){
                    cell.dateAndTimeLabel.text = "\(convert24HourTo12Hour(hour.start)) - \(convert24HourTo12Hour(hour.end))"
                }
            }
            else{
                cell.dateAndTimeLabel.text = "Closed"
            }
            
            let place_location = CLLocation(latitude: place_cell.latitude, longitude: place_cell.longitude)
            
            if self.place != nil{
                let location = CLLocation(latitude: (self.place?.coordinate.latitude)!, longitude: (self.place?.coordinate.longitude)!)
                cell.distanceLabel.text = getDistance(fromLocation: place_location, toLocation:
                location)
                
            }
            else{
                if let data = self.pinData{
                    let current = CLLocation(latitude: data.coordinates.latitude, longitude: data.coordinates.longitude)
                    cell.distanceLabel.text = getDistance(fromLocation: place_location, toLocation: current)
                }
                else{
                    cell.distanceLabel.text = getDistance(fromLocation: place_location, toLocation: AuthApi.getLocation()!)
                }
            }
            
            if place_cell.categories.count > 0{
                addGreenDot(label: cell.categoryLabel, content: getInterest(yelpCategory: place_cell.categories[0].alias))
            }
        
            
            cell.checkForFollow()
            if let url = URL(string: place_cell.image_url){
                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                    (receivedSize :Int, ExpectedSize :Int) in
                    
                }, completed: {
                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                    
                    if image != nil && finished{
                        cell.placeImage.image = crop(image: image!, width: 50, height: 50)
                    }
                })
                
            }
            
            cell.isMeetup = self.isMeetup
            cell.inviteFromOtherUserProfile = self.inviteFromOtherUserProfile
            cell.UID = UID
            cell.username = username
            cell.parentVC = self
            cell.invitePeopleVCDelegate = self
            
            return cell
        }else{
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
            
            cell.isMeetup = self.isMeetup
            cell.inviteFromOtherUserProfile = self.inviteFromOtherUserProfile
            cell.event = event
            cell.UID = UID
            cell.username = username
            cell.invitePeopleVCDelegate = self
            cell.parentVC = self
            
            if isMeetup || event.attendeeCount < 20{
                cell.guestCount.isHidden = true
            }else{
                cell.guestCount.isHidden = false
                cell.guestCount.text = "\(event.attendeeCount) guests"
            }
            
            
            if let date = self.ticketMasterDF.date(from: event.date!){
                cell.dateAndTimeLabel.text = eventDF.string(from: date)
            }
            else{
                cell.dateAndTimeLabel.text = event.date!
            }
            
//            Date formatter for date and time label in event
            cell.price.text = event.price == nil || event.price == 0 ? "Free" : "$\(event.price!)"
            
            let eventLocation = CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
            
            if self.place != nil{
                let location = CLLocation(latitude: (self.place?.coordinate.latitude)!, longitude: (self.place?.coordinate.longitude)!)
                cell.distance.text = getDistance(fromLocation: eventLocation, toLocation:
                    location)
                
            }
            else{
                cell.distance.text = getDistance(fromLocation: eventLocation, toLocation: AuthApi.getLocation()!)
                
            }
            
            if (event.creator?.characters.count)! > 0{
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
            }
            else{
                if let url = URL(string: event.image_url!){
                    SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                        (receivedSize :Int, ExpectedSize :Int) in
                        
                    }, completed: {
                        (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                        
                        if image != nil && finished{
                            cell.eventImage.image = crop(image: image!, width: 50, height: 50)
                        }
                    })
                }
                
            }
            
            cell.checkIfAttending()
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
            return 115
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if segmentedOut.selectedSegmentIndex == 0
        {
            self.searchPlaces(query: searchText)
        }
        else if segmentedOut.selectedSegmentIndex == 1
        {
            self.searchEvents(query: searchText)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if segmentedOut.selectedSegmentIndex == 0
        {
            self.searchPlaces(query: searchBar.text!)
        }
        else if segmentedOut.selectedSegmentIndex == 1
        {
            self.searchEvents(query: searchBar.text!)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchBar.setShowsCancelButton(false, animated: true)
        if segmentedOut.selectedSegmentIndex == 0{
            self.filtered = self.places
            self.tableView.reloadData()
        }
        else{
            self.filtered = self.events
            self.tableView.reloadData()
        }
        searchBar.resignFirstResponder()
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
    
    @IBAction func createEventButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func updatePlaces()
    {
        let url = "https://api.yelp.com/v3/businesses/search"
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(AuthApi.getYelpToken()!)",
            "cache-contro": "no-cache"
        ]
        
        var parameters = [String:Any]()
        if self.place != nil {
            parameters = [
                "latitude": self.place?.coordinate.latitude,
                "longitude": self.place?.coordinate.longitude
                ] as [String : Any]
        }
        else{
            parameters = [
                "latitude": location?.coordinate.latitude ?? 0,
                "longitude": location?.coordinate.longitude ?? 0,
                ] as [String : Any]
        }
        
        
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
                
                let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
                
                if !self.places.contains(place){
                    self.places.append(place)
                }
            }
            
            if self.segmentedOut.selectedSegmentIndex == 0
            {
                self.filtered = self.followingPlaces + self.places
            }
            self.tableView.reloadData()
        }
    }
}

extension InvitePeopleViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let chooseLocationVC = ChooseLocationViewController(nibName: "ChooseLocationViewController", bundle: nil)
        chooseLocationVC.delegate = self
        self.present(chooseLocationVC, animated: true, completion: nil)
    }
}

extension InvitePeopleViewController: GMSAutocompleteViewControllerDelegate {
    
    func createGMSViewController() -> GMSAutocompleteViewController{
        let autoCompleteController = GMSAutocompleteViewController()
        
        let filter = GMSAutocompleteFilter()
        filter.country = "US"
        
        autoCompleteController.autocompleteFilter = filter
        
        autoCompleteController.delegate = self
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        //        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 17)!
        ]
        
        let placeholderTextAttributes: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = placeholderAttributes
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = placeholderTextAttributes
        
        autoCompleteController.primaryTextColor = UIColor.white
        autoCompleteController.primaryTextHighlightColor = Constants.color.green
        autoCompleteController.secondaryTextColor = UIColor.white
        autoCompleteController.tableCellBackgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
        autoCompleteController.tableCellSeparatorColor = UIColor.white
        
        return autoCompleteController
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.place = place
        
        var first = [String]()
        var second = [String]()
        
        var isPlace = true
        //locality;admin area level 1; postal code
        for a in place.addressComponents!{
            if a.type == "street_number"{
                first.append(a.name)
                isPlace = false
            }
            if a.type == "route"{
                first.append(a.name)
                isPlace = false
            }
            
            if a.type == "locality"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "administrative_area_level_1"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "postal_code"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "premise"{
                first.append(a.name)
                break
            }
        }
        
        if isPlace{
            second = first
            
            self.currentLocation.text = "\(place.name)"
        }
        else{
            self.currentLocation.text = "\(first.joined(separator: " "))"
        }
     
        if segmentedOut.selectedSegmentIndex == 0
        {
            self.searchPlaces(query: searchBar.text!)
        }
        else if segmentedOut.selectedSegmentIndex == 1
        {
            self.searchEvents(query: searchBar.text!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getPlaceHours(id: String){
        if let token = AuthApi.getYelpToken(){
            let url = "https://api.yelp.com/v3/businesses/\(id)"
            
            let headers: HTTPHeaders = [
                "authorization": "Bearer \(token)",
                "cache-contro": "no-cache"
            ]
            
            Alamofire.request(url, method: .get, parameters:nil, headers: headers).responseJSON { response in
                let json = JSON(data: response.data!)
                let place = self.placeMapping[id]
                
                if json["hours"].arrayValue.count > 0{
                    let open_hours = json["hours"].arrayValue[0].dictionaryValue
                    var hours = [Hours]()
                    for hour in (open_hours["open"]?.arrayValue)!{
                        let hour = Hours(start: hour["start"].stringValue, end: hour["end"].stringValue, day: hour["day"].intValue)
                        hours.append(hour)
                    }
                    
                    place?.setHours(hours: hours)
                }
                place?.set_is_open(is_open: json["hours"][0]["is_open_now"].boolValue)
            }
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // to do: handle error
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        viewController.autocompleteFilter?.country = "US"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        viewController.autocompleteFilter?.country = "US"
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func showPopupView() {
        print("back in invitepeoplevc")
        self.showInvitePopup = true
    }
}

extension InvitePeopleViewController{
    func searchPlaces(query: String){
        if(query.characters.count > 0){
            let url = "https://api.yelp.com/v3/businesses/search"
            
            let headers: HTTPHeaders = [
                "authorization": "Bearer \(AuthApi.getYelpToken()!)",
                "cache-contro": "no-cache"
            ]
            
            var parameters = [String:Any]()
            if self.place != nil {
                parameters = [
                    "latitude": self.place?.coordinate.latitude,
                    "longitude": self.place?.coordinate.longitude,
                    "term": query
                    ] as [String : Any]
            }
            else{
                if let data = self.pinData{
                    currentLocation.text = data.locationAddress.components(separatedBy: ";;")[0]
                    
                    parameters = [
                        "latitude": data.coordinates.latitude ?? 0,
                        "longitude": data.coordinates.longitude ?? 0,
                        "term": query
                        ] as [String : Any]
                }
                else{
                    parameters = [
                        "latitude": location?.coordinate.latitude ?? 0,
                        "longitude": location?.coordinate.longitude ?? 0,
                        "term": query
                        ] as [String : Any]
                }
            }
            
            Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
                let json = JSON(data: response.data!)
                print(json)
                _ = self.places.count
                
                self.filtered.removeAll()
                
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
                    
                    let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
                    
                    self.placeMapping[place.id] = place
                    self.getPlaceHours(id: place.id)
                    self.filtered.append(place)
                }
                
                let filteredArray = self.followingPlaces.filter() {
                    if let name = $0.name as? String{
                        return name.hasPrefix(query)
                    } else {
                        return false
                    }
                }
                
                self.filtered = filteredArray + self.filtered
                self.tableView.reloadData()
            }
        }
        else{
            self.filtered = self.places
            self.tableView.reloadData()
        }
    }
    
    func searchEvents(query: String){
        if(query.characters.count > 0){
            let DF = DateFormatter()
            DF.dateFormat = "MMM d, h:mm a"
            
            let dateOnlyDF = DateFormatter()
            dateOnlyDF.dateFormat = "yyyy-MM-dd "
            
            Constants.DB.event.queryOrdered(byChild: "title_lowered").queryStarting(atValue: query.lowercased()).queryEnding(atValue: query.lowercased()+"\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.filtered.removeAll()
                if let value = value
                {
                    for (id, event) in value
                    {
                        if let info = event as? [String:Any]{
                            let event = Event.toEvent(info: info)
                            event?.id = id as? String
                            
                            //                            if DF.date(from: (event?.date!)!)! > Date() && !(event?.privateEvent)!{
                            self.filtered.append(event)
                            //                            }
                            
                        }
                        
                    }
                    
                    let filteredArray = self.attendingEvent.filter() {
                        if let name = $0.title as? String{
                            return name.hasPrefix(query)
                        } else {
                            return false
                        }
                    }
                    
                    self.filtered = filteredArray + self.filtered
                    self.tableView.reloadData()
                }
                
            })
            
            if self.place != nil {
                Event.getNearyByEvents(query: query, location: (self.place?.coordinate)!, gotEvents: {events in
                    var DF = DateFormatter()
                    DF.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    self.filtered = self.filtered + events.sorted(by: {
                        let date1 = DF.date(from: $0.0.date!)
                        let date2 = DF.date(from: $0.1.date!)
                        return date1! < date2!
                    })
                    self.tableView.reloadData()
                })
            }
            else{
                Event.getNearyByEvents(query: query, location: (AuthApi.getLocation()?.coordinate)!, gotEvents: {events in
                    let DF = DateFormatter()
                    DF.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    
                    self.filtered = self.filtered + events.sorted(by: {
                        var date1:Date?, date2:Date?
                        if let date = DF.date(from: $0.0.date!){
                            date1 = date
                        }
                        else if let date = dateOnlyDF.date(from: $0.0.date!){
                            date1 = date
                        }
                        if let date = DF.date(from: $0.1.date!){
                            date2 = date
                        }
                        else if let date = dateOnlyDF.date(from: $0.1.date!){
                            date2 = date
                        }
                        
                        return date1! < date2!
                    })

                    self.tableView.reloadData()
                })
            }
            
        }
        else{
            self.filtered = self.events
            self.tableView.reloadData()
        }
    }
    
    @IBAction func unwindBackToExplorePage(_ sender: UIStoryboardSegue){
        self.showPopupView()
    }
    
    func gotSelectedLocation(location: LocationSuggestion) {
        self.selectedLocation = true
        self.location = CLLocation(latitude: location.lat, longitude: location.long)
        self.currentLocation.text = location.name
    }
}


