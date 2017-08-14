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
import MapKit
import SDWebImage

protocol CommentsDelegate {
    func gotComments(comments: [PlaceRating])
}

protocol SuggestPlacesDelegate {
    func gotSuggestedPlaces(places: [Place])
}

protocol SendInviteFromPlaceDetailsDelegate{
    func hasSentInvite()
}

class PlaceViewController: UIViewController, InviteUsers,UITableViewDelegate,UITableViewDataSource,SendInviteFromPlaceDetailsDelegate, UITextViewDelegate{
    
    var commentsDelegate: CommentsDelegate?
    var suggestPlacesDelegate: SuggestPlacesDelegate?
    var suggestedPlaces = [Place]()
    
    var place: Place?
    var rating = [PlaceRating]()
    var selectedCommentRating = 0
    var currentLocation: CLLocation?
    var map: MapViewController? = nil
    var delegate: showMarkerDelegate?
    var data = [NSDictionary]()
    var isFollowing = false
    var place_focus = ""
    var pinDF = DateFormatter()
    
    var ratingID: String?
    var starRatingTag: Int? = nil
    var showInvitePopup = false
    
    
    @IBOutlet weak var mainStackView: UIStackView!
//    nav bar
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var distanceLabelInNavBar: UIButton!
    @IBOutlet weak var mapButton: UIButton!

//    invite popup
    @IBOutlet weak var invitePopupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var invitePopupView: UIView!
    let screenSize = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
//    scroll view
    @IBOutlet weak var placeScrollView: UIScrollView!
    
//    top view
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var followersAmountLabel: UIButton!
    @IBOutlet weak var pinAmountLabel: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    
    
    // reviews stack
    @IBOutlet weak var reviewsStack: UIStackView!
    @IBOutlet weak var reviewsTextView: UITextView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var writeReviewView: UITextView!
    @IBOutlet weak var starRatingView: UIView!
    @IBOutlet weak var postReviewSeciontButton: UIButton!
    
    // place info stack
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewScreenHeight: NSLayoutConstraint!
        // basic info screen
        @IBOutlet weak var phoneLabel: UILabel!
        @IBOutlet weak var cityStateLabel: UILabel!
        @IBOutlet weak var streetAddress: UILabel!
    
    
        @IBOutlet weak var reviewStars: UIImageView!
        @IBOutlet weak var reviewAmountButton: UIButton!
        var averageRatingAmount = 0.0
        var averageReviewAmount = 0.0
    
    
        // location info
        @IBOutlet weak var hoursStackView: UIStackView!
        @IBOutlet weak var starsUberAndHoursStack: UIStackView!
        @IBOutlet weak var yelpButton: UIButton!
        @IBOutlet weak var uberButton: UIButton!
        @IBOutlet weak var googleMapButton: UIButton!
    
    
    // invite stack
    @IBOutlet weak var inviteUserStackView: UIStackView!
    @IBOutlet weak var inviteView: UIView!
    
    // pins stack
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var pinStackView: UIStackView!
    @IBOutlet weak var pinTableView: UITableView!
    @IBOutlet weak var pinTableHeightConstraint: NSLayoutConstraint!
    
    // people also liked stack
    @IBOutlet weak var peopleAlsoLikedStack: UIView!
    @IBOutlet weak var peopleAlsoLikedStackHeight: NSLayoutConstraint!
    @IBOutlet weak var peopleAlsoLikedTableView: UITableView!
    @IBOutlet weak var peopleAlsoLikeTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadPlace(place: self.place!)
        
        self.mapButton.setImage(UIImage(named: "Globe_White"), for: .normal)
        
        self.screenWidth = self.screenSize.width
        self.screenHeight = self.screenSize.height
        self.invitePopupView.center.y = self.screenHeight-20
        self.invitePopupTopConstraint.constant = self.screenHeight-20
        self.invitePopupView.layer.cornerRadius = 10.0
        
