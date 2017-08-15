//
//  SearchEventsViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON
import FirebaseDatabase
import Crashlytics

class SearchEventsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate{
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var invitePopupView: UIView!
    @IBOutlet weak var invitePopupViewBottomConstraint: NSLayoutConstraint!
    
    var events = [Event]()
    var filtered = [Event]()
    var location: CLLocation?
    
    var all_events = [Event]()
    var attending = [Event]()
    var feeds = [FocusNotification]()
    var showInvitePopup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.clipsToBounds = true
        
        tableView.register(UINib(nibName: "FeedOneTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedOneCell")
        tableView.register(UINib(nibName: "FeedEventTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTwoCell")
        tableView.register(UINib(nibName: "FeedPlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedThreeCell")
        tableView.register(UINib(nibName: "FeedCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedFourCell")
        tableView.register(UINib(nibName: "FeedPlaceImageTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedFiveCell")
        tableView.register(UINib(nibName: "FeedCreatedEventTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedSixCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150.0
        
//        MARK: Navigation Bar
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        
//        MARK: Invite Popup View
        self.invitePopupView.layer.cornerRadius = 10.0
        
        filtered = events
        
        hideKeyboardWhenTappedAround()
//        tableView.tableFooterView = UIView()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.location = AuthApi.getLocation()
        
        getAllActivity(gotPins: { pins in
            self.feeds.append(contentsOf: pins)
            
            var uniqueFeeds = Array(Set(self.feeds))
            self.feeds = uniqueFeeds.sorted(by: {
                $0.time! >= $1.time!
            })
            self.tableView.reloadData()
        }, gotEvents: { events in
            self.feeds.append(contentsOf: events)
            
            var uniqueFeeds = Array(Set(self.feeds))
            self.feeds = uniqueFeeds.sorted(by: {
                $0.time! >= $1.time!
            })
            
            self.tableView.reloadData()
        }, gotInvitations: { invites in
            self.feeds.append(contentsOf: invites)
            
            var uniqueFeeds = Array(Set(self.feeds))
            self.feeds = uniqueFeeds.sorted(by: {
                $0.time! >= $1.time!
            })
            
            self.tableView.reloadData()
        })
        
        var uniqueFeeds = Array(Set(self.feeds))
        self.feeds = uniqueFeeds.sorted(by: {
            $0.time! >= $1.time!
        })
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logCustomEvent(withName: "Screen",
                               customAttributes: [
                                "Name": "Search Event"
            ])
        
        if showInvitePopup {
            self.invitePopupView.isHidden = false
            UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.invitePopupView.center.y -= 129
                self.invitePopupViewBottomConstraint.constant += 129
            }, completion: { animate in
                UIView.animate(withDuration: 2.5, delay: 3.0, options: .curveEaseInOut, animations: {
                    self.invitePopupView.center.y += 129
                    self.invitePopupViewBottomConstraint.constant -= 129
                }, completion: nil)
            })
            self.showInvitePopup = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
//        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchEventTableViewCell!
        
        let event = filtered[indexPath.row]
        cell?.name.text = event.title
        
        print(event.fullAddress)
        
        var addressComponents = event.fullAddress?.components(separatedBy: ",")
        _ = addressComponents?[0]
        
        addressComponents?.remove(at: 0)
        _ = addressComponents?.joined(separator: ", ")
        
        var fullAddress = ""
        for str in addressComponents!{
            fullAddress = fullAddress + " " + str
        }
        print("full address: \(fullAddress)")
        
        //cell?.address.text = "\(streetAddress!)\n\(city!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))"
        cell?.address.text = event.fullAddress?.replacingOccurrences(of: ";;", with: "\n")
        cell?.address.textContainer.maximumNumberOfLines = 2

        let eventLocation = CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
        cell?.distance.text = getDistance(fromLocation: self.location!, toLocation: eventLocation,addBracket: false)

        cell?.guestCount.text = "\(event.attendeeCount) guests"
        
        if let category = event.category{
            if category.contains(";"){
                addGreenDot(label: (cell?.interest)!, content: category.components(separatedBy: ";")[0])
            }
            else{
                addGreenDot(label: (cell?.interest)!, content: category)
            }
        }
        
        cell?.price.text = "Price"
        
        if self.all_events.index(where: { $0.id == event.id }) != nil {
            cell?.attendButton.layer.borderWidth = 0
            cell?.attendButton.layer.borderColor = UIColor.clear.cgColor
            cell?.attendButton.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
            cell?.attendButton.setTitle("Attend", for: .normal)
        }
        else{
            cell?.attendButton.layer.borderWidth = 1
            cell?.attendButton.layer.borderColor = UIColor.white.cgColor
            cell?.attendButton.backgroundColor = UIColor.clear
            cell?.attendButton.setTitle("Attending", for: .normal)
        }
        _ = UIImage(named: "empty_event")
        
        if let price = event.price{
            if price == 0{
                cell?.price.text = "Free"
            }
            else{
                cell?.price.text = "\(price)"
            }
            
        }
        
        let reference = Constants.storage.event.child("\(event.id!).jpg")
        
        cell?.eventImage.image = crop(image: #imageLiteral(resourceName: "empty_event"), width: 50, height: 50)
        
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
                    cell?.eventImage.image = crop(image: image!, width: 50, height: 50)
                }
            })
            
            
        })
     
        cell?.inviteButton.roundCorners(radius: 5.0)
        cell?.inviteButton.layer.shadowOpacity = 0.5
        cell?.inviteButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell?.inviteButton.layer.masksToBounds = false
        cell?.inviteButton.layer.shadowColor = UIColor.black.cgColor
        cell?.inviteButton.layer.shadowRadius = 5.0
        
        cell?.attendButton.roundCorners(radius: 5.0)
        cell?.attendButton.layer.shadowOpacity = 0.5
        cell?.attendButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell?.attendButton.layer.masksToBounds = false
        cell?.attendButton.layer.shadowColor = UIColor.black.cgColor
        cell?.attendButton.layer.shadowRadius = 5.0
        
        cell?.inviteButton.tag = indexPath.row
        cell?.inviteButton.addTarget(self, action: #selector(self.inviteUser), for: UIControlEvents.touchUpInside)
        cell?.attendButton.addTarget(self, action: #selector(self.attendEvent(sender:)), for: UIControlEvents.touchUpInside)
        
        return cell!
        */
        
        
        /*
         
         FeedOneCell - Pin
         FeedTwoCell - attending event
         FeedThreeCell - liked pin
         FeedFourCell - event comment
         FeedFiveCell - pin with image
         FeedSixCell - event like
         */
        var cell: UITableViewCell?
        
        
        let feed = self.feeds[indexPath.row]
        
        if feed.type == .Pin && feed.item?.imageURL == nil{
            if let feedOneCell = tableView.dequeueReusableCell(withIdentifier: "FeedOneCell", for: indexPath) as? FeedOneTableViewCell{
                let data = feed.item?.data["pin"] as! [String:Any]
    
                feedOneCell.parentVC = self
                feedOneCell.delegate = self.tabBarController?.viewControllers![0] as! MapViewController
                
                feedOneCell.pin = pinData(UID: data["fromUID"] as! String, dateTS: data["time"] as! Double, pin: data["pin"] as! String, location: data["formattedAddress"] as! String, lat: data["lat"] as! Double, lng: data["lng"] as! Double, path: Constants.DB.pins.child(feed.item?.data["key"] as! String), focus: data["focus"] as? String ?? "")
                feedOneCell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (feedOneCell.pin?.dateTimeStamp)!), numericDates: true, shortVersion: true)
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    feedOneCell.nameLabel.text = user.username
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            feedOneCell.userImage.sd_setImage(with: url, for: .normal, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            feedOneCell.userImage.sd_setImage(with: url, for: .selected, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    if let pinFocus = pinData["focus"] as? String{
                        if pinFocus.characters.first == "●"{
                            let startIndex = pinFocus.index(pinFocus.startIndex, offsetBy: 2)
                            let interestStringWithoutDot = pinFocus.substring(from: startIndex)
                            addGreenDot(label: feedOneCell.interestLabel, content: interestStringWithoutDot)
                        }else{
                            addGreenDot(label: feedOneCell.interestLabel, content: pinFocus)
                        }
                    }else{
                        addGreenDot(label: feedOneCell.interestLabel, content: "N.A")
                    }
                    
                    
                    
                    
                    feedOneCell.addressLabel.text = (pinData["formattedAddress"] as? String)?.components(separatedBy: ";;")[0]
                    feedOneCell.nameDescriptionLabel.text = pinData["pin"] as? String
                    
                    
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    feedOneCell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                }
                feedOneCell.mapButton.addTarget(self, action: #selector(SearchEventsViewController.goToMap), for: .touchUpInside)
                feedOneCell.commentTextView.delegate = self
                feedOneCell.commentButton.addTarget(self, action: #selector(SearchEventsViewController.commentPressed(_:)), for: .touchUpInside)
                cell = feedOneCell
            }
            
        }
        else if feed.type == .Pin && feed.item?.imageURL != nil{
            if let feedFiveCell = tableView.dequeueReusableCell(withIdentifier: "FeedFiveCell", for: indexPath) as? FeedPlaceImageTableViewCell{
                
                feedFiveCell.delegate = self.tabBarController?.viewControllers![0] as! MapViewController
                
                let data = feed.item?.data["pin"] as! [String:Any]
                feedFiveCell.pin = data
                feedFiveCell.parentVC = self
                
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    feedFiveCell.usernameLabel.setTitle(user.username, for: .normal)
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            feedFiveCell.usernameImage.sd_setImage(with: url, for: .normal, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            feedFiveCell.usernameImage.sd_setImage(with: url, for: .selected, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    
                    feedFiveCell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (pinData["time"] as! Double)), numericDates: true, shortVersion: true)
                    
                    if let pinFocus = pinData["focus"] as? String{
                        if pinFocus.characters.first == "●"{
                            let startIndex = pinFocus.index(pinFocus.startIndex, offsetBy: 2)
                            let interestStringWithoutDot = pinFocus.substring(from: startIndex)
                            addGreenDot(label: feedFiveCell.interestLabel, content: interestStringWithoutDot)
                        }else{
                            addGreenDot(label: feedFiveCell.interestLabel, content: pinFocus)
                        }
                    }else{
                        addGreenDot(label: feedFiveCell.interestLabel, content: "N.A")
                    }
                    
                    feedFiveCell.commentTextView.delegate = self
                    feedFiveCell.globeButton.addTarget(self, action: #selector(SearchEventsViewController.goToMap), for: .touchUpInside)
                    feedFiveCell.addressLabel.titleLabel?.lineBreakMode = .byTruncatingTail
                    feedFiveCell.addressLabel.setTitle((pinData["formattedAddress"] as? String)?.components(separatedBy: ";;")[0], for: .normal)
                    feedFiveCell.pinCaptionLabel.text = pinData["pin"] as? String
                    feedFiveCell.sizeToFit()
                    feedFiveCell.commentButton.addTarget(self, action: #selector(SearchEventsViewController.commentPressed(_:)), for: .touchUpInside)
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    feedFiveCell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                    
                    var firstVal = ""
                    for (key,_) in (pinData["images"] as! NSDictionary)
                    {
                        firstVal = key as! String
                        break
                    }
                    
                    let reference = Constants.storage.pins.child(((pinData["images"] as! NSDictionary)[firstVal] as! NSDictionary)["imagePath"] as! String)
                    reference.downloadURL(completion: { (url, error) in
                        
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                            return
                        }
                        
                        
                        
                        feedFiveCell.imagePlace.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_pin"))
                        feedFiveCell.imagePlace.setShowActivityIndicator(true)
                        feedFiveCell.imagePlace.setIndicatorStyle(.gray)
                    })
                }
                cell = feedFiveCell
            }
        }
        else if feed.type == .Created{
            let feedCreatedEventCell = tableView.dequeueReusableCell(withIdentifier: "FeedSixCell", for: indexPath) as! FeedCreatedEventTableViewCell
            
            feedCreatedEventCell.delegate = self.tabBarController?.viewControllers![0] as! MapViewController
            
            let event = feed.item?.data["event"] as? Event
            feedCreatedEventCell.event = event
            feedCreatedEventCell.timeSince.text = DateFormatter().timeSince(from: feed.time!, numericDates: true, shortVersion: true)
            
            getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                feedCreatedEventCell.usernameLabel.setTitle(user.username, for: .normal)
                if let image = user.image_string{
                    if let url = URL(string: image){
                        
                        SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                            (receivedSize :Int, ExpectedSize :Int) in
                            
                        }, completed: {
                            (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                            
                            if image != nil && finished{
                                feedCreatedEventCell.usernameImage.setImage(crop(image: image!, width: 50, height: 50), for: .normal)
                            }
                            else{
                                feedCreatedEventCell.usernameImage.setImage(crop(image: #imageLiteral(resourceName: "placeholder_people"), width: 50, height: 50), for: .normal)
                            }
                        })
                        
                    }
                }
            })
            
            feedCreatedEventCell.eventNameLabel.setTitle(event?.title!, for: .normal)
            feedCreatedEventCell.eventNameLabel.setTitleColor(Constants.color.pink, for: .normal)
            feedCreatedEventCell.actionLabel.text = "created"
            feedCreatedEventCell.parentVC = self
            feedCreatedEventCell.globeButton.addTarget(self, action: #selector(SearchEventsViewController.goToMap), for: .touchUpInside)
            
            feedCreatedEventCell.searchEventTableView.reloadData()
            cell = feedCreatedEventCell
        }
        else if feed.type == .Going{
            let feedEventCell = tableView.dequeueReusableCell(withIdentifier: "FeedTwoCell", for: indexPath) as! FeedEventTableViewCell
            
            
            feedEventCell.delegate = self.tabBarController?.viewControllers![0] as! MapViewController
            
            feedEventCell.globeImage.addTarget(self, action: #selector(SearchEventsViewController.goToMap), for: .touchUpInside)
            feedEventCell.inviteButton.addTarget(self, action: #selector(SearchEventsViewController.goToInvitePage), for: .touchUpInside)
            
            feedEventCell.nameLabelButton.setTitle(feed.sender?.username, for: .normal)
            
            if let event = feed.item?.data["event"] as? Event{
                feedEventCell.event = event
                feedEventCell.eventNameLabelButton.setTitle(event.title, for: .normal)
            }
            
            feedEventCell.timeSince.text = DateFormatter().timeSince(from: feed.time!, numericDates: true, shortVersion: true)
            
            Constants.DB.user.child((feed.sender?.uuid)!).observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? [String:Any]{
                    if let image = data["image_string"] as? String{
                        if let url = URL(string: image){
                            SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                                (receivedSize :Int, ExpectedSize :Int) in
                                
                            }, completed: {
                                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                                
                                if image != nil && finished{
                                    feedEventCell.usernameImage.setImage(image, for: .normal)
                                }
                            })
                            
                        }
                    }
                }
            })
            
            let reference = Constants.storage.event.child("\(feed.item!.id).jpg")
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
                        feedEventCell.eventImage.setImage(crop(image: image!, width: 50, height: 50), for: .normal)
                    }
                })
            })
            cell = feedEventCell
        }
        else if feed.type == .Like{
            if let feedPlaceCell = tableView.dequeueReusableCell(withIdentifier: "FeedThreeCell", for: indexPath) as? FeedPlaceTableViewCell{
                let data = feed.item?.data["pin"] as! [String:Any]
                feedPlaceCell.pin = data
                feedPlaceCell.parentVC = self
                feedPlaceCell.feed = feed
                
                feedPlaceCell.delegate = self.tabBarController?.viewControllers![0] as! MapViewController
                
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    feedPlaceCell.usernameWhoLikedLabel.setTitle(user.username, for: .normal)
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            feedPlaceCell.usernameImage.sd_setImage(with: url, for: .normal, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            feedPlaceCell.usernameImage.sd_setImage(with: url, for: .selected, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    let user = pinData["fromUID"] as? String
                    
                    feedPlaceCell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (pinData["time"] as! Double)), numericDates: true, shortVersion: true)
                    
                    
                    getUserData(id: user!, gotUser: {user in
                        feedPlaceCell.usernameWhoIsBeingLiked.setTitle("\(user.username!)'s", for: .normal)
                    })
                    
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    feedPlaceCell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                    
                    let caption = pinData["pin"] as! String
                    
                    
                    let mainString = "Pin: \"\(caption)\""
                    let captionString = "\"\(caption)\""
                    
                    let range = (mainString as NSString).range(of: captionString)
                    
                    let pinAttributeText = NSMutableAttributedString.init(string: mainString)
                    
                    pinAttributeText.addAttributes([
                        NSForegroundColorAttributeName: Constants.color.green,
                        NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!
                        ], range: range)

                    feedPlaceCell.placeBeingLiked.titleLabel?.numberOfLines = 0
                    feedPlaceCell.placeBeingLiked.setAttributedTitle(pinAttributeText, for: .normal)
                    if let images = pinData["images"] as? NSDictionary{
                        var firstVal = ""
                        for (key,_) in images
                        {
                            firstVal = key as! String
                            break
                        }
                        
                        let reference = Constants.storage.pins.child((images[firstVal] as! NSDictionary)["imagePath"] as! String)
                        reference.downloadURL(completion: { (url, error) in
                            
                            if error != nil {
                                print(error?.localizedDescription ?? "")
                                return
                            }
                            
                            feedPlaceCell.placePhoto.sd_setImage(with: url, for: .normal, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            feedPlaceCell.placePhoto.sd_setImage(with: url, for: .selected, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            
//                            feedPlaceCell.placePhoto.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_pin"))
//                            feedPlaceCell.placePhoto.setShowActivityIndicator(true)
//                            feedPlaceCell.placePhoto.setIndicatorStyle(.gray)
                        })
                    }
                    else{
                        feedPlaceCell.placePhoto.isEnabled = false
                        feedPlaceCell.placePhoto.isHidden = true
                    }
                }
                cell = feedPlaceCell
            }
            
        }
        else if feed.type == .Comment{
            if let feedFourCell = tableView.dequeueReusableCell(withIdentifier: "FeedFourCell", for: indexPath) as? FeedCommentTableViewCell{
                let data = feed.item?.data["pin"] as! [String:Any]
                feedFourCell.pin = data
                feedFourCell.parentVC = self
                feedFourCell.feed = feed
                
                feedFourCell.delegate = self.tabBarController?.viewControllers![0] as! MapViewController
                
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    feedFourCell.usernameWhoCommentedLabel.setTitle(user.username, for: .normal)
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            feedFourCell.usernameImage.sd_setImage(with: url, for: .normal, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            feedFourCell.usernameImage.sd_setImage(with: url, for: .selected, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    let user = pinData["fromUID"] as? String
                    
                    feedFourCell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (pinData["time"] as! Double)), numericDates: true, shortVersion: true)
                    
                    getUserData(id: user!, gotUser: {user in
                        feedFourCell.usernameReceivingCommentLabel.setTitle("\(user.username!)'s", for: .normal)
                    })
                    
                    feedFourCell.parentVC = self
                    feedFourCell.checkLengthOfLabel()
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    feedFourCell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                    feedFourCell.globeImage.addTarget(self, action: #selector(SearchEventsViewController.goToMap), for: .touchUpInside)
                    let caption = pinData["pin"] as! String
                    
                    feedFourCell.eventNameLabel.setTitle("\(caption)", for: .normal)
                    feedFourCell.eventNameLabel.setTitleColor(Constants.color.green, for: .normal)
                    
                    feedFourCell.commentLabel.text = "\"\((feed.item?.itemName)!)\""
                    
                    if let images = pinData["images"] as? NSDictionary{
                        var firstVal = ""
                        for (key,_) in images
                        {
                            firstVal = key as! String
                            break
                        }
                        
                        let reference = Constants.storage.pins.child((images[firstVal] as! NSDictionary)["imagePath"] as! String)
                        reference.downloadURL(completion: { (url, error) in
                            
                            if error != nil {
                                print(error?.localizedDescription ?? "")
                                return
                            }
                            
                            feedFourCell.eventImage.sd_setImage(with: url, for: .normal, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            feedFourCell.eventImage.sd_setImage(with: url, for: .selected, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                            
                        })
                    }
                    else{
                        feedFourCell.eventImage.isEnabled = false
                        feedFourCell.eventImage.isHidden = true
                    }
                }
                cell = feedFourCell
            }
        }
        return cell!
    }
    
    func goToInvitePage(){
        let inviteVC = UIStoryboard(name: "Invites", bundle: nil).instantiateViewController(withIdentifier: "NewInviteViewController")
        self.present(inviteVC, animated: true, completion: nil)
    }
    
    func getUserData(id: String, gotUser: @escaping (_ user: User) -> Void){
        Constants.DB.user.child(id).observeSingleEvent(of: .value, with: {snapshot in
        
            if let data = snapshot.value as? [String: Any]{
                if let user = User.toUser(info: data){
                    gotUser(user)
                }
            }
        })
    }
//
//    
//    func attendEvent(sender:UIButton){
//        let buttonRow = sender.tag
//        let event = self.filtered[buttonRow]
//        
//        if sender.title(for: .normal) == "Attend"{
//            print("attending event \(String(describing: event.title)) ")
//            
//            Constants.DB.event.child((event.id)!).child("attendingList").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
//            
//            
//            Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                if value != nil
//                {
//                    let attendingAmount = value?["amount"] as! Int
//                    Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount + 1])
//                }
//            })
//            
//            Answers.logCustomEvent(withName: "Attend Event",
//                                   customAttributes: [
//                                    "user": AuthApi.getFirebaseUid()!,
//                                    "event": event.title,
//                                    "attend": true
//                ])
//            
//            sender.layer.borderWidth = 1
//            sender.layer.borderColor = UIColor.white.cgColor
//            sender.backgroundColor = UIColor.clear
//            sender.setTitle("Attending", for: .normal)
//        }
//        else{
//            
//            let alertController = UIAlertController(title: "Unattend \(event.title!)?", message: nil, preferredStyle: .actionSheet)
//            
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            alertController.addAction(cancelAction)
//            
//            let OKAction = UIAlertAction(title: "Unattend", style: .destructive) { action in
//                Constants.DB.event.child((event.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let value = snapshot.value as? [String:Any]{
//                        
//                        for (id,_) in value{
//                            Constants.DB.event.child("\(event.id!)/attendingList/\(id)").removeValue()
//                        }
//                    }
//                    
//                    
//                })
//                
//                Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
//                    let value = snapshot.value as? NSDictionary
//                    if value != nil
//                    {
//                        let attendingAmount = value?["amount"] as! Int
//                        Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount - 1])
//                    }
//                })
//                
//                sender.layer.borderWidth = 0
//                sender.layer.borderColor = UIColor.clear.cgColor
//                sender.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
//                sender.setTitle("Attend", for: .normal)
//                
//                Answers.logCustomEvent(withName: "Attend Event",
//                                       customAttributes: [
//                                        "user": AuthApi.getFirebaseUid()!,
//                                        "event": event.title,
//                                        "attend": false
//                    ])
//            }
//            alertController.addAction(OKAction)
//            
//            self.present(alertController, animated: true)
//            
//            
//        }
//        
//    }
//    
//    func inviteUser(sender:UIButton){
//        let buttonRow = sender.tag
//        
//        let event = self.filtered[buttonRow]
//        print("invite user to event \(String(describing: event.title)) ")
//        
//        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
//        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
//        ivc.type = "event"
//        ivc.searchEvent = self
//        ivc.id = event.id!
//        ivc.event = event
//        self.present(ivc, animated: true, completion: { _ in })
//        
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = self.feeds[indexPath.row]
        if feed.type == .Pin && feed.item?.imageURL == nil{
            let storyboard = UIStoryboard(name: "Pin", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
            
            let data = feed.item?.data["pin"] as! [String:Any]
            
            ivc.data = pinData(UID: data["fromUID"] as! String, dateTS: data["time"] as! Double, pin: data["pin"] as! String, location: data["formattedAddress"] as! String, lat: data["lat"] as! Double, lng: data["lng"] as! Double, path: Constants.DB.pins.child(feed.item?.data["key"] as! String), focus: data["focus"] as? String ?? "")
            self.present(ivc, animated: true, completion: { _ in })
        }
        else if feed.type == .Pin && feed.item?.imageURL != nil{
            let storyboard = UIStoryboard(name: "Pin", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
            
            let data = feed.item?.data["pin"] as! [String:Any]
            
            ivc.data = pinData(UID: data["fromUID"] as! String, dateTS: data["time"] as! Double, pin: data["pin"] as! String, location: data["formattedAddress"] as! String, lat: data["lat"] as! Double, lng: data["lng"] as! Double, path: Constants.DB.pins.child(feed.item?.data["key"] as! String), focus: data["focus"] as? String ?? "")
            
            self.present(ivc, animated: true, completion: { _ in })
        }
        else if feed.type == .Created{
            let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
            controller.event = feed.item?.data["event"] as! Event
            
            self.present(controller, animated: true, completion: nil)
        }
        else if feed.type == .Going{
            let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
            controller.event = feed.item?.data["event"] as! Event
            
            self.present(controller, animated: true, completion: nil)
        }
        else if feed.type == .Like{
            let storyboard = UIStoryboard(name: "Pin", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
            
            let data = feed.item?.data["pin"] as! [String:Any]
            
            ivc.data = pinData(UID: data["fromUID"] as! String, dateTS: data["time"] as! Double, pin: data["pin"] as! String, location: data["formattedAddress"] as! String, lat: data["lat"] as! Double, lng: data["lng"] as! Double, path: Constants.DB.pins.child(feed.item?.data["key"] as! String), focus: data["focus"] as? String ?? "")
            
            self.present(ivc, animated: true, completion: { _ in })
        }
        else if feed.type == .Comment{
            let storyboard = UIStoryboard(name: "Pin", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
            
            let data = feed.item?.data["pin"] as! [String:Any]
            
            ivc.data = pinData(UID: data["fromUID"] as! String, dateTS: data["time"] as! Double, pin: data["pin"] as! String, location: data["formattedAddress"] as! String, lat: data["lat"] as! Double, lng: data["lng"] as! Double, path: Constants.DB.pins.child(feed.item?.data["key"] as! String), focus: data["focus"] as? String ?? "")
            
            self.present(ivc, animated: true, completion: { _ in })
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        var textFrame = textView.frame
        textFrame.size.height = textView.contentSize.height
        textView.frame = textFrame
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add a comment"{
            textView.text = ""
        }
    }
    
    func commentPressed(_ sender: Any) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func goToMap() {
        self.performSegue(withIdentifier: "unwindToMapViewControllerWithSegue", sender: self)
    }
    
    func goToUserProfile(_ sender: Any) {
//        let VC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UserProfileViewController
//        self.present(VC, animated:true, completion:nil)
    }
    
    func goToPlaceDetail(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
//        controller.place = place
//        self.present(controller, animated: true, completion: nil)
    }
    
    func goToEventDetail(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
//        controller.event = suggestion
//        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func unwindBackToSearchEventViewController(sender: UIStoryboardSegue){
        self.showInvitePopup = true
    }
}
