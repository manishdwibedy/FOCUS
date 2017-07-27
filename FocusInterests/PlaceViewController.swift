//
//  PlaceViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol CommentsDelegate {
    func gotComments(comments: [PlaceRating])
}

protocol SuggestPlacesDelegate {
    func gotSuggestedPlaces(places: [Place])
}

protocol SendInviteFromPlaceDetailsDelegate{
    func hasSentInvite()
}

class PlaceViewController: UIViewController, SendInviteFromPlaceDetailsDelegate{
    var commentsDelegate: CommentsDelegate?
    var suggestPlacesDelegate: SuggestPlacesDelegate?
    
    var place: Place?
    var rating = [PlaceRating]()
    var currentLocation: CLLocation?
    var map: MapViewController? = nil
    
    @IBOutlet weak var placeScrollView: UIScrollView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    
    @IBOutlet weak var pinViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var ratingBackground: UIView!
    
    @IBOutlet weak var invitePopupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var invitePopupView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var followersAmountLabel: UIButton!
    @IBOutlet weak var pinAmountLabel: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var distanceLabelInNavBar: UIButton!
    
    let screenSize = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var showInvitePopup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadPlace(place: self.place!)
        
        self.mapButton.setImage(UIImage(named: "Globe_White"), for: .normal)
        
        self.screenWidth = self.screenSize.width
        self.screenHeight = self.screenSize.height
        self.invitePopupView.center.y = self.screenHeight - 20
        self.invitePopupTopConstraint.constant = self.screenHeight - 20
        
