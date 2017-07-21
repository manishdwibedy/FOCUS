//
//  OtherUserProfileViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import GeoFire
import FirebaseDatabase

class OtherUserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var followYourFriendsView: UIView!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet var userScrollView: UIScrollView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var peopleMoreButton: UIButton!
    @IBOutlet weak var eventMoreButton: UIButton!
    @IBOutlet weak var otherEventStackView: UIStackView!
    @IBOutlet weak var otherPlaceStackView: UIStackView!
    @IBOutlet weak var eventsCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var recentPostTableView: UITableView!
    @IBOutlet weak var recentPostTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHeightHoldingRecentPostTableView: NSLayoutConstraint!
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var pinView: UIView!
    
    @IBOutlet weak var pinViewHeight: NSLayoutConstraint!
    // User data
    //	@IBOutlet var userName: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var otherUserNameInterestTitleLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    //    @IBOutlet weak var suggestionsHeight: NSLayoutConstraint!
    
    // follower and following
    @IBOutlet weak var followerStackView: UIStackView!
    @IBOutlet weak var followingStackView: UIStackView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followerCount: UIButton!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followingCount: UIButton!
    
    // user pin info
    
    @IBOutlet weak var greenDotImage: UIImageView!
    //    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinCategoryLabel: UILabel!
    @IBOutlet weak var pinLikesLabel: UILabel!
    @IBOutlet weak var pinAddress2Label: UILabel!
    
    @IBOutlet weak var pinDistanceLabel: UILabel!
    @IBOutlet weak var pinCount: UIButton!
    var pinInfo: pinData? = nil
    
    //    MARK: Do we still need this
    //    @IBOutlet weak var pinDescription: UILabel!
    @IBOutlet weak var updatePinButton: UIButton!
    @IBOutlet weak var emptyPinButton: UIButton!
    
    // user interests
    @IBOutlet weak var focusHeader: UILabel!
    @IBOutlet weak var focusView: UIView!
    @IBOutlet weak var interestStackView: UIStackView!
    @IBOutlet weak var interestViewHeight: NSLayoutConstraint!
    @IBOutlet weak var interestStackHeight: NSLayoutConstraint!
    @IBOutlet weak var moreFocusButton: UIButton!
    
    // Location Description (would this be location description?)
    // Location FOCUS button (what would this be for?)
    // Collection view See more... button
    @IBOutlet weak var moreEventsButton: UIButton!
    // (and also any of the ones after)
    @IBOutlet weak var eventView: UIView!
    
    @IBOutlet weak var eventHeader: UILabel!
    var followers = [User]()
    var following = [User]()
    var interestArray = [Interest]()
    
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
//        if editButton.title(for: .normal) == "edit"{
//            let scrollPoint = CGPoint(x: 0, y: sender.frame.origin.y + 200)
//            self.userScrollView.setContentOffset(scrollPoint, animated: true)
//            
//            descriptionText.isEditable = true
//            descriptionText.textColor = .black
//            descriptionText.backgroundColor = .white
//            descriptionText.becomeFirstResponder()
//            editButton.setTitle("save", for: .normal)
//        }
//        else{
//            descriptionText.isEditable = false
//            descriptionText.textColor = .white
//            descriptionText.backgroundColor = .clear
//            descriptionText.resignFirstResponder()
//            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("description").setValue(descriptionText.text)
//            editButton.setTitle("edit", for: .normal)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recentPostTableView.dataSource = self
        self.recentPostTableView.delegate = self
        
        let recentPostNib = UINib(nibName: "FeedOneTableViewCell", bundle: nil)
        self.recentPostTableView.register(recentPostNib, forCellReuseIdentifier: "recentPostCell")
        self.recentPostTableView.rowHeight = UITableViewAutomaticDimension
        
        self.placesTableView.dataSource = self
        self.placesTableView.delegate = self
        
        let placeNib = UINib(nibName: "PlacesOtherWillLikeTableViewCell", bundle: nil)
        self.placesTableView.register(placeNib, forCellReuseIdentifier: "placesCell")
        
        self.eventsTableView.dataSource = self
        self.eventsTableView.delegate = self
        
        let eventNib = UINib(nibName: "EventOtherWillLikeTableViewCell", bundle: nil)
        self.eventsTableView.register(eventNib, forCellReuseIdentifier: "eventsCell")
        
