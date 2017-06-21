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

class UserProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UINavigationBarDelegate{

    @IBOutlet weak var eventsCollectionView: UICollectionView!
	@IBOutlet var userScrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var pinView: UIView!
    
    @IBOutlet weak var pinViewHeight: NSLayoutConstraint!
    // User data
//	@IBOutlet var userName: UILabel!
	@IBOutlet var descriptionText: UITextView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
//    @IBOutlet weak var suggestionsHeight: NSLayoutConstraint!
    
    // follower and following
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    // user pin info
    
    @IBOutlet weak var greenDotImage: UIImageView!
//    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var pinCategoryLabel: UILabel!
    @IBOutlet weak var pinLikesLabel: UILabel!
    @IBOutlet weak var pinAddress1Label: UILabel!
    @IBOutlet weak var pinAddress2Label: UILabel!
    @IBOutlet weak var morePinButton: UIButton!
    
//    MARK: Do we still need this
//    @IBOutlet weak var pinDescription: UILabel!
    @IBOutlet weak var updatePinButton: UIButton!
    @IBOutlet weak var emptyPinButton: UIButton!
    
    // user interests
    @IBOutlet weak var interestStackView: UIStackView!
    
	// Haven't added:
	// User FOCUS button
    @IBOutlet weak var moreFocusButton: UIButton!
	// Location Description (would this be location description?)
	// Location FOCUS button (what would this be for?)
	// Collection view See more... button
    @IBOutlet weak var moreEventsButton: UIButton!
	// (and also any of the ones after)
	
    var followers = [User]()
    var following = [User]()
    
    var suggestion = [Event]()
    let geoFire = GeoFire(firebaseRef: Database.database().reference().child("event_locations"))
    
    let pinDataAvailable = true
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        present(vc, animated: true, completion: nil)
    }
    
    // Back button
	@IBAction func backButton(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        print(sender.tag)
    }
	
	// Edit Description button
	@IBAction func editDescription(_ sender: UIButton) {
        if editButton.title(for: .normal) == "edit"{
            let scrollPoint = CGPoint(x: 0, y: sender.frame.origin.y + 200)
            self.userScrollView.setContentOffset(scrollPoint, animated: true)
            
            descriptionText.isEditable = true
            descriptionText.textColor = .black
            descriptionText.backgroundColor = .white
            descriptionText.becomeFirstResponder()
            editButton.setTitle("save", for: .normal)
        }
        else{
            descriptionText.isEditable = false
            descriptionText.textColor = .white
            descriptionText.backgroundColor = .clear
            descriptionText.resignFirstResponder()
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("description").setValue(descriptionText.text)
            editButton.setTitle("edit", for: .normal)
        }
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    
//		userScrollView.contentSize = CGSize(width: 375, height: 1600)
        // Do any additional setup after loading the view.
        
        hideKeyboardWhenTappedAround()
        
        let eventsCollectionNib = UINib(nibName: "UserProfileCollectionViewCell", bundle: nil)
        self.eventsCollectionView.register(eventsCollectionNib, forCellWithReuseIdentifier: "eventsCollectionCell")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showFollowing))
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.showFollower))
        followerLabel.isUserInteractionEnabled = true
        followerLabel.addGestureRecognizer(tap1)
        
//      Use tags in order to allow for only IBAction that will track
//      each event based on the tag of the sender
        self.morePinButton.tag = 1
        self.moreFocusButton.tag = 2
        self.moreEventsButton.tag = 3
        self.emptyPinButton.roundCorners(radius: 10)
        
        self.roundImagesAndButtons()

        self.navigationController?.navigationBar.titleTextAttributes = [
             NSFontAttributeName: UIFont(name: "Avenir Book", size: 21)!]
        
        getEventSuggestions()
        getPin()
        
        if !pinDataAvailable{
            self.view.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: 706)
            userScrollView.frame = CGRect(x: 0, y: 0, width: Int(self.userScrollView.frame.width), height: 572)
            mainViewHeight.constant = 750
        }
        else{
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !pinDataAvailable{
            pinViewHeight.constant = 35
            
            
            
            greenDotImage.isHidden = true
            //            categoryImage.isHidden = true
            pinImage.isHidden = true
            pinLabel.isHidden = true
            pinCategoryLabel.isHidden = true
            pinLikesLabel.isHidden = true
            pinAddress1Label.isHidden = true
            pinAddress2Label.isHidden = true
            updatePinButton.isHidden = true
            morePinButton.isHidden = true
            //            MARK: Do we still need this
            //            pinDescription.isHidden = true
        }
        else{
            emptyPinButton.isHidden = true
            
        }
    }
    
//    MARK: COLLECTIONVIEW DELEGATE METHODS
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        
        return self.suggestion.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCollectionCell", for: indexPath) as!UserProfileCollectionViewCell
        
        let suggestion = self.suggestion[indexPath.row]