        hideKeyboardWhenTappedAround()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showRating(sender:)))
        
        self.invitePopupView.allCornersRounded(radius: 10.0)
        
        self.topView.addTopBorderWithColor(color: UIColor.white, width: 1.0)
        
        self.placeImage.layer.borderWidth = 1.0
        self.placeImage.layer.borderColor = Constants.color.lightBlue.cgColor
        self.placeImage.roundedImage()
        
        self.followButton.setTitleColor(UIColor.white, for: .normal)
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.setTitleColor(UIColor.white, for: .selected)
        self.followButton.setTitle("Following", for: .selected)
        self.checkIfFollowing()
        
        self.followButton.roundCorners(radius: 5.0)
        self.inviteButton.roundCorners(radius: 5.0)
        self.reviewButton.roundCorners(radius: 5.0)
        self.pinButton.roundCorners(radius: 5.0)
        
        self.distanceLabelInNavBar.setTitleColor(UIColor.white, for: .normal)
        self.distanceLabelInNavBar.setTitleColor(UIColor.white, for: .selected)
        self.pinAmountLabel.setTitleColor(UIColor.white, for: .normal)
        self.pinAmountLabel.setTitleColor(UIColor.white, for: .selected)
        self.followersAmountLabel.setTitleColor(UIColor.white, for: .normal)
        self.followersAmountLabel.setTitleColor(UIColor.white, for: .selected)
        
        
        let placeLocation = CLLocation(latitude: Double((place?.latitude)!), longitude: Double((place?.longitude)!))
        
        self.distanceLabelInNavBar.setTitle(getDistance(fromLocation: AuthApi.getLocation()!, toLocation: placeLocation,addBracket: false, precision: 0), for: .normal)
        
        
        self.pinButton.setTitle("I\'m Here", for: .normal)
        self.pinButton.setTitleColor(UIColor.white, for: .normal)
        self.pinButton.setTitle("I\'m Here", for: .selected)
        self.pinButton.setTitleColor(Constants.color.navy, for: .selected)
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.view.backgroundColor = Constants.color.navy
        self.navigationBar.barTintColor = Constants.color.navy
        self.navigationBar.titleTextAttributes = attrs
        
        self.pinAmountLabel.setTitle("0", for: .normal)
        self.followersAmountLabel.setTitle("0", for: .normal)
        
        Constants.DB.places.child((place?.id)!).observeSingleEvent(of: .value, with: {snapshot in
            if let data = snapshot.value as? [String: Any]{
                if let pins = data["pins"] as? [String: Any]{
                    self.pinAmountLabel.setTitle("\(pins.count)", for: .normal)
                }
                else{
                    self.pinAmountLabel.setTitle("0", for: .normal)
                }
                
                if let following = data["following"] as? [String: Any]{
                    self.followersAmountLabel.setTitle("\(following.count)", for: .normal)
                }
                else{
                    self.followersAmountLabel.setTitle("0", for: .normal)
                }
            }
            else{
                self.pinAmountLabel.setTitle("0", for: .normal)
                self.followersAmountLabel.setTitle("0", for: .normal)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showPopup()
    }
    
    func showRating(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Reviews", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "reviews") as? ReviewsViewController
        VC?.place = place
        self.present(VC!, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.pinView.alpha = 1
//                self.ratingView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.pinView.alpha = 0
//                self.ratingView.alpha = 1
            })
        }
    }
    
    @IBAction func goBackToMap(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMapViewControllerWithSegue", sender: self)
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        sender.isSelected  = !sender.isSelected;
        
        if sender.isSelected == true{
            sender.layer.borderWidth = 1
            sender.layer.borderColor = UIColor.white.cgColor
            sender.backgroundColor = UIColor(red: 25/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
            
            let time = NSDate().timeIntervalSince1970
            Follow.followPlace(id: (place?.id)!)
            
        }else if sender.isSelected == false {
            
            let unfollowAlertController = UIAlertController(title: "Are you sure you want to unfollow \(self.place!.name)?", message: nil, preferredStyle: .actionSheet)
            
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                sender.layer.borderWidth = 0.0
                sender.backgroundColor = Constants.color.green
                
                Follow.unFollowPlace(id: (self.place?.id)!)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            self.present(unfollowAlertController, animated: true, completion: nil)
            
        }
    }

    func checkIfFollowing(){
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").queryOrdered(byChild: "placeID").queryEqual(toValue: place!.id).observeSingleEvent(of: .value, with: {snapshot in
            
            if let data = snapshot.value as? [String:Any]{
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor.white.cgColor
                self.followButton.backgroundColor = UIColor(red: 25/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
                self.followButton.isSelected = true
            }
            else{
                self.followButton.layer.borderWidth = 0.0
                self.followButton.backgroundColor = Constants.color.green
                self.followButton.isSelected = false
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinInfo"{
            let pin = segue.destination as! PinViewController
            pin.delegate = self
            pin.placeVC = self
            pin.place = self.place
            pin.averageReviewAmount = Double((self.place?.reviewCount)!)
            guard let ratingAmount = self.place?.rating else {
                pin.averageRatingAmount = 0.0
                return
            }
            
            pin.averageRatingAmount = Double(ratingAmount)

        }
        if segue.identifier == "unwindToMapViewControllerWithSegue"{
            let map = self.map
            if let place = place{
                if !(map?.places.contains(place))!{
                    map?.places.append(place)
                    
                    let position = CLLocationCoordinate2D(latitude: Double(place.latitude), longitude: Double(place.longitude))
                    let marker = GMSMarker(position: position)
                    marker.icon = UIImage(named: "place_icon")
                    marker.title = place.name
                    marker.map = map?.mapView
                    marker.isTappable = true
                    
                    let index = map?.places.count
                    marker.accessibilityLabel = "place_\(index!)"
                    
                    map?.placePins[place.id] = marker
                    
                    map?.placeMapping[place.id] = place
                    map?.getPlaceHours(id: place.id)
                    map?.places.append(place)
                    
                    map?.viewingPlace = place
                    
                    map?.currentLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
                    map?.willShowPlace = true
                    map?.tapPlace(place: place, marker: marker)
                    
                    map?.eventPlaceMarker = marker
                }
            }
        }
        else if segue.identifier == "rating"{
//            let rating = segue.destination as! RatingViewController
//            rating.placeVC = self
//            rating.place = self.place
//            rating.ratings = self.rating
        }
    }
    
    
    func loadPlace(place: Place){
//        self.title = place.name
        let titlelabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        titlelabel.text = place.name
        titlelabel.textColor = UIColor.white
        titlelabel.font = UIFont(name: "Avenir-Black", size: 18.0)
        titlelabel.backgroundColor = UIColor.clear
        titlelabel.adjustsFontSizeToFitWidth = false
        self.navigationBar.topItem?.titleView = titlelabel
    
        if let url = URL(string: place.image_url){
            placeImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_place"))
        }
        
        let ratingString = String(place.rating)
        
//        imageView.sd_setImage(with: URL(string: (place.image_url)), placeholderImage: nil)
        //self.getLatestComments()
        fetchSuggestedPlaces(token: AuthApi.getYelpToken()!)
        
    }
    
    func getLatestComments(){
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        comments.queryOrdered(byChild: "date").queryLimited(toLast: 5).observeSingleEvent(of: .value, with: {snapshot in
            
            if let comments = snapshot.value as? [String: [String: Any]]{
                for (_, comment) in comments.enumerated(){
                    print(comment.key)
                    let id = comment.value["user"] as! String
                    var commentText = comment.value["comment"] as! String
                    let rating = comment.value["rating"] as! Double
                    let date = comment.value["date"] as! Double
                    
                    if commentText.characters.count == 0{
                        commentText = "No comment was provided."
                    }
                    
                    let placeComment = PlaceRating(uid: id, date: Date(timeIntervalSince1970: date), rating: rating)
                    
                    Constants.DB.user.child(id).observeSingleEvent(of: .value, with: {snapshot in
                        let value = snapshot.value as! [String: Any]
                        let username = value["username"] as! String
                        placeComment.setUsername(username: username)
                        
                        self.commentsDelegate?.gotComments(comments: self.rating)
                    })
                    
                    
                    
                    if commentText.characters.count > 0{
                        placeComment.addComment(comment: commentText)
                    }
                    self.rating.append(placeComment)
                }
            }
            
            
        })
    }
    
    func fetchSuggestedPlaces(token: String){
        if let location = self.currentLocation{
            getNearbyPlaces(location: location)
        }
        else{
            let location = CLLocation(latitude: (self.place?.latitude)!, longitude: (self.place?.longitude)!)
            getNearbyPlaces(location: location)
        }
        
    }
    
    func getNearbyPlaces(location: CLLocation){
        let url = "https://api.yelp.com/v3/businesses/search"
        let categories = self.place?.categories.map { $0.alias }.joined(separator: ",")
        
        let parameters: [String: Any] = [
            "latitude" : Double(location.coordinate.latitude),
            "longitude" : Double(location.coordinate.longitude),
            "categories": categories!,
            "limit": 3
        ]
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(AuthApi.getYelpToken()!)",
            "cache-contro": "no-cache"
        ]
        
        Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
            var suggestedPlaces = [Place]()
            let json = JSON(data: response.data!)
            
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
                
                if !suggestedPlaces.contains(place){
                    suggestedPlaces.append(place)
                }
            }
            
            self.suggestPlacesDelegate?.gotSuggestedPlaces(places: suggestedPlaces)
        }
    }
    
    @IBAction func pinHerePressed(_ sender: Any) {
        self.pinButton.isSelected = !self.pinButton.isSelected
        if self.pinButton.isSelected{
            self.pinButton.backgroundColor = UIColor.white
        }else{
            self.pinButton.backgroundColor = Constants.color.green
        }
        self.pinButton.isSelected = !self.pinButton.isSelected
        if self.pinButton.isSelected{
            self.pinButton.backgroundColor = UIColor.white
        }else{
            self.pinButton.backgroundColor = Constants.color.green
        }
        
        let createEventStoryboard = UIStoryboard.init(name: "CreateEvent", bundle: nil)
        let createEventVC = createEventStoryboard.instantiateViewController(withIdentifier: "createEvent") as! CreateNewEventViewController
        
        createEventVC.specifiedLocationFromPlaceOrEventDetail = true
        self.present(createEventVC, animated: true, completion: nil)
    }
    
    @IBAction func reviewButon(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Reviews", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "Reviews") as! UINavigationController
        let reviewVC = ivc.viewControllers[0] as! ReviewsViewController
        reviewVC.place = self.place
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    @IBAction func inviteButtonClicked(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.id = self.place!.id
        ivc.place = place
        ivc.placeDetailsDelegate = self
        ivc.inviteFromPlaceDetails = true
        present(ivc, animated: true, completion: nil)
    }
    
    func showPopup(){
        if showInvitePopup {
            UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseInOut, animations: {
                self.invitePopupView.center.y -= self.invitePopupView.frame.size.height
                self.invitePopupTopConstraint.constant -= self.invitePopupView.frame.size.height
            }, completion: { animate in
                UIView.animate(withDuration: 1, delay: 3.0, options: .curveEaseInOut, animations: {
                    self.invitePopupView.center.y += self.invitePopupView.frame.size.height
                    self.invitePopupTopConstraint.constant += self.invitePopupView.frame.size.height
                }, completion: nil)
            })
            self.showInvitePopup = false
        }
    }
    
    func hasSentInvite(){
        print("have sent invite to this place!")
        self.showInvitePopup = true
    }
    
}
