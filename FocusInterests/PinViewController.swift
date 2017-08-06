//
//  PinViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class PinViewController: UIViewController, InviteUsers, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate, UIPopoverPresentationControllerDelegate{
    var place: Place?
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var postReviewSeciontButton: UIButton!
    // reviews stack
    @IBOutlet weak var reviewsStack: UIStackView!
    @IBOutlet weak var reviewsTextView: UITextView!
    
    // basic info screen
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var uberButton: UIButton!
    @IBOutlet weak var googleMapButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var reviewStars: UIImageView!
    @IBOutlet weak var reviewAmountButton: UIButton!
    var averageRatingAmount = 0.0
    var averageReviewAmount = 0.0
    
    
    // location info
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var hoursStackView: UIStackView!
    @IBOutlet weak var pinTableView: UITableView!
    @IBOutlet weak var inviteUserStackView: UIStackView!
    @IBOutlet weak var starsUberAndHoursStack: UIStackView!
    
    var suggestedPlaces = [Place]()
    
    @IBOutlet weak var writeReviewView: UITextView!
    @IBOutlet weak var starRatingView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewScreenHeight: NSLayoutConstraint!
    
    // pins stack
    @IBOutlet weak var pinStackView: UIStackView!
    @IBOutlet weak var pinsHeightConstraint: NSLayoutConstraint!
    
    // people also liked stack
    @IBOutlet weak var peopleAlsoLikedStack: UIView!
    @IBOutlet weak var peopleAlsoLikedTableView: UITableView!
    @IBOutlet weak var peopleAlsoLikedTableViewHeight: NSLayoutConstraint!
    
    var placeVC: PlaceViewController? = nil
    var ratingID: String?
    var rating: Int? = nil
    var showInvitePopup = false
    var delegate: SendInviteFromPlaceDetailsDelegate?
    
    @IBOutlet weak var yelpButton: UIButton!
    
    
    //rating
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    
    var data = [NSDictionary]()
    var isFollowing = false
    var place_focus = ""
    var pinDF = DateFormatter()
    
    @IBOutlet weak var noPinLabel: UILabel!
    @IBOutlet weak var pinTableHeight: NSLayoutConstraint!
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.placeVC?.reviewButton.addTarget(self, action: #selector(PinViewController.showReviewBox), for: .touchUpInside)
        self.mainStackView.removeArrangedSubview(self.reviewsStack)
        self.reviewsStack.isHidden = true
//        self.view.bounds.size.height -= self.reviewsStack.frame.size.height
        
        self.placeVC?.followButton.addTarget(self, action: #selector(PinViewController.followPressed), for: .touchUpInside)
        
        let pinPlaceReviewNib = UINib(nibName: "PinPlaceReviewTableViewCell", bundle: nil)
        self.pinTableView.register(pinPlaceReviewNib, forCellReuseIdentifier: "pinPlaceReviewCell")
        
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        self.peopleAlsoLikedTableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        
//        placeVC?.suggestPlacesDelegate = self
//        loadInfoScreen(place: self.place!)
        
        hideKeyboardWhenTappedAround()
        
        // Round up Yelp!
        
        self.yelpButton.backgroundColor = .clear
        self.yelpButton.layer.masksToBounds = true
        self.yelpButton.layer.cornerRadius = 5
        
        var address = ""
        for str in (place?.address)!{
            address = address + " " + str
            
        }
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
        
        checkFollowing()
        checkRatingAmount()
        
        self.loadInfoScreen(place: self.place!)
        
        self.getUserSuggestions(gotUsers: {users in
        
            for (index,view) in self.inviteUserStackView.arrangedSubviews.enumerated(){
                let inviteUser = view as? InviteUserView
                inviteUser?.parentVC = self
                
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
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func checkFollowing(){
        Constants.DB.following_place.child((place?.id)!).child("followers").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            self.placeVC?.followButton.setTitle("Following", for: .selected)
            self.placeVC?.followButton.setTitle("Follow", for: .normal)
            
            if value != nil {
                self.placeVC?.followButton.isSelected = true
                self.placeVC?.followButton.layer.borderColor = UIColor.white.cgColor
                self.placeVC?.followButton.layer.borderWidth = 1
//                self.placeVC?.followButton.layer.shadowOpacity = 1.0
//                self.placeVC?.followButton.layer.masksToBounds = false
//                self.placeVC?.followButton.layer.shadowColor = UIColor.black.cgColor
//                self.placeVC?.followButton.layer.shadowRadius = 5.0
                self.placeVC?.followButton.backgroundColor = UIColor(red: 21/255.0, green: 41/255.0, blue: 65/255.0, alpha: 1.0)
                self.isFollowing = true
                
            }else{
                self.placeVC?.followButton.isSelected = false
                self.placeVC?.followButton.layer.borderColor = UIColor.clear.cgColor
                self.placeVC?.followButton.layer.borderWidth = 0
                self.placeVC?.followButton.backgroundColor = UIColor(red: 122/225.0, green: 201/255.0, blue: 1/255.0, alpha: 1)
                self.isFollowing = false
                
            }
        })
        
    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        getSuggestedPlaces(interests: getInterest(yelpCategory: (place?.categories[0].alias)!), limit: 3, gotPlaces: {places in
            self.suggestedPlaces = places
            self.peopleAlsoLikedTableView.reloadData()
        })
    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func callPlace(sender:UITapGestureRecognizer) {
        guard let number = URL(string: "tel://" + (place?.plainPhone)!) else { return }
        UIApplication.shared.open(number)
    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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

/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func loadInfoScreen(place: Place){
        // Do any additional setup after loading the view.

        if place.price.characters.count == 0{
            self.placeVC?.dollarLabel.text = "N.A."

        }
        else{
            self.placeVC?.dollarLabel.text = place.price

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
                addGreenDot(label: completeLabel, content: category)
                addGreenDot(label: (self.placeVC?.interestLabel)!, content: category)
            }
            
        }
        streetAddress.text = place.address[0]
        if place
            .address.count == 2{
            cityStateLabel.text = place.address[1]
        }
        else{
            cityStateLabel.text = ""
        }
        
        phoneLabel.text = place.phone
        
//        TODO: THIS RETURNS NIL NEED TO FIX BACKEND SETUP SO THAT HOURS ARE ADDED
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
        
        
        getNearbyPlaces(text: "", id: place.id, categories: yelp_category.joined(separator: ","), count: 3, location: CLLocation(latitude: place.latitude, longitude: place.longitude), completion: {places in
            self.suggestedPlaces = places
            self.peopleAlsoLikedTableView.reloadData()
        })
    }

    // function which is triggered when handleTap is called
    func handleTap(_ sender: UITapGestureRecognizer) {
        let view = sender.view as! SuggestPlaceView
        print("Tapped \(String(describing: view.name.text))")
        placeVC?.loadPlace(place: view.place!)
        self.loadInfoScreen(place: view.place!)
        
//        self.scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)

    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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
            otherPlacesCell.placeVC = self
            let place = suggestedPlaces[indexPath.row]
            otherPlacesCell.dateAndTimeLabel.text = "7/20 10:00 P.M."
            otherPlacesCell.placeNameLabel.text = place.name
            otherPlacesCell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) reviews)"
            otherPlacesCell.setRatingAmountForSearchPlaceCell(ratingAmount: Double(place.rating))
            let address = place.address.joined(separator: "\n")
            
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
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0){
            return 80
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPlaceCell
            return cell.frame.height
        }
    }

/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var frame = self.peopleAlsoLikedTableView.frame;
        frame.size.height = self.peopleAlsoLikedTableView.contentSize.height
        self.peopleAlsoLikedTableView.frame = frame;
        
        getSuggestedPlaces(interests: getInterest(yelpCategory: (place?.categories[0].alias)!), limit: 3, gotPlaces: {places in
            self.suggestedPlaces = places
            self.peopleAlsoLikedTableView.reloadData()
        })
    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func inviteUser(name: String) {
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.id = (place?.id)!
        ivc.place = place
        
        ivc.username = name
        ivc.placeVC = self
        
        self.present(ivc, animated: true, completion: { _ in })
    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func inviteTestMethod(){
        
        print("testing........")
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.id = (place?.id)!
        ivc.place = place
        ivc.placeDetailsDelegate = self.delegate
        ivc.inviteFromPlaceDetails = true
        ivc.username = AuthApi.getUserName()!
        ivc.placeVC = self
        
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func inviteSentToSingleUser(){

//        TODO: need to send invite to single user, need to ask arya how to handle stack when invite sent
        self.placeVC?.hasSentInvite()
        self.placeVC?.showPopup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func gotSuggestedPlaces(places: [Place]) {
//        for (index, place) in places.enumerated(){
//            let view = suggestPlacesStackView.arrangedSubviews[index] as! SuggestPlaceView
//            view.place = place
//            view.name.text = place.name
//            view.name.textColor = .white
//            view.imageView.sd_setImage(with: URL(string: place.image_url), placeholderImage: UIImage(named: "addUser"))
//            view.imageView.roundedImage()
//            
//            view.isUserInteractionEnabled = true
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//            view.addGestureRecognizer(tap)
//            
//        }
//    }
//    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    @IBAction func openYelp(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: (place?.url)!)! as URL)

    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    @IBAction func pin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "Home") as! PinScreenViewController
        ivc.pinType = .place
        ivc.placeEventID = (place?.id)!
        
        for str in (place?.address)!
        {
            ivc.formmatedAddress = ivc.formmatedAddress + ";;" + str
        }
        ivc.coordinates.latitude = (place?.latitude)!
        ivc.coordinates.longitude = (place?.longitude)!
        ivc.locationName = (place?.name)!
        self.present(ivc, animated: true, completion: { _ in })
        
    }
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    // MARK: TEXT VIEW DELEGATE METHODS
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.reviewsTextView.text = ""
    }
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func showReviewBox(){
        self.placeVC?.reviewButton.isSelected = !(self.placeVC?.reviewButton.isSelected)!
        if (self.placeVC?.reviewButton.isSelected)!{
            self.reviewsStack.isHidden = false
            self.mainStackView.insertArrangedSubview(self.reviewsStack, at: 0)
        }else{
            self.mainStackView.removeArrangedSubview(self.reviewsStack)
            self.reviewsStack.isHidden = true
//            self.view.bounds.size.height -= self.reviewsStack.frame.size.height
        }
    }
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    @IBAction func selectedRating(sender: UIButton){
        self.rating = sender.tag
        switch sender.tag{
        case 1:
//            self.ratingsImage.image = #imageLiteral(resourceName: "Star light yellow")
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star light yellow"))
            break
        case 2:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star dark yellow"))
//            self.ratingsImage.image = #imageLiteral(resourceName: "Star dark yellow")
            break
        case 3:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star light orange"))
            break
        case 4:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star dark orange"))
            break
        case 5:
            self.setImage(select: sender.tag, image: #imageLiteral(resourceName: "Star red"))
            break
        default:
            break
        }
        
    }
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    @IBAction func postComment(_ sender: Any) {
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        let comment = comments.childByAutoId()
        
        if let rating = self.ratingID{
            comments.child(rating).setValue([
                "rating": self.rating ?? 0,
                "comment": reviewsTextView.text,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
        }
        else{
            comment.setValue([
                "rating": self.rating ?? 0,
                "comment": reviewsTextView.text,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
            self.ratingID = comment.key
        }
    }
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
    func followPressed(){
        if isFollowing == false{
            let time = NSDate().timeIntervalSince1970
            Constants.DB.following_place.child((place?.id)!).child("followers").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":Double(time)])
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("places").childByAutoId().updateChildValues(["placeID":place?.id ?? "", "time":time])
            
            self.placeVC?.followButton.isSelected = true
            self.placeVC?.followButton.backgroundColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
            self.placeVC?.followButton.tintColor = UIColor.clear
            self.placeVC?.followButton.setTitle("Following", for: UIControlState.selected)
            isFollowing = true
        }else
        {
            
            let unfollowAlertController = UIAlertController(title: "Are you sure you want to unfollow \(place!.name)?", message: nil, preferredStyle: .actionSheet)
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                
                self.placeVC?.followButton.setTitle("Follow", for: UIControlState.normal)
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
    
    
/////////////////////////////////////
////////////// ADDED TO PLACEVIEWLCONTROLLER ////////////////
/////////////////////////////////////
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
                                        if matchingInterest > 0{
                                            followingCount += 1
                                            user.matchingInterestCount = matchingInterest
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
                        if matchingInterest > 0{
                            userCount += 1
                            user.matchingInterestCount = matchingInterest
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
