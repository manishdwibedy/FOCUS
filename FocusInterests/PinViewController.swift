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

class PinViewController: UIViewController, InviteUsers, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate{
    var place: Place?
    
    @IBOutlet weak var postReviewSeciontButton: UIButton!
    @IBOutlet weak var morePinSectionButton: UIButton!
    @IBOutlet weak var moreCategoriesSectionButton: UIButton!
    
    @IBOutlet weak var reviewsView: UIView!
    @IBOutlet weak var reviewsTextView: UITextView!
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    // basic info screen
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    // categories
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var categoryBackground: UIView!
    @IBOutlet weak var categoriesStackView: UIStackView!
    
    // location info
    @IBOutlet weak var locationInfoStackView: UIStackView!
    @IBOutlet weak var locationInfoStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var hoursStackView: UIStackView!
    @IBOutlet weak var pinTableView: UITableView!
    @IBOutlet weak var inviteUserStackView: UIStackView!
    @IBOutlet weak var infoScreenHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var reviewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var peopleAlsoLikedTableView: UITableView!
    var suggestedPlaces = [Place]()
    
    @IBOutlet weak var writeReviewView: UITextView!
    @IBOutlet weak var starRatingView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var placeVC: PlaceViewController? = nil
    var ratingID: String?
    var rating: Int? = nil
    var showInvitePopup = false
    var delegate: SendInviteFromPlaceDetailsDelegate?
    
    @IBOutlet weak var yelpButton: UIButton!
    @IBOutlet weak var uberButton: UIButton!
    @IBOutlet weak var googleMapButton: UIButton!
    