//        eventCell.userEventsLabel.text = suggestion.title
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        
        let reference = Constants.storage.event.child("\(suggestion.id).jpg")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            eventCell.userEventsImage.sd_setImage(with: url, placeholderImage: placeholderImage)
            eventCell.userEventsImage.setShowActivityIndicator(true)
            eventCell.userEventsImage.setIndicatorStyle(.gray)
            
        })
            
        return eventCell
    }
    
    func showFollowing(sender:UITapGestureRecognizer) {
        let followerViewController = UIStoryboard(name: "Following", bundle: nil).instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
        self.present(followerViewController, animated: true, completion: nil)
    }
    
    func showFollower(sender:UITapGestureRecognizer) {
        let followerViewController = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        self.present(followerViewController, animated: true, completion: nil)
    }
    
    func displayUserData() {
        FirebaseDownstream.shared.getCurrentUser {[unowned self] (dictionnary) in
            if let dictionnary = dictionnary {
                print(dictionnary)
                let username_str = dictionnary["username"] as? String ?? ""
                let description_str = dictionnary["description"] as? String ?? ""
                let image_string = dictionnary["image_string"] as? String ?? ""
                let fullname = dictionnary["fullname"] as? String ?? ""
                
//                self.userName.text = username_str
//                self.descriptionText.text = description_str
                
//                SAMPLE description text
                //self.descriptionText.text = description
                self.fullNameLabel.text = fullname
                
//        setting username to title
//                self.navBarItem.title = self.userName.text
                
                if let followers = dictionnary["followers"] as? [String:Any]{
                    if let people = followers["people"] as? [String:[String:Any]]{
                        let count = people.count
                        
                        self.followerLabel.text = "Followers: \(count)"
                    }
                }
                
                if let followers = dictionnary["following"] as? [String:Any]{
                    if let people = followers["people"] as? [String:[String:Any]]{
                        let count = people.count
                        
                        self.followingLabel.text = "Followers: \(count)"
                    }
                }
                
                self.userImage.sd_setImage(with: URL(string: image_string), placeholderImage: UIImage(named: "empty_event"))
                
            }

        }
        
        let interests = AuthApi.getInterests()?.components(separatedBy: ",")
        
        for view in interestStackView.arrangedSubviews{
            interestStackView.removeArrangedSubview(view)
        }
        
        for (index, interest) in (interests?.enumerated())!{
            let textLabel = UILabel()
            
            textLabel.textColor = .white
            textLabel.text  = interest
            textLabel.textAlignment = .left
            
            
            if index == 0{
                textLabel.text = "● " + textLabel.text!
                
                let primaryFocus = NSMutableAttributedString(string: textLabel.text!)
                primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:0, length:1))
                textLabel.attributedText = primaryFocus
            }
            
            if interest.characters.count > 0{
                interestStackView.addArrangedSubview(textLabel)
                interestStackView.translatesAutoresizingMaskIntoConstraints = false;
            }
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
        self.descriptionText.frame = newFrame;


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
            if value != nil
            {
                self.pinAddress1Label.text = value?["formattedAddress"] as? String
                self.pinAddress2Label.text = value?["pin"] as? String
                if (value?["like"] as? NSDictionary) != nil{
                self.pinLikesLabel.text = String((value?["like"] as? NSDictionary)?["num"] as! Int)
                }
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil
                    {
                        self.pinLabel.text = value?["username"] as? String
                    }
                })
                
                
            }
        })
        
    }

    @IBAction func updatePin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "Home") as? PinScreenViewController
        self.present(VC!, animated: true, completion: nil)
    }
    
    func getEventSuggestions(){
        
        let center = AuthApi.getLocation()
        if let circleQuery = self.geoFire?.query(at: center, withRadius: 20.0) {
            _ = circleQuery.observe(.keyEntered) { (key, location) in
                print("Key '\(key)' entered the search area and is at location '\(location)'")
                
                Constants.DB.event.child(key!).observeSingleEvent(of: .value, with: {snapshot in
                    let info = snapshot.value as? [String : Any] ?? [:]
                    
                    let event = Event(title: (info["title"])! as! String, description: (info["description"])! as! String, fullAddress: (info["fullAddress"])! as! String, shortAddress: (info["shortAddress"])! as! String, latitude: (info["latitude"])! as! String, longitude: (info["longitude"])! as! String, date: (info["date"])! as! String, creator: (info["creator"])! as! String, id: snapshot.key, category: info["interests"] as? String)
                    
                    if let attending = info["attendingList"] as? [String:Any]{
                        event.setAttendessCount(count: attending.count)
                    }
                    
                  self.suggestion.append(event)

                    var rows = self.suggestion.count / 3
                    if self.suggestion.count % 3 != 0{
                        rows += 1
                    }
//                    self.suggestionsHeight.constant = CGFloat(125 * rows)
                self.eventsCollectionView.reloadData()
                })
            }
            
            circleQuery.observeReady{
                print("All initial data has been loaded and events have been fired for circle query!")
            }
        }
        
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
        
        self.morePinButton.layer.borderWidth = 1
        self.morePinButton.layer.borderColor = UIColor.white.cgColor
        self.morePinButton.roundCorners(radius: 5.0)
        
        self.moreFocusButton.layer.borderWidth = 1
        self.moreFocusButton.layer.borderColor = UIColor.white.cgColor
        self.moreFocusButton.roundCorners(radius: 5.0)
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