        self.mainStackView.removeArrangedSubview(self.reviewsStack)
        self.reviewsStack.isHidden = true
        self.reviewButton.setTitle("Review", for: .normal)
        self.reviewButton.setTitleColor(UIColor.white, for: .normal)
        self.reviewButton.setTitle("Review", for: .selected)
        self.reviewButton.setTitleColor(UIColor.white, for: .selected)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showRating(sender:)))
        
        
        self.placeImage.layer.borderWidth = 1.0
        self.placeImage.layer.borderColor = Constants.color.lightBlue.cgColor
        self.placeImage.roundedImage()
        
        
        self.followButton.roundCorners(radius: 5.0)
        self.followButton.setTitleColor(UIColor.white, for: .normal)
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.setTitleColor(UIColor.white, for: .selected)
        self.followButton.setTitle("Following", for: .selected)
        
        self.checkIfFollowing()
        
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
        
        self.distanceLabelInNavBar.setTitle(getDistance(fromLocation: AuthApi.getLocation()!, toLocation: placeLocation,addBracket: false, precision: 1), for: .normal)
        
        
        self.pinTableView.delegate = self
        self.pinTableView.dataSource = self
        let pinPlaceReviewNib = UINib(nibName: "PinPlaceReviewTableViewCell", bundle: nil)
        self.pinTableView.register(pinPlaceReviewNib, forCellReuseIdentifier: "pinPlaceReviewCell")
        
        self.peopleAlsoLikedTableView.delegate = self
        self.peopleAlsoLikedTableView.dataSource = self
        self.peopleAlsoLikedTableView.translatesAutoresizingMaskIntoConstraints = false
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        self.peopleAlsoLikedTableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        self.peopleAlsoLikedTableView.rowHeight = UITableViewAutomaticDimension
        self.peopleAlsoLikedTableView.estimatedRowHeight = 150.0
        
        self.yelpButton.backgroundColor = .clear
        self.yelpButton.layer.masksToBounds = true
        self.yelpButton.layer.cornerRadius = 5
        
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
        self.navigationBar.addBottomBorderWithColor(color: UIColor.white, width: 0.7)
        
        self.pinAmountLabel.setTitle("0", for: .normal)
        self.followersAmountLabel.setTitle("0", for: .normal)
        
        self.button1.setImage(#imageLiteral(resourceName: "Star white"), for: .normal)
        self.button2.setImage(#imageLiteral(resourceName: "Star white"), for: .normal)
        self.button3.setImage(#imageLiteral(resourceName: "Star white"), for: .normal)
        self.button4.setImage(#imageLiteral(resourceName: "Star white"), for: .normal)
        self.button5.setImage(#imageLiteral(resourceName: "Star white"), for: .normal)
        
        button1.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button2.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button3.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button4.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button5.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        
        Constants.DB.following_place.child((place?.id)!).child("followers").observeSingleEvent(of: .value, with: {snapshot in
            if let data = snapshot.value as? [String: Any]{
                let count = data.count
                self.followersAmountLabel.setTitle("\(count)", for: .normal)
                
            }
            else{
                self.followersAmountLabel.setTitle("0", for: .normal)
            }
        })
        
        Constants.DB.places.child((place?.id)!).observeSingleEvent(of: .value, with: {snapshot in
            if let data = snapshot.value as? [String: Any]{
                if let pins = data["pins"] as? [String: Any]{
                    self.pinAmountLabel.setTitle("\(pins.count)", for: .normal)
                }
                else{
                    self.pinAmountLabel.setTitle("0", for: .normal)
                }
            }
            else{
                self.pinAmountLabel.setTitle("0", for: .normal)
            }
        })
        
        
        
        //        placeVC?.suggestPlacesDelegate = self
        //        loadInfoScreen(place: self.place!)
        
        hideKeyboardWhenTappedAround()
        
        // Round up Yelp!
        var address = ""
        for str in (place?.address)!{
            address = address + " " + str
            
        }
        
//       set rating
        self.averageReviewAmount = Double((self.place?.reviewCount)!)
        guard let ratingAmount = self.place?.rating else {
            self.averageRatingAmount = 0.0
            return
        }
        self.averageRatingAmount = Double(ratingAmount)

        Constants.DB.pins.queryOrdered(byChild: "formattedAddress").queryEqual(toValue: address).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                for (key,_) in value!
                {
                    self.data.append(value?[key] as! NSDictionary)
                }
                
                self.data.sorted(by: {
                    ($0["time"] as! Double) < ($1["time"] as! Double)
                })
                if self.data.count > 3{
                    
                    print("get 3")
                }
                
                //self.data.sort(by: $0["time"] as? Double < $1["time"] as? Double)
            }
            else{
                self.pinStackView.removeArrangedSubview(self.pinTableView)
                self.pinTableView.removeFromSuperview()
                //                self.pinView.bounds.size.height -= self.pinTableView.frame.size.height
            }
            self.pinTableView.reloadData()
            
        })
        
        if let phoneLabelText = phoneLabel.text {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.callPlace))
            self.phoneLabel.isUserInteractionEnabled = true
            
            let textRange = NSMakeRange(0, phoneLabelText.characters.count)
            let attributedText = NSMutableAttributedString(string: phoneLabelText)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            
            self.phoneLabel.attributedText = attributedText
            self.phoneLabel.addGestureRecognizer(tap)
        }
        
        checkFollowing()
        checkRatingAmount()
        
        self.loadInfoScreen(place: self.place!)
        
        self.getUserSuggestions(gotUsers: {users in
            
            for (index,view) in self.inviteUserStackView.arrangedSubviews.enumerated(){
                let inviteUser = view as? InviteUserView
                inviteUser?.placeVC = self
                
                if let user = users[index] as? User{
                    inviteUser?.userName.text = user.username
                    inviteUser?.user = user
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            inviteUser?.image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                }
                else{
                    self.inviteUserStackView.removeArrangedSubview(view)
                }
            }
        })
        
        pinDF.dateFormat = "MMM d, h:mm a"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