    @IBOutlet weak var peopleAlsoLikedHeight: NSLayoutConstraint!
    @IBOutlet weak var pinsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var peopleAlsoLikedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var peopleWhoLikeThisTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryTop: NSLayoutConstraint!
    @IBOutlet weak var pinsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var peopleAlsoLikedViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.placeVC?.reviewButton.addTarget(self, action: #selector(PinViewController.showReviewBox), for: .touchUpInside)
        
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
        for str in (place?.address)!
        {
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
                self.pinsHeightConstraint.constant = 116
//                self.viewHeight.constant -= 116
                
                self.noPinLabel.alpha = 1
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
        
//        self.view
        self.topViewHeight.constant -= self.reviewsView.frame.size.height
        self.placeVC?.pinViewHeight.constant -= self.reviewsView.frame.size.height
        reviewsView.alpha = 0
//        categoryTop.constant = 0
        
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
        
        
        self.loadInfoScreen(place: self.place!)
        
        self.getUserSuggestions(gotUsers: {users in
        
            for (index,view) in self.inviteUserStackView.arrangedSubviews.enumerated(){
                let inviteUser = view as? InviteUserView
                
                if let user = users[index] as? User{
                    inviteUser?.userName.text = user.username
                    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func callPlace(sender:UITapGestureRecognizer) {
        guard let number = URL(string: "tel://" + (place?.plainPhone)!) else { return }
        UIApplication.shared.open(number)
    }
    
    func loadInfoScreen(place: Place){
        // Do any additional setup after loading the view.
        self.placeVC?.placeName.text = place.name

        if place.price.characters.count == 0{
            self.placeVC?.dollarLabel.text = "N.A."

        }
        else{
            self.placeVC?.dollarLabel.text = place.price

        }
        
        postReviewSeciontButton.layer.borderWidth = 1
//        moreCategoriesSectionButton.layer.borderWidth = 1
        
        postReviewSeciontButton.layer.borderColor = UIColor.white.cgColor
//        moreCategoriesSectionButton.layer.borderColor = UIColor.white.cgColor
        
        postReviewSeciontButton.roundCorners(radius: 5)
//        moreCategoriesSectionButton.roundCorners(radius: 5)
        
        starRatingView.topCornersRounded(radius: 10)
        writeReviewView.bottomCornersRounded(radius: 10)
        
//        for view in categoriesStackView.subviews{
//            view.removeFromSuperview()
//        }
        
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
            
//            categoriesStackView.addArrangedSubview(completeLabel)
//            categoriesStackView.translatesAutoresizingMaskIntoConstraints = false;
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
            infoScreenHeight.constant += CGFloat(25 * hours.count)
//            viewHeight.constant += CGFloat(25 * hours.count)
            
            for (_, hour) in (hours.enumerated()){
//                frame: CGRect(x: 0, y: 0, width: self.hoursStackView.frame.size.width, height: 25)
                let textLabel = UILabel()
                
                textLabel.text  = hour
                textLabel.textAlignment = .left
                textLabel.textColor = .white
                
                hoursStackView.addArrangedSubview(textLabel)
                hoursStackView.translatesAutoresizingMaskIntoConstraints = false;
            }
        }else {
            self.infoScreenHeight.constant -= self.hoursStackView.bounds.size.height
            self.placeVC?.pinViewHeight.constant -= self.hoursStackView.bounds.size.height
            self.hoursStackView.bounds.size.height = 0
            // MISSING locationInfoStackView
//            self.infoScreenHeight.constant -= self.locationInfoStackView.subviews[3].bounds.height
//            self.viewHeight.constant -= self.locationInfoStackView.subviews[3].bounds.height
//            
//            self.locationInfoStackView.subviews[3].removeFromSuperview()
//            self.locationInfoStackViewHeight.constant = 75

            
            //            let textLabel = UILabel()
//            textLabel.text = "This location has not submitted its hours"
//            textLabel.textAlignment = .center
//            textLabel.textColor = UIColor.white
//            textLabel.center = hoursStackView.center
//            hoursStackView.addArrangedSubview(textLabel)
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
        
        
        getNearbyPlaces(text: "", categories: yelp_category.joined(separator: ","), count: 3, location: CLLocation(latitude: place.latitude, longitude: place.longitude), completion: {places in
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
        
        self.scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)

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
            
            return pinCell
        }else{
            
            let otherPlacesCell = self.peopleAlsoLikedTableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell", for: indexPath) as! SearchPlaceCell
            otherPlacesCell.inviteButtonOut.addTarget(self, action: #selector(inviteTestMethod), for: .touchUpInside)
            otherPlacesCell.placeCellView.backgroundColor = UIColor.clear
            otherPlacesCell.layer.backgroundColor = UIColor.clear.cgColor
            
            let place = suggestedPlaces[indexPath.row]
            otherPlacesCell.placeNameLabel.text = place.name
            otherPlacesCell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) ratings)"
            
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
            
            return otherPlacesCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0){
//            tableView.cellForRow(at: indexPath)?.bounds.size.height = (tableView.cellForRow(at: indexPath)?.contentView.bounds.size.height)!
            return 80
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPlaceCell
            return cell.bounds.size.height
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func inviteUser(name: String) {
        print("clicked \(name)")
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.id = (place?.id)!
        ivc.place = place
        
        ivc.username = name
        ivc.placeVC = self
        
        self.present(ivc, animated: true, completion: { _ in })
    }
    
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
    
    @IBAction func openYelp(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: (place?.url)!)! as URL)

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
    
    @IBAction func pin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "Home") as! PinScreenViewController
        ivc.pinType = "place"
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
    
    // MARK: TEXT VIEW DELEGATE METHODS
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.reviewsTextView.text = ""
    }
    
    func showReviewBox(){
        if reviewsView.alpha == 1{
            reviewsView.alpha = 0
//            categoryTop.constant = 0
            self.topViewHeight.constant -= self.reviewsView.frame.size.height
            self.placeVC?.pinViewHeight.constant -= self.reviewsView.frame.size.height
        }
        else{
            reviewsView.alpha = 1
//            categoryTop.constant = 132
            self.topViewHeight.constant += self.reviewsView.frame.size.height
            self.placeVC?.pinViewHeight.constant += self.reviewsView.frame.size.height
        }
    }
    
    @IBAction func showReview(_ sender: Any) {
        if reviewsView.alpha == 1{
            reviewsView.alpha = 0
            categoryTop.constant = 90
        }
        else{
            reviewsView.alpha = 1
            categoryTop.constant = 215
        }
        
    }
    
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
    
    func followPressed(){
        if isFollowing == false
        {
            let time = NSDate().timeIntervalSince1970
            Constants.DB.following_place.child((place?.id)!).child("followers").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":Double(time)])
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("places").childByAutoId().updateChildValues(["placeID":place?.id ?? "", "time":time])
            
            self.placeVC?.followButton.isSelected = true
//            self.followButton.layer.borderWidth = 1
//            self.followButton.layer.borderColor = UIColor.white.cgColor
//            self.followButton.layer.shadowOpacity = 1.0
//            self.followButton.layer.masksToBounds = false
//            self.followButton.layer.shadowColor = UIColor.black.cgColor
//            self.followButton.layer.shadowRadius = 7.0
            self.placeVC?.followButton.backgroundColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
            self.placeVC?.followButton.tintColor = UIColor.clear
            self.placeVC?.followButton.setTitle("Following", for: UIControlState.selected)
            isFollowing = true
        }else
        {
            self.placeVC?.followButton.setTitle("Follow", for: UIControlState.normal)
            Constants.DB.following_place.child((place?.id)!).child("followers").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    for (key,_) in value!
                    {
                        Constants.DB.following_place.child((self.place?.id)!).child("followers").child(key as! String).removeValue()
                    }
                    
                    
                    
                }
            })
        }
    }
    
    func getUserSuggestions(gotUsers: @escaping ([User]) -> Void){
        var people = [User]()
        var userCount = 0
        Constants.DB.user.observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as? [String : Any] ?? [:]
            
            for (_, user) in users{
                let info = user as? [String:Any]
                
                if let info = info{
                    if let user = User.toUser(info: info){
                        
                        if matchingUserInterest(user: user){
                            userCount += 1
                            if user.uuid != AuthApi.getFirebaseUid(){
                                if !people.contains(user){
                                    people.append(user)
                                }
                                
                                if userCount < 3 && people.count == userCount - 1{
                                    gotUsers(people)
                                }
                                else if people.count == 3{
                                    gotUsers(people)
                                }
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    @IBAction func follow(_ sender: Any) {
        
//        if isFollowing == false
//        {
//        let time = NSDate().timeIntervalSince1970
//        Constants.DB.following_place.child((place?.id)!).child("followers").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":Double(time)])
//        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("places").childByAutoId().updateChildValues(["placeID":place?.id ?? "", "time":time])
//        
//        self.followButton.isSelected = true
//        self.followButton.layer.borderWidth = 1
//        self.followButton.layer.borderColor = UIColor.white.cgColor
//        self.followButton.layer.shadowOpacity = 1.0
//        self.followButton.layer.masksToBounds = false
//        self.followButton.layer.shadowColor = UIColor.black.cgColor
//        self.followButton.layer.shadowRadius = 7.0
//        self.followButton.backgroundColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
//        self.followButton.tintColor = UIColor.clear
//        self.followButton.setTitle("Following", for: UIControlState.normal)
//            isFollowing = true
//        }else
//        {
//            self.followButton.setTitle("Follow", for: UIControlState.normal)
//            Constants.DB.following_place.child((place?.id)!).child("followers").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                if value != nil {
//                    for (key,_) in value!
//                    {
//                        Constants.DB.following_place.child((self.place?.id)!).child("followers").child(key as! String).removeValue()
//                    }
//                    
//                    
//                    
//                }
//            })
//        }
        //           Constants.DB.places.child(placeID).child("followers").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":Double(time)])
        
        
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
