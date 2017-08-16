//
//  UserProfileViewController.swift
//  FocusInterests
//
//  Created by Albert Pan on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import GeoFire
import FirebaseDatabase
import Crashlytics

enum previousScreen{
    case people
    case notification
}

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationBarDelegate, UITextViewDelegate{
    
	@IBOutlet var userScrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var userInfoView: UIView!
    // User data
	@IBOutlet var descriptionText: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
//    @IBOutlet weak var suggestionsHeight: NSLayoutConstraint!
    
    // follower and following
    @IBOutlet weak var followerStackView: UIStackView!
    @IBOutlet weak var followingStackView: UIStackView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followerCount: UIButton!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followingCount: UIButton!
    
    // border between user info and pin stack
    @IBOutlet weak var secondBorderHeight: NSLayoutConstraint!
    
    // User Pin Stack
    @IBOutlet weak var createPinAndUpdatePinStack: UIStackView!
    @IBOutlet weak var createPinView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinCategoryLabel: UILabel!
    @IBOutlet weak var pinLikesLabel: UILabel!
    @IBOutlet weak var pinAddress2Label: UILabel!
    @IBOutlet weak var updatePinButton: UIButton!
    @IBOutlet weak var createPinButton: UIButton!
    @IBOutlet weak var pinDistanceLabel: UILabel!
    @IBOutlet weak var pinCount: UIButton!
    var pinInfo: pinData? = nil
    
    // user interests
    var hiddenInterests = [UIView]()
    @IBOutlet weak var focusHeader: UILabel!
    @IBOutlet weak var focusView: UIView!
    @IBOutlet weak var interestStackView: UIStackView!
    @IBOutlet weak var interestViewHeight: NSLayoutConstraint!
    @IBOutlet weak var moreFocusButton: UIButton!
    @IBOutlet weak var moreOrLessButtonStackHeight: NSLayoutConstraint!
    @IBOutlet weak var moreOrLessButtonStack: UIStackView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var lessButton: UIButton!
    
    // recent post stack
    @IBOutlet weak var recentPostTableView: UITableView!
    @IBOutlet weak var recentPostTableViewHeight: NSLayoutConstraint!
    
    // Events Stack
	// Location Description (would this be location description?)
	// Location FOCUS button (what would this be for?)
	// Collection view See more... button
    
    @IBOutlet weak var eventsStackView: UIStackView!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var eventsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var moreEventsButtonView: UIView!
    @IBOutlet weak var moreEventsButton: UIButton!
	// (and also any of the ones after)
    @IBOutlet weak var eventView: UIView!
	
    @IBOutlet weak var eventHeader: UILabel!
    var followers = [User]()
    var following = [User]()
    
    @IBOutlet weak var createEventButton: UIButton!
    var suggestion = [Event]()
    let geoFire = GeoFire(firebaseRef: Database.database().reference().child("event_locations"))
    
    var otherUser = false
    var userID = ""
    var previous: previousScreen? = nil
    
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        present(vc, animated: true, completion: nil)
    }
    
    // Back button
	@IBAction func backButton(_ sender: Any) {
        if otherUser{
            switch(previous!){
            case .people:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
                VC?.showTab = 1
                self.present(VC!, animated: true, completion: nil)
            case .notification:
                let storyboard = UIStoryboard(name: "Notif_Invite_Feed", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NotifViewController") as! NotificationFeedViewController
                
                dropfromTop(view: self.view)
                
                self.present(vc, animated: true, completion: nil)
            }
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
            
            self.present(VC!, animated: true, completion: nil)
        }
        
	}
	
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        let selectInterests = InterestsViewController(nibName: "InterestsViewController", bundle: nil)
        self.present(selectInterests, animated: true, completion: nil)
    }
	
	// Edit Description button
	@IBAction func editDescription(_ sender: UIButton) {
        if editButton.title(for: .normal) == "edit"{
            let scrollPoint = CGPoint(x: 0, y: sender.frame.origin.y + 200)
            self.userScrollView.setContentOffset(scrollPoint, animated: true)
            
            descriptionText.textColor = .black
            descriptionText.backgroundColor = .white
            descriptionText.becomeFirstResponder()
            editButton.setTitle("save", for: .normal)
        }
        else{
            descriptionText.textColor = .white
            descriptionText.backgroundColor = .clear
            descriptionText.resignFirstResponder()
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("description").setValue(descriptionText.text)
            editButton.setTitle("edit", for: .normal)
        }
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Answers.logCustomEvent(withName: "Screen",
                               customAttributes: [
                                "Name": "User Profile"
            ])
        
        // Do any additional setup after loading the view.
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.view.backgroundColor = Constants.color.navy
        self.navBar.barTintColor = Constants.color.navy
        self.navBar.titleTextAttributes = attrs
        
        hideKeyboardWhenTappedAround()
        
        self.moreButton.layer.borderWidth = 1.0
        self.moreButton.layer.borderColor = UIColor.white.cgColor
        self.moreButton.roundCorners(radius: 5.0)
        self.lessButton.layer.borderWidth = 1.0
        self.lessButton.layer.borderColor = UIColor.white.cgColor
        self.lessButton.roundCorners(radius: 5.0)
        
        let eventsCollectionNib = UINib(nibName: "UserProfileCollectionViewCell", bundle: nil)
        self.eventsCollectionView.register(eventsCollectionNib, forCellWithReuseIdentifier: "eventsCollectionCell")
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showFollowing))
        followingStackView.isUserInteractionEnabled = true
        followingStackView.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.showFollower))
        followerStackView.isUserInteractionEnabled = true
        followerStackView.addGestureRecognizer(tap1)
        