//        getSuggestedPlaces(interests: getInterest(yelpCategory: (place?.categories[0].alias)!), limit: 3, gotPlaces: {places in
//            self.suggestedPlaces = places
//            self.peopleAlsoLikedTableView.reloadData()
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        getSuggestedPlaces(interests: getInterest(yelpCategory: (place?.categories[0].alias)!), limit: 3, gotPlaces: {places in
            self.suggestedPlaces = places
            self.peopleAlsoLikedTableView.reloadData()
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callPlace(sender:UITapGestureRecognizer) {
        guard let number = URL(string: "tel://" + (place?.plainPhone)!) else { return }
        UIApplication.shared.open(number)
    }
    
    func showRating(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Reviews", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "reviews") as? ReviewsViewController
        VC?.place = place
        self.present(VC!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 0){
            if self.data.count > 3{
                return 3
            }
            else{
                return self.data.count
            }
        }else{
            return suggestedPlaces.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.tag == 0){
            let pinCell = self.pinTableView.dequeueReusableCell(withIdentifier: "pinPlaceReviewCell", for: indexPath) as! PinPlaceReviewTableViewCell
            
            let data = self.data[indexPath.row]
            
            Constants.DB.user.child((data["fromUID"] as? String)!).observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? [String:Any]{
                    pinCell.usernameLabel.text = data["username"] as? String
                }
            })
            
            addGreenDot(label: pinCell.categoryLabel, content:(data["focus"] as? String)!)
            pinCell.timeOfPinLabel.text = pinDF.string(from: Date(timeIntervalSince1970: (data["time"] as? Double)!))
            pinCell.commentsTextView.text = data["pin"] as? String
            self.pinTableView.frame.size.height = (pinCell.frame.height * CGFloat(indexPath.row + 1))
            return pinCell
        }else{
            let otherPlacesCell = self.peopleAlsoLikedTableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell", for: indexPath) as! SearchPlaceCell
            otherPlacesCell.inviteButtonOut.addTarget(self, action: #selector(inviteTestMethod), for: .touchUpInside)
            otherPlacesCell.placeViewController = self
            let place = suggestedPlaces[indexPath.row]
            otherPlacesCell.placeNameLabel.text = place.name
            otherPlacesCell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) reviews)"
            otherPlacesCell.setRatingAmountForSearchPlaceCell(ratingAmount: Double(place.rating))
            let address = place.address.joined(separator: "\n")
            
            let placeLocation = CLLocation(latitude: Double(place.latitude), longitude: Double(place.longitude))
            
            otherPlacesCell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: placeLocation,addBracket: false, precision: 1)
            
            if let url = URL(string: place.image_url){
                
                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                    (receivedSize :Int, ExpectedSize :Int) in
                    
                }, completed: {
                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                    
                    if image != nil && finished{
                        otherPlacesCell.placeImage.image = crop(image: image!, width: 50, height: 50)
                    }
                })
            }
            
            otherPlacesCell.place = place
            otherPlacesCell.addressTextView.text = address
            addGreenDot(label: otherPlacesCell.categoryLabel, content: place_focus)
            otherPlacesCell.checkForFollow()
            
            self.peopleAlsoLikedTableView.frame.size.height = (otherPlacesCell.frame.height * CGFloat(indexPath.row + 1))
            
            return otherPlacesCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0){
            return 80
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPlaceCell
            
            self.peopleAlsoLikeTableViewHeight.constant = cell.contentView.frame.height * CGFloat(indexPath.row + 1)
            
            return cell.contentView.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
            let place = suggestedPlaces[indexPath.row]
            print(place)
            let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
            controller.place = place
            self.present(controller, animated: true, completion: nil)
            
        }
    }
    
    // MARK: TEXT VIEW DELEGATE METHODS
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.reviewsTextView.text = ""
    }
    
    @IBAction func showReviewBox(){
        self.reviewButton.isSelected = !(self.reviewButton.isSelected)
        if (self.reviewButton.isSelected){
            self.reviewsStack.isHidden = false
            self.mainStackView.insertArrangedSubview(self.reviewsStack, at: 0)
        }else{
            self.mainStackView.removeArrangedSubview(self.reviewsStack)
            self.reviewsStack.isHidden = true
            //            self.view.bounds.size.height -= self.reviewsStack.frame.size.height
        }
    }
    
    
    @IBAction func goBackToMap(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMapViewControllerWithSegue", sender: self)
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openYelp(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: (place?.url)!)! as URL)
        
    }
    
    @IBAction func openGoogleMaps(_ sender: Any) {
        let latitude = place?.latitude
        let longitude = place?.longitude
        
        let user_location = AuthApi.getLocation()
        let place_location = CLLocation(latitude: latitude!, longitude: longitude!)
        let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
        
        let distanceInMeters = user_location!.distance(from: place_location)
        
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, distanceInMeters*2, distanceInMeters*2)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place?.name
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func openUber(_ sender: Any) {
        let lat = place?.latitude
        let long = place?.longitude
        var address = place?.address[0]
        address = address?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url_string = "uber://?client_id=1Z-d5Wq4PQoVsSJFyMOVdm1nExWzrpqI&action=setPickup&pickup=my_location&dropoff[latitude]=\(String(describing: lat!))&dropoff[longitude]=\(String(describing: long!))&dropoff[nickname]=\(String(describing: address!))&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d"
        
        //let url  = URL(string: url_string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        if let url = URL(string: url_string){
            if UIApplication.shared.canOpenURL(url) == true
            {
                UIApplication.shared.openURL(url)
            }
        }
        
        
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        print("changing following button")
//        self.followButton.isSelected = !self.followButton.isSelected
        if self.followButton.isSelected == true{
            
            let unfollowAlertController = UIAlertController(title: "Are you sure you want to unfollow \(self.place!.name)?", message: nil, preferredStyle: .actionSheet)
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                Follow.unFollowPlace(id: (self.place?.id)!)
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor.clear.cgColor
                self.followButton.backgroundColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
                self.followButton.tintColor = UIColor.clear
                self.followButton.isSelected = false
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            self.present(unfollowAlertController, animated: true, completion: nil)
        }else{
            let time = NSDate().timeIntervalSince1970
            Follow.followPlace(id: (place?.id)!)
            self.followButton.layer.borderWidth = 1
            self.followButton.layer.borderColor = UIColor.white.cgColor
            self.followButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
            self.followButton.tintColor = UIColor.clear
            self.followButton.isSelected = true
        }
    }
    
    
    @IBAction func followPressed(){
        if isFollowing == false{
            let time = NSDate().timeIntervalSince1970
            Constants.DB.following_place.child((place?.id)!).child("followers").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":Double(time)])
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("places").childByAutoId().updateChildValues(["placeID":place?.id ?? "", "time":time])
            
            self.followButton.isSelected = true
            self.followButton.backgroundColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
            self.followButton.tintColor = UIColor.clear
            self.followButton.setTitle("Following", for: UIControlState.selected)
            isFollowing = true
        }else
        {
            
            let unfollowAlertController = UIAlertController(title: "Are you sure you want to unfollow \(place!.name)?", message: nil, preferredStyle: .actionSheet)
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                
                self.followButton.setTitle("Follow", for: UIControlState.normal)
                Constants.DB.following_place.child((self.place?.id)!).child("followers").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil {
                        for (key,_) in value!
                        {
                            Constants.DB.following_place.child((self.place?.id)!).child("followers").child(key as! String).removeValue()
                        }
                        
                        
                        
                    }
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            
            self.present(unfollowAlertController, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func postComment(_ sender: Any) {
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        let comment = comments.childByAutoId()
        
        if let rating = self.ratingID{
            comments.child(rating).setValue([
                "rating": self.selectedCommentRating ?? 0,
                "comment": reviewsTextView.text,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
        }
        else{
            comment.setValue([
                "rating": self.selectedCommentRating ?? 0,
                "comment": reviewsTextView.text,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
            self.ratingID = comment.key
        }
    }

    func checkIfFollowing(){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").queryOrdered(byChild: "placeID").queryEqual(toValue: place!.id).observeSingleEvent(of: .value, with: {snapshot in
            
            if let data = snapshot.value as? [String:Any]{
                self.followButton.isSelected = true
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor.white.cgColor
                self.followButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
                self.followButton.tintColor = UIColor.clear
            }else{
                self.followButton.isSelected = false
                self.followButton.layer.borderWidth = 0.0
                self.followButton.backgroundColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
                self.followButton.tintColor = UIColor.clear
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "pinInfo"{
//            let pin = segue.destination as! PinViewController
//            pin.delegate = self
//            pin.placeVC = self
//            pin.place = self.place
//            pin.averageReviewAmount = Double((self.place?.reviewCount)!)
//            guard let ratingAmount = self.place?.rating else {
//                pin.averageRatingAmount = 0.0
//                return
//            }
//            
//            pin.averageRatingAmount = Double(ratingAmount)
//
//        }
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
                    
                    delegate?.showPlaceMarker(place: self.place!)
                }
                else{
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
                    
                    delegate?.showPlaceMarker(place: self.place!)
                }
            }
        }else if segue.identifier == "unwindToMapViewControllerFromPlaceDetailsWithSegue"{
            let map = self.map
            map?.locationFromPlaceDetails = (place?.name)!
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
    
    func loadInfoScreen(place: Place){
        // Do any additional setup after loading the view.
        
        if place.price.characters.count == 0{
            self.dollarLabel.text = "N.A."
            
        }
        else{
            self.dollarLabel.text = place.price
            
        }
        
        postReviewSeciontButton.layer.borderWidth = 1
        postReviewSeciontButton.layer.borderColor = UIColor.white.cgColor
        postReviewSeciontButton.roundCorners(radius: 5)
        
        
        starRatingView.topCornersRounded(radius: 10)
        writeReviewView.bottomCornersRounded(radius: 10)
        
        
        var focus_category = Set<String>()
        var yelp_category = [String]()
        
        place_focus = getInterest(yelpCategory: place.categories[0].alias)
        
        for category in place.categories{
            focus_category.insert(getInterest(yelpCategory: category.alias))
            yelp_category.append(category.alias)
            
        }
        
        for (index, category) in focus_category.enumerated(){
            let completeLabel = UILabel()
            
            //            here you're adding green category dot to category text
            completeLabel.text = category
            completeLabel.textColor = .white
            
            if index == 0 {
                addGreenDot(label: (self.interestLabel)!, content: category)
            }
            
        }
        
        if place.categories.count == 0{
            addGreenDot(label: (self.interestLabel)!, content: "Community")
        }
        
        streetAddress.text = place.address[0]
        if place.address.count == 2{
            cityStateLabel.text = place.address[1]
        }
        else{
            cityStateLabel.text = place.address.last!
        }
        
        phoneLabel.text = place.phone
        
        print("Hours: \(String(describing: place.hours))")
        
        if let open_hours = place.hours{
            let hours = getOpenHours(open_hours)
            self.starsUberAndHoursStack.addArrangedSubview(self.hoursStackView)
            for (_, hour) in (hours.enumerated()){
                
                let textLabel = UILabel()
                
                textLabel.text  = hour
                textLabel.textAlignment = .left
                textLabel.textColor = .white
                self.infoViewScreenHeight.constant += 17.5
                hoursStackView.addArrangedSubview(textLabel)
                hoursStackView.translatesAutoresizingMaskIntoConstraints = false;
            }
        }else if place.hours == nil{
            self.infoView.frame.size.height -= self.hoursStackView.frame.height
            self.infoViewScreenHeight.constant -= self.hoursStackView.frame.height
            self.starsUberAndHoursStack.removeArrangedSubview(self.hoursStackView)
            self.hoursStackView.removeFromSuperview()
        }
        
        let invite = ["user1", "user2", "user3"]
        
        for (index, user) in invite.enumerated(){
            let view = inviteUserStackView.arrangedSubviews[index] as! InviteUserView
            view.userName.text = user
            view.userName.textColor = .white
            view.delegate = self
            view.inviteButton.addTarget(self, action: #selector(inviteSentToSingleUser), for: .touchUpInside)
            view.image.image = UIImage(named: "UserPhoto")
        }
        
        yelpButton.setImage(UIImage(named: "Yelp icon.png"), for: .normal)
        yelpButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        uberButton.setImage(UIImage(named: "uber"), for: .normal)
        uberButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        googleMapButton.setImage(UIImage(named: "Large_Apple_Maps.png"), for: .normal)
        googleMapButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        

        getNearbyPlaces(text: nil, id: place.id, categories: yelp_category.joined(separator: ","), count: 3, location: CLLocation(latitude: place.latitude, longitude: place.longitude), completion: {places in
            self.suggestedPlaces = places
            self.peopleAlsoLikedTableView.reloadData()
        })
    }

    
    func fetchSuggestedPlaces(token: String){
        if let location = self.currentLocation{
            getNearbyLocations(location: location)
        }
        else{
            let location = CLLocation(latitude: (self.place?.latitude)!, longitude: (self.place?.longitude)!)
            getNearbyLocations(location: location)
        }
        
    }
    
    func getNearbyLocations(location: CLLocation){
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
    
    func getUserSuggestions(gotUsers: @escaping ([User]) -> Void){
        var followingSuggestions = [User]()
        var suggestions = [User]()
        var userCount = 0
        
        let ref = Constants.DB.user
        
        var followingCount = 0
        ref.child(AuthApi.getFirebaseUid()!).child("following/people").observeSingleEvent(of: .value, with: {snapshot in
            if let value = snapshot.value as? [String:Any]{
                for (_, people) in value{
                    
                    if let peopleData = people as? [String:Any]{
                        let UID = peopleData["UID"] as! String
                        ref.child(UID).observeSingleEvent(of: .value, with: { snapshot in
                            if let user = snapshot.value as? [String:Any]{
                                if let user = User.toUser(info: user){
                                    if user.uuid != AuthApi.getFirebaseUid(){
                                        let matchingInterest = matchingUserInterest(user: user)
                                        if matchingInterest.count > 0{
                                            followingCount += 1
                                            user.matchingInterestCount = matchingInterest.count
                                            if user.uuid != AuthApi.getFirebaseUid(){
                                                if !followingSuggestions.contains(user){
                                                    followingSuggestions.append(user)
                                                }
                                                
                                                if followingCount < 3 && followingSuggestions.count == followingCount - 1{
                                                    followingSuggestions = followingSuggestions.sorted(by: {$0.matchingInterestCount > $1.matchingInterestCount})
                                                    
                                                    if suggestions.count > 0{
                                                        gotUsers(followingSuggestions + suggestions[0..<3-followingSuggestions.count])
                                                    }
                                                    
                                                }
                                                else if suggestions.count == 3{
                                                    followingSuggestions = followingSuggestions.sorted(by: {$0.matchingInterestCount > $1.matchingInterestCount})
                                                    gotUsers(followingSuggestions)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        })
                    }
                }
            }
        })
        
        Constants.DB.user.observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as? [String : Any] ?? [:]
            
            for (_, user) in users{
                let info = user as? [String:Any]
                
                if let info = info{
                    if let user = User.toUser(info: info){
                        let matchingInterest = matchingUserInterest(user: user)
                        if matchingInterest.count > 0{
                            userCount += 1
                            user.matchingInterestCount = matchingInterest.count
                            if user.uuid != AuthApi.getFirebaseUid(){
                                if !suggestions.contains(user){
                                    suggestions.append(user)
                                }
                                
                                if userCount < 3 && suggestions.count == userCount - 1{
                                    suggestions = suggestions.sorted(by: {$0.matchingInterestCount > $1.matchingInterestCount})
                                    
                                    if followingSuggestions.count < 3{
                                        gotUsers(followingSuggestions + suggestions[0..<3-followingSuggestions.count])
                                    }
                                }
                                else if suggestions.count == 3{
                                    suggestions = suggestions.sorted(by: {$0.matchingInterestCount > $1.matchingInterestCount})
                                    
                                    if followingSuggestions.count < 3{
                                        gotUsers(followingSuggestions + suggestions[0..<3-followingSuggestions.count])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        })
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
        performSegue(withIdentifier: "unwindToMapViewControllerFromPlaceDetailsWithSegue", sender: self)
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
    
    func inviteUser(name: String) {
        print("clicked \(name)")
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.id = (place?.id)!
        ivc.place = place
        ivc.username = name
        ivc.placeDetailsDelegate = self
        ivc.inviteFromPlaceDetails = true
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    func inviteTestMethod(){
        
        print("testing........")
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.id = (place?.id)!
        ivc.place = place
        ivc.placeDetailsDelegate = self
        ivc.inviteFromPlaceDetails = true
        ivc.username = AuthApi.getUserName()!
        ivc.placeViewController = self
        
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    @IBAction func selectedRating(sender: UIButton){
        self.starRatingTag = sender.tag
        switch sender.tag{
        case 1:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star light yellow"))
            self.selectedCommentRating = 1
            break
        case 2:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star dark yellow"))
            self.selectedCommentRating = 2
            break
        case 3:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star light orange"))
            self.selectedCommentRating = 3
            break
        case 4:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star dark orange"))
            self.selectedCommentRating = 4
            break
        case 5:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star red"))
            self.selectedCommentRating = 5
            break
        default:
            break
        }
    }
    
    func setImage(select: Int, image: UIImage){
        for select in 1...select{
            let button = ratingView.viewWithTag(select) as! UIButton
            button.setImage(image, for: .normal)
        }
        
        if select < 5{
            for unselected in select + 1...5{
                let button = ratingView.viewWithTag(unselected) as! UIButton
                button.setImage(#imageLiteral(resourceName: "Star white"), for: .normal)
            }
        }
    }
    
    func checkRatingAmount(){
        self.reviewAmountButton.setTitle("\(Int(self.averageReviewAmount)) reviews", for: .normal)
        guard let reviewsStarImageView = self.reviewStars else{
            return
        }
        switch self.averageRatingAmount{
        case 0.0...0.9:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_0")
        case 1.0...1.4:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_1")
        case 1.5...1.9:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_1_half")
        case 2.0...2.4:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_2")
        case 2.5...2.9:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_2_half")
        case 3.0...3.4:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_3")
        case 3.5...3.9:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_3_half")
        case 4.0...4.4:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_4")
        case 4.5...4.9:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_4_half")
        case 5.0:
            reviewsStarImageView.image = #imageLiteral(resourceName: "small_5")
        default:
            break
        }
    }
    
    func checkFollowing(){
        Constants.DB.following_place.child((place?.id)!).child("followers").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.followButton.setTitle("Following", for: .selected)
            self.followButton.setTitle("Follow", for: .normal)
            
            if value != nil {
                self.followButton.isSelected = true
                self.followButton.layer.borderColor = UIColor.white.cgColor
                self.followButton.layer.borderWidth = 1
                //                self.placeVC?.followButton.layer.shadowOpacity = 1.0
                //                self.placeVC?.followButton.layer.masksToBounds = false
                //                self.placeVC?.followButton.layer.shadowColor = UIColor.black.cgColor
                //                self.placeVC?.followButton.layer.shadowRadius = 5.0
                self.followButton.backgroundColor = UIColor(red: 21/255.0, green: 41/255.0, blue: 65/255.0, alpha: 1.0)
                self.isFollowing = true
                
            }else{
                self.followButton.isSelected = false
                self.followButton.layer.borderColor = UIColor.clear.cgColor
                self.followButton.layer.borderWidth = 0
                self.followButton.backgroundColor = UIColor(red: 122/225.0, green: 201/255.0, blue: 1/255.0, alpha: 1)
                self.isFollowing = false
                
            }
        })
        
    }
    
    func inviteSentToSingleUser(){
//        TODO: need to send invite to single user, need to ask arya how to handle stack when invite sent
        self.hasSentInvite()
        self.showPopup()
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