//        self.peopleMoreButton.layer.borderWidth = 1.0
//        self.peopleMoreButton.layer.borderColor = UIColor.white.cgColor
//        self.peopleMoreButton.roundCorners(radius: 5.0)
//        
//        self.eventMoreButton.layer.borderWidth = 1.0
//        self.eventMoreButton.layer.borderColor = UIColor.white.cgColor
//        self.eventMoreButton.roundCorners(radius: 5.0)
        
        self.otherUserNameInterestTitleLabel.text = "alex\'s FOCUS"
        
        // Do any additional setup after loading the view.
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        
        self.followButton.roundCorners(radius: 5.0)
        self.messageButton.roundCorners(radius: 5.0)
        self.inviteButton.roundCorners(radius: 5.0)
        
        hideKeyboardWhenTappedAround()
        
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
//        self.moreFocusButton.tag = 2
        self.moreEventsButton.tag = 3
//        self.emptyPinButton.roundCorners(radius: 10)
        
        self.roundImagesAndButtons()
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 21)!]
        
//        getEventSuggestions()
//        getPin()
        
//        self.pinView.addTopBorderWithColor(color: UIColor.white, width: 1)
//        self.userInfoView.addBottomBorderWithColor(color: UIColor.white, width: 0.3)
//        self.otherPlaceStackView.addBottomBorderWithColor(color: UIColor.white, width: 0.3)
//        self.otherEventStackView.addBottomBorderWithColor(color: UIColor.white, width: 0.3)
//        self.focusView.addBottomBorderWithColor(color: UIColor.white, width: 0.3)
//        self.focusView.addTopBorderWithColor(color: UIColor.white, width: 0.3)
//        self.navigationItem.title = ""
        
        self.createEventButton.roundCorners(radius: 6)
        
        if otherUser{
//            self.editButton.isHidden = true
            self.createEventButton.isHidden = true
//            self.emptyPinButton.isHidden = true
//            self.updatePinButton.isHidden = true
            self.createEventButton.isHidden = true
//            self.settingButton.isHidden = true
        }
        
        let ID = otherUser ? self.userID : AuthApi.getFirebaseUid()!
        Constants.DB.pins.child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let value = value
            {
                
                self.pinInfo = pinData(UID: value["fromUID"] as! String, dateTS: value["time"] as! Double, pin: value["pin"] as! String, location: value["formattedAddress"] as! String, lat: value["lat"] as! Double, lng: value["lng"] as! Double, path: Constants.DB.pins.child(ID ), focus: value["focus"] as? String ?? "")
                
                if Calendar.current.dateComponents([.hour], from: Date(timeIntervalSince1970: (self.pinInfo?.dateTimeStamp)!), to: Date()).hour ?? 0 < 24{
                    if value["images"] != nil{
                        
                    }
//                    self.emptyPinButton.isHidden = true
                    
//                    self.pinCategoryLabel.text = value["focus"] as? String
//                    self.pinAddress2Label.text = value["pin"] as? String
                    
                    if let likes = value["like"] as? [String:Any]{
                        let count = likes["num"] as? Int
                        
                        var label = "like"
                        if count! > 1{
                            label = "likes"
                        }
//                        self.pinLikesLabel.text = "\(count!) \(label)"
                    }
                    
                    if let images = value["images"] as? [String:Any]{
                        let imageURL = (images[images.keys.first!] as? [String:Any])?["imagePath"] as? String
//                        let pinImage = Constants.storage.pins.child(imageURL!)
                        
                        // Fetch the download URL
//                        pinImage.downloadURL { url, error in
//                            if error != nil {
//                                // Handle any errors
//                            } else {
//                                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
//                                    (receivedSize :Int, ExpectedSize :Int) in
//                                    
//                                }, completed: {
//                                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
//                                    
//                                    if image != nil && finished{
//                                        self.pinImage.image = image
//                                    }
//                                })
//                                
//                            }
//                        }
                    }
                    
                }
                    
                    // OLD PIN
                else{
                    self.view.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 706)
                    self.userScrollView.frame = CGRect(x: 0, y: 0, width: Int(self.userScrollView.frame.width), height: 572)
//                    self.mainViewHeight.constant = 750
                    
//                    self.pinViewHeight.constant = 45
                    
//                    self.emptyPinButton.isHidden = false
//                    self.emptyPinButton.setTitle("Update Pin", for: .normal)
//                    self.pinDistanceLabel.isHidden = true
//                    self.pinAddress2Label.isHidden = true
//                    self.greenDotImage.isHidden = true
//                    self.pinImage.isHidden = true
//                    self.pinCategoryLabel.isHidden = true
//                    self.pinLikesLabel.isHidden = true
//                    self.updatePinButton.isHidden = true
                    
                }
                
                
                
            }
            else{
                self.view.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 706)
                self.userScrollView.frame = CGRect(x: 0, y: 0, width: Int(self.userScrollView.frame.width), height: 572)