//      Use tags in order to allow for only IBAction that will track
//      each event based on the tag of the sender
        self.moreFocusButton.tag = 2
        self.createPinButton.roundCorners(radius: 10)
        
        self.roundImagesAndButtons()

        self.navigationController?.navigationBar.titleTextAttributes = [
             NSFontAttributeName: UIFont(name: "Avenir Book", size: 21)!]
        
        getEventSuggestions()
        getPin()
        
        self.navigationItem.title = ""
        
        self.createEventButton.roundCorners(radius: 10.0)
        
        if otherUser{
            self.editButton.isHidden = true
            self.createEventButton.isHidden = true
            self.createPinButton.isHidden = true
            self.updatePinButton.isHidden = true
            self.createEventButton.isHidden = true
            self.settingButton.isHidden = true
        }
        
        let ID = otherUser ? self.userID : AuthApi.getFirebaseUid()!
        Constants.DB.pins.child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let value = value
            {
                
                self.pinInfo = pinData(UID: value["fromUID"] as! String, dateTS: value["time"] as! Double, pin: value["pin"] as! String, location: value["formattedAddress"] as! String, lat: value["lat"] as! Double, lng: value["lng"] as! Double, path: Constants.DB.pins.child(ID ), focus: value["focus"] as? String ?? "")

                if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: (self.pinInfo?.dateTimeStamp)!), to: Date()).hour ?? 0 >= 0{
                    if value["images"] != nil{
                        
                    }
                    
                    self.createPinAndUpdatePinStack.addArrangedSubview(self.pinView)
                    self.createPinAndUpdatePinStack.removeArrangedSubview(self.createPinView)
                    self.createPinView.removeFromSuperview()
                    self.createPinButton.isHidden = true

                    if let focusVal = value["focus"] as? String{
                        addGreenDot(label: self.pinCategoryLabel, content: focusVal)
                    }else{
                        addGreenDot(label: self.pinCategoryLabel, content: "N.A.")
                    }
                    self.pinAddress2Label.text = value["pin"] as? String
                    
                    if let likes = value["like"] as? [String:Any]{
                        let count = likes["num"] as? Int
                        
                        var label = "like"
                        if count! > 1{
                            label = "likes"
                        }
                        self.pinLikesLabel.text = "\(count!) \(label)"
                    }
                    
                    if let images = value["images"] as? [String:Any]{
                        let imageURL = (images[images.keys.first!] as? [String:Any])?["imagePath"] as? String
                        let pinImage = Constants.storage.pins.child(imageURL!)
                        
                        // Fetch the download URL
                        pinImage.downloadURL { url, error in
                            if error != nil {
                                // Handle any errors
                            } else {
                                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                                    (receivedSize :Int, ExpectedSize :Int) in
                                    
                                }, completed: {
                                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                                    
                                    if image != nil && finished{
                                        self.pinImage.image = image
                                    }
                                })
                                
                            }
                        }
                    }
                    else{
                        self.pinImage.image = #imageLiteral(resourceName: "placeholder_pin")
                    }
                }else{ // FOR OLD PIN
                    self.createPinAndUpdatePinStack.addArrangedSubview(self.pinView)
                    self.createPinAndUpdatePinStack.removeArrangedSubview(self.createPinView)
                    self.createPinView.removeFromSuperview()
                }
                
                self.secondBorderHeight.constant = 5
            }else{
                
                self.secondBorderHeight.constant = 20
                self.createPinAndUpdatePinStack.removeArrangedSubview(self.pinView)
                self.pinView.removeFromSuperview()
                self.createPinButton.isHidden = false
            }
        })
        
        let pinDetail = UITapGestureRecognizer(target: self, action: #selector(self.showPin))
        pinView.isUserInteractionEnabled = true
        pinView.addGestureRecognizer(pinDetail)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userImage.image = #imageLiteral(resourceName: "placeholder_people")
//        TODO: line 336 is returning nil.  You can test when signing into the focusdummy@gmail.com account
        if let url = URL(string: AuthApi.getUserImage()!){
            SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                (receivedSize :Int, ExpectedSize :Int) in
                
            }, completed: {
                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                
                if image != nil && finished{
                    self.userImage.image = crop(image: image!, width: 85, height: 85)
                }
            })
        }
    }
    