//                self.mainViewHeight.constant = 750
                
//                self.pinViewHeight.constant = 45
                
//                self.emptyPinButton.isHidden = false
//                
//                self.pinDistanceLabel.isHidden = true
//                self.pinAddress2Label.isHidden = true
//                self.greenDotImage.isHidden = true
//                self.pinImage.isHidden = true
//                self.pinCategoryLabel.isHidden = true
//                self.pinLikesLabel.isHidden = true
//                self.updatePinButton.isHidden = true
                
            }
        })
        
        let pinDetail = UITapGestureRecognizer(target: self, action: #selector(self.showPin))
//        pinView.isUserInteractionEnabled = true
//        pinView.addGestureRecognizer(pinDetail)
        
//        let ogEventCollectionViewHeight = self.eventsCollectionViewHeight.constant
//        self.eventsCollectionViewHeight.constant = self.eventsCollectionView.contentSize.height
        self.eventView.bounds.size.height += (self.eventsCollectionView.contentSize.height)
//        self.mainViewHeight.constant += (self.eventsCollectionView.contentSize.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //    MARK: COLLECTIONVIEW DELEGATE METHODS
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
//        return self.suggestion.count > 3 ? 3 : self.suggestion.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCollectionCell", for: indexPath) as!UserProfileCollectionViewCell
        
//        let suggestion = self.suggestion[indexPath.row]
        //        eventCell.userEventsLabel.text = suggestion.title
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        eventCell.userEventsLabel.text = "Event \((indexPath.row+1))"
        
//        eventCell.userEventsLabel.text = suggestion.title
        
/*
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
*/
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
        followerViewController.ID = self.userID
        self.present(followerViewController, animated: true, completion: nil)
    }
    
    func showFollower(sender:UITapGestureRecognizer) {
        let followerViewController = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        followerViewController.windowTitle = "Followers"
        followerViewController.ID = self.userID
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
                
                
                //                SAMPLE description text
                //self.descriptionText.text = description
                self.fullNameLabel.text = fullname
//                self.userNameLabel.text = username_str
                
                self.descriptionText.text = "ctetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut lab pecu, sed do eiusmod tempor incididunt ut lab pecu, sed do eiusmod tempor incididunt ut lab pecu, sed do eiusmod tempor incididunt ut lab"
//                self.descriptionText.text = description_str
                
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
                            let textLabel = UILabel()
                            
                            textLabel.textColor = .white
                            textLabel.text  = interest
                            textLabel.textAlignment = .left
                            let interestView = InterestStackViewLabel()
                            interestView.interestLabel.text = interest
                            let interestImage = "\(interest) Green"
                            interestView.interestLabelImage.image = UIImage(named: interestImage)
                            
                            if interest.characters.count > 0{
                                if self.interestStackView.arrangedSubviews.count < 3{
                                    let interestSubView = UIView(frame: CGRect(x: 0, y: 0, width: self.interestStackView.frame.size.width, height: 20))
                                    interestSubView.addSubview(interestView)
                                    
//                                    self.interestStackView.addArrangedSubview(textLabel)
                                    self.interestStackView.addArrangedSubview(interestSubView)
//                                    self.interestStackView.bounds.size.height += interestSubView.frame.size.height
//                                    self.interestViewHeight.constant += interestSubView.frame.size.height/4
                                    self.interestStackView.translatesAutoresizingMaskIntoConstraints = false;
                                }
                            }
                        }
                        
                        if final_interest.count > 3{
//                            self.moreFocusButton.setTitle("More", for: .normal)
                        }
                        else{
//                            self.moreFocusButton.isHidden = true
                        }
                        