//    MARK: COLLECTIONVIEW DELEGATE METHODS
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.suggestion.count > 3 ? 3 : self.suggestion.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCollectionCell", for: indexPath) as! UserProfileCollectionViewCell
        
        if indexPath.row == 0{
            self.eventsViewHeight.constant = eventCell.frame.height
        }else if indexPath.row == 2 || indexPath.row == 4{
            self.eventsViewHeight.constant += (eventCell.frame.height + 20)
        }
        
        let suggestion = self.suggestion[indexPath.row]
//        eventCell.userEventsLabel.text = suggestion.title
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        eventCell.userEventsLabel.text = suggestion.title
        
        let reference = Constants.storage.event.child("\(suggestion.id!).jpg")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            eventCell.userEventsImage.sd_setImage(with: url, placeholderImage: placeholderImage)
            eventCell.userEventsImage.setShowActivityIndicator(true)
            eventCell.userEventsImage.setIndicatorStyle(.gray)
            
        })
            
        return eventCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let suggestion = self.suggestion[indexPath.row]
        
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
        controller.event = suggestion
        self.present(controller, animated: true, completion: nil)
    }
    
    func showFollowing(sender:UITapGestureRecognizer) {
        let followerViewController = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        followerViewController.windowTitle = "Following"
        followerViewController.ID = AuthApi.getFirebaseUid()!
        self.present(followerViewController, animated: true, completion: nil)
    }
    
    func showFollower(sender:UITapGestureRecognizer) {
        let followerViewController = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        followerViewController.windowTitle = "Followers"
        followerViewController.ID = AuthApi.getFirebaseUid()!
        self.present(followerViewController, animated: true, completion: nil)
    }
    
    func showPin(sender: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
        ivc.data = self.pinInfo
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    func displayUserData() {
        let ID = otherUser ? self.userID : AuthApi.getFirebaseUid()!
        Constants.DB.user.child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionnary = snapshot.value as? NSDictionary {
//                print(dictionnary)
                let username_str = dictionnary["username"] as? String ?? ""
                let description_str = dictionnary["description"] as? String ?? ""
                let image_string = dictionnary["image_string"] as? String ?? ""
                let fullname = dictionnary["fullname"] as? String ?? ""
                
                self.fullNameLabel.text = fullname
                self.descriptionText.text = description_str
                
                self.navBarItem.title = username_str
                
                if let followers = dictionnary["followers"] as? [String:Any]{
                    if let people = followers["people"] as? [String:[String:Any]]{
                        let count = people.count
                        
                        self.followerCount.setTitle("\(count)", for: .normal)
                    }
                }
                
                if let followers = dictionnary["following"] as? [String:Any]{
                    if let people = followers["people"] as? [String:[String:Any]]{
                        let count = people.count
                        
                        self.followingCount.setTitle("\(count)", for: .normal)
                    }
                }
                
                if let pinCount = dictionnary["pinCount"] as? Int{
                    self.pinCount.setTitle("\(pinCount)", for: .normal)
                }
                else{
                    self.pinCount.setTitle("0", for: .normal)
                }
                
                
                if self.otherUser{
                    if let interests = dictionnary["interests"] as? String{
                        let selected = interests.components(separatedBy: ",")
                        
                        var final_interest = [String]()
                        for interest in selected{
                            final_interest.append(interest.components(separatedBy: "-")[0])
                        }
                        
                        print("self.otherUser condition: \(self.interestStackView.arrangedSubviews.count)")
                        
                        for view in self.interestStackView.arrangedSubviews{
                            self.interestStackView.removeArrangedSubview(view)
                        }
                        
                        for (_, interest) in (final_interest.enumerated()){
                            let interestLabelView = InterestStackViewLabel()
                            interestLabelView.interestLabel.text = interest
                            
                            let interestImage = "\(interest) Green"
                            interestLabelView.interestLabelImage.image = UIImage(named: interestImage)
                            interestLabelView.addButton.isSelected = true
                            if interest.characters.count > 0{
                                self.interestStackView.addArrangedSubview(interestLabelView)
                                self.interestViewHeight.constant += interestLabelView.frame.size.height
                            }
                        }
                        
                        if final_interest.count > 3{
                            self.moreFocusButton.setTitle("More", for: .normal)
                        }
                        else{
                            self.moreFocusButton.isHidden = true
                        }
                        
                    }
                }
            }
        })
        
        if !otherUser{
            let interests = getUserInterests().components(separatedBy: ",")
            
            print("!otherUser condition: \(self.interestStackView.arrangedSubviews.count)")
            print("interests amount: \(interests)")
            if interests.count > 3 {
                self.moreOrLessButtonStack.isHidden = false
                self.moreOrLessButtonStack.removeArrangedSubview(self.lessButton)
                self.lessButton.isHidden = true
                self.moreOrLessButtonStackHeight.constant = 20.0
            }else{
                self.moreOrLessButtonStack.isHidden = true
                //                self.containerStackForMoreOrLessButtons.removeFromSuperview()
            }
            
            if interestStackView.arrangedSubviews.count > 0{
                var endIndex = interestStackView.arrangedSubviews.count-1
                while endIndex >= 0{
                    interestStackView.arrangedSubviews[endIndex].removeFromSuperview()
                    endIndex -= 1
                }
            }
            
            for (index, interest) in (interests.enumerated()){
                let interestLabelView = InterestStackViewLabel(frame: CGRect(x: 0, y: 0, width: self.interestStackView.bounds.width, height: 30))
                
                if interest.characters.count > 0{
                    interestLabelView.view.bounds.size.width = self.interestStackView.frame.size.width
                    interestLabelView.view.center = interestLabelView.center
                    interestLabelView.interestLabel.text = interest
                    let interestImage = "\(interest) Green"
                    interestLabelView.interestLabelImage.image = UIImage(named: interestImage)
                    
                    
                    if index < 3{
                        interestLabelView.addButton.isSelected = true
                        self.interestStackView.addArrangedSubview(interestLabelView)
                        self.interestStackView.translatesAutoresizingMaskIntoConstraints = false
                    }else{
                        interestLabelView.addButton.isSelected = true
                        self.hiddenInterests.append(interestLabelView)
                    }
                }
            }
            
            guard let firstFocusView = self.interestStackView.arrangedSubviews.first else {
                return
            }
            
            if self.interestStackView.arrangedSubviews.count <= 1{
                self.interestViewHeight.constant = firstFocusView.frame.height
            }else{
                self.interestViewHeight.constant = CGFloat((firstFocusView.frame.height + 15) * CGFloat(self.interestStackView.arrangedSubviews.count))
            }
            
            print("End: \(interestStackView.arrangedSubviews.count)")
            
        }
        
    }
    
    @IBAction func moreInterestsButtonPressed(_ sender: Any) {
        if self.hiddenInterests.count > 0{
            for interestViewIndex in 0...self.hiddenInterests.count-1{
                self.interestStackView.addArrangedSubview(self.hiddenInterests[interestViewIndex])
            }
            
            guard let firstFocusView = self.interestStackView.arrangedSubviews.first else {
                return
            }
            
            self.interestViewHeight.constant = CGFloat((firstFocusView.bounds.size.height) * CGFloat(self.interestStackView.arrangedSubviews.count))
            
            self.lessButton.isHidden = false
            self.moreOrLessButtonStack.addArrangedSubview(self.lessButton)
            self.moreOrLessButtonStack.removeArrangedSubview(self.moreButton)
            self.moreButton.isHidden = true
            self.moreOrLessButtonStackHeight.constant = 20.0
        }
    }
    
    @IBAction func lessButtonPressed(_ sender: Any) {
        for arrangedInterestIndex in 0...self.hiddenInterests.count-1{
            self.interestStackView.removeArrangedSubview(self.hiddenInterests[arrangedInterestIndex])
        }
        
        guard let firstFocusView = self.interestStackView.arrangedSubviews.first else {
            return
        }
        
        self.interestViewHeight.constant = CGFloat((firstFocusView.bounds.size.height) * CGFloat(self.interestStackView.arrangedSubviews.count))
        
        self.moreButton.isHidden = false
        self.moreOrLessButtonStack.addArrangedSubview(self.moreButton)
        self.moreOrLessButtonStack.removeArrangedSubview(self.lessButton)
        self.lessButton.isHidden = true
        self.moreOrLessButtonStackHeight.constant = 20.0
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPin() {
        
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let value = value
            {
                self.pinAddress2Label.text = value["pin"] as? String
                if let likes = value["like"] as? NSDictionary{
                    if let likeCount = likes["num"] as? Int{
                        var likeLabel = "like"
                        if likeCount > 1{
                            likeLabel.append("s")
                        }
                        self.pinLikesLabel.text = "\(likeCount) \(likeLabel)"
                    }
                    
                }
                
                let pin_location = CLLocation(latitude: value["lat"] as! Double, longitude: value["lng"] as! Double)
                self.pinDistanceLabel.text = getDistance(fromLocation: pin_location, toLocation: AuthApi.getLocation()!)
            }
        })
        
    }

    @IBAction func updatePin(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMapViewControllerFromPersonalUserProfilePlaceDetailsOrEventDetails", sender: self)
    }
    
    func getEventSuggestions(){
        
        let ID = otherUser ? self.userID : AuthApi.getFirebaseUid()!
        Constants.DB.event.queryOrdered(byChild: "creator").queryEqual(toValue: ID).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { snapshot in
            let eventInfo = snapshot.value as? [String : Any]
            
            if let eventInfo = eventInfo{
                _ = eventInfo.count
                for (id, event) in eventInfo{
                    if let info = event as? [String:Any]{
                        if let event = Event.toEvent(info: info){
                            event.id = id
                            self.suggestion.append(event)
                        }
                    }
                }
            }
            
            if self.suggestion.count > 0{
                self.eventsCollectionView.reloadData()
                self.eventsStackView.addArrangedSubview(self.eventsCollectionView)
                self.eventsStackView.removeArrangedSubview(self.createEventButton)
                self.eventsViewHeight.constant += (self.eventsCollectionView.frame.size.height - self.createEventButton.frame.size.height)
                
                self.createEventButton.superview?.sendSubview(toBack: self.createEventButton)
                self.createEventButton.alpha = 0
            }
            else{
                self.eventsViewHeight.constant -= self.eventsCollectionView.frame.size.height
                self.eventsStackView.addArrangedSubview(self.createEventButton)
                self.eventsStackView.removeArrangedSubview(self.eventsCollectionView)
                
                self.createEventButton.superview?.bringSubview(toFront: self.createEventButton)
                self.createEventButton.alpha = 1
            }
            
            self.eventsStackView.translatesAutoresizingMaskIntoConstraints = false;
            
        })
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations/event").queryOrdered(byChild: "status").queryEqual(toValue: "accepted").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            
            if let placeData = value{
                let count = placeData.count
                for (_,place) in placeData
                {
                    let id = (place as? [String:Any])?["ID"]
                    
                    Constants.DB.event.child(id as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let info = snapshot.value as? [String : Any], info.count > 0{
                            let event = Event.toEvent(info: info)
                            event?.id = id as! String
                            
                            let eventLocation = CLLocation(latitude: Double((info["longitude"])! as! String)!, longitude: Double((info["longitude"])! as! String)!)
                            
                            event?.distance = eventLocation.distance(from: AuthApi.getLocation()!)
                            if let attending = info["attendingList"] as? [String:Any]{
                                event?.setAttendessCount(count: attending.count)
                            }
                            
                            
                            self.suggestion.append(event!)
                            if self.suggestion.count == count{
                                if self.suggestion.count > 0{
    
                                    self.eventsCollectionView.reloadData()
                                    
                                    self.createEventButton.superview?.sendSubview(toBack: self.createEventButton)
                                    
                                    self.createEventButton.alpha = 0
                                }
                                else{
                                    self.createEventButton.superview?.bringSubview(toFront: self.createEventButton)
                                    self.createEventButton.alpha = 1
                                }
                            }
                            
                        }
                        
                        
                    })
                }
            }
        })
    }
    
    func roundImagesAndButtons(){
        self.updatePinButton.roundCorners(radius: 10.0)
        
        self.userImage.layer.borderWidth = 2
        self.userImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userImage.roundedImage()
        
        self.pinImage.layer.borderWidth = 1
        self.pinImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.pinImage.roundedImage()
        
        self.editButton.layer.borderWidth = 1
        self.editButton.layer.borderColor = UIColor.white.cgColor
        self.editButton.roundCorners(radius: 5.0)
       
        self.moreFocusButton.layer.borderWidth = 1
        self.moreFocusButton.layer.borderColor = UIColor.white.cgColor
        self.moreFocusButton.roundCorners(radius: 5.0)
        
    }
    
    @IBAction func createPin(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMapViewControllerFromPersonalUserProfilePlaceDetailsOrEventDetails", sender: self)
    }
    
    @IBAction func createEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
        self.present(controller, animated: true, completion: nil)

    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
}