//                        let count = self.interestStackView.arrangedSubviews.count
//                        self.interestStackHeight.constant = CGFloat(25 * count)
//                        self.interestViewHeight.constant = CGFloat(25 * count + 113)
                    }
                }
                
                self.userImage.image = #imageLiteral(resourceName: "empty_event")
                if let url = URL(string: image_string){
                    SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                        (receivedSize :Int, ExpectedSize :Int) in
                        
                    }, completed: {
                        (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                        
                        if image != nil && finished{
                            self.userImage.image = crop(image: image!, width: 85, height: 85)
                        }
                    })
                }
                //                self.userImage.sd_setImage(with: URL(string: image_string), placeholderImage: UIImage(named: "empty_event"))
                
            }
            
        })
        
        if !otherUser{
            let interests = getUserInterests().components(separatedBy: ",")
            
            print("!otherUser condition: \(self.interestStackView.arrangedSubviews.count)")
            
            if interestStackView.arrangedSubviews.count > 0{
                var endIndex = interestStackView.arrangedSubviews.count-1
                while endIndex >= 0{
                    interestStackView.arrangedSubviews[endIndex].removeFromSuperview()
                    endIndex -= 1
                }
            }
            
            for (_, interest) in (interests.enumerated()){
                
                let textLabel = UILabel()
                
                textLabel.textColor = .white
                textLabel.text  = interest
                textLabel.textAlignment = .left
                
                if interest.characters.count > 0{
                    if interestStackView.arrangedSubviews.count < 3{
                        let interestView = InterestStackViewLabel()
                        interestView.interestLabel.text = interest
                        let interestSubView = UIView(frame: CGRect(x: 0, y: 0, width: self.interestStackView.frame.size.width, height: 20))
                        
                        interestSubView.addSubview(interestView)
                        self.interestStackView.addArrangedSubview(interestSubView)
//                        self.interestStackView.bounds.size.height += interestSubView.frame.size.height
//                        self.interestViewHeight.constant += interestSubView.frame.size.height/4
                        
                        interestStackView.translatesAutoresizingMaskIntoConstraints = false;
                    }
                }
            }
            
//            print(interestStackView.arrangedSubviews.count)
            
//            let count = interestStackView.arrangedSubviews.count
//            interestStackHeight.constant = CGFloat(25 * count)
//            interestViewHeight.constant = CGFloat(25 * count + 113)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayUserData()
        
        let fixedWidth = self.descriptionText.frame.size.width
        self.descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = self.descriptionText.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = self.descriptionText.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        self.descriptionText.frame = newFrame
        self.recentPostTableViewHeight.constant = self.recentPostTableView.contentSize.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
    //        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
    //        self.present(vc, animated: true, completion: nil)
    //    }
    
    
    func getPin() {
        
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let value = value
            {
//                self.pinAddress2Label.text = value["pin"] as? String
                if let likes = value["like"] as? NSDictionary{
                    if let likeCount = likes["num"] as? Int{
                        var likeLabel = "like"
                        if likeCount > 1{
                            likeLabel.append("s")
                        }
//                        self.pinLikesLabel.text = "\(likeCount) \(likeLabel)"
                    }
                    
                }
                
                let pin_location = CLLocation(latitude: value["lat"] as! Double, longitude: value["lng"] as! Double)
//                self.pinDistanceLabel.text = getDistance(fromLocation: pin_location, toLocation: AuthApi.getLocation()!)
            }
        })
        
    }
    
    @IBAction func updatePin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "Home") as? PinScreenViewController
        self.present(VC!, animated: true, completion: nil)
    }
    
    func getEventSuggestions(){
        self.moreEventsButton.isHidden = false
        
        let ID = otherUser ? self.userID : AuthApi.getFirebaseUid()!
        Constants.DB.event.queryOrdered(byChild: "creator").queryEqual(toValue: ID).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { snapshot in
            let eventInfo = snapshot.value as? [String : Any]
            
            if let eventInfo = eventInfo{
                _ = eventInfo.count
                for (id, event) in eventInfo{
                    let info = event as? [String:Any]
                    let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as? String, shortAddress: (info?["shortAddress"])! as? String, latitude: (info?["latitude"])! as? String, longitude: (info?["longitude"])! as? String, date: (info?["date"])! as! String, creator: (info?["creator"])! as? String, id: id, category: info?["interest"] as? String, privateEvent: (info?["private"] as? Bool)!)
                    
                    self.suggestion.append(event)
                }
            }
            
            if self.suggestion.count > 3{
                self.moreEventsButton.isHidden = false
            }
            else{
                self.moreEventsButton.isHidden = true
            }
            
            self.eventsCollectionView.reloadData()
            
//            if self.suggestion.count > 0{
//                if self.suggestion.count > 3{
//                    self.moreEventsButton.isHidden = false
//                }
//                else{
//                    self.moreEventsButton.isHidden = true
//                }
//                
//                self.eventsCollectionView.reloadData()
//                
//                self.createEventButton.superview?.sendSubview(toBack: self.createEventButton)
//                self.createEventButton.alpha = 0
//            }
//            else{
//                self.createEventButton.superview?.bringSubview(toFront: self.createEventButton)
//                self.createEventButton.alpha = 1
//            }
            
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
                                
                                if self.suggestion.count > 3{
                                    self.moreEventsButton.isHidden = false
                                }
                                else{
                                    self.moreEventsButton.isHidden = true
                                }
                                
                                self.eventsCollectionView.reloadData()
                                
                                self.createEventButton.superview?.sendSubview(toBack: self.createEventButton)
                                self.createEventButton.alpha = 0
                                
//                                if self.suggestion.count > 0{
//                                    if self.suggestion.count > 3{
//                                        self.moreEventsButton.isHidden = false
//                                    }
//                                    else{
//                                        self.moreEventsButton.isHidden = true
//                                    }
//                                    
//                                    self.eventsCollectionView.reloadData()
//                                    
//                                    self.createEventButton.superview?.sendSubview(toBack: self.createEventButton)
//                                    self.createEventButton.alpha = 0
//                                }
//                                else{
//                                    self.createEventButton.superview?.bringSubview(toFront: self.createEventButton)
//                                    self.createEventButton.alpha = 1
//                                }
                            }
                            
                        }
                        
                        
                    })
                }
            }
        })
    }
    
    func roundImagesAndButtons(){
//        self.updatePinButton.roundCorners(radius: 10.0)
        
        self.userImage.layer.borderWidth = 2
        self.userImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userImage.roundedImage()
        
//        self.pinImage.layer.borderWidth = 1
//        self.pinImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
//        self.pinImage.roundedImage()
        
//        self.editButton.layer.borderWidth = 1
//        self.editButton.layer.borderColor = UIColor.white.cgColor
//        self.editButton.roundCorners(radius: 5.0)
        
        self.moreEventsButton.layer.borderWidth = 1
        self.moreEventsButton.layer.borderColor = UIColor.white.cgColor
        self.moreEventsButton.roundCorners(radius: 5.0)
    }
    
    @IBAction func createPin(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "home") as! UITabBarController
        vc.selectedIndex = 2
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func createEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
        self.present(controller, animated: true, completion: nil)
    }
    
    //    MARK: TableView Delegate and Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 || tableView.tag == 1{
            return 3
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let placeCell = tableView.dequeueReusableCell(withIdentifier: "placesCell", for: indexPath) as! PlacesOtherWillLikeTableViewCell
            return placeCell
        }else if tableView.tag == 1{
            let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath) as! EventOtherWillLikeTableViewCell
            return eventCell
        }else{
            let recentPostCell = tableView.dequeueReusableCell(withIdentifier: "recentPostCell", for: indexPath) as! FeedOneTableViewCell

            return recentPostCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = CGFloat()
        if tableView.tag == 0{
            rowHeight = 100
        }else if tableView.tag == 1{
            rowHeight = 100
        }else if tableView.tag == 2{
            let myCell = tableView.dequeueReusableCell(withIdentifier: "recentPostCell") as! FeedOneTableViewCell
            rowHeight = myCell.bounds.size.height;
        }
        
        return rowHeight
    }
    
}

