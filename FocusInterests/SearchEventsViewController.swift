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

class SearchEventsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
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
        
        let nib = UINib(nibName: "SearchEventTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.register(UINib(nibName: "NotificationFeedCellTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifFeedCell")
        
        tableView.register(UINib(nibName: "FeedOneTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedOneCell")
        
        tableView.register(UINib(nibName: "FeedEventTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTwoCell")
        
        tableView.register(UINib(nibName: "FeedPlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedThreeCell")
        
        tableView.register(UINib(nibName: "FeedCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedFourCell")
        
        tableView.register(UINib(nibName: "FeedPlaceImageTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedFiveCell")
        
        tableView.register(UINib(nibName: "FeedCreatedEventTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedSixCell")
        
        tableView.register(UINib(nibName: "notificationTabCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifTabCell")
        
//        MARK: Navigation Bar
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        
//        MARK: Invite Popup View
        self.invitePopupView.allCornersRounded(radius: 10)
        
        filtered = events
        
        hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.location = AuthApi.getLocation()
        tableView.reloadData()
        
//        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations/event").queryOrdered(byChild: "status").queryEqual(toValue: "accepted").observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            
//            
//            if let placeData = value{
//                let count = placeData.count
//                for (_,place) in placeData
//                {
//                    let id = (place as? [String:Any])?["ID"]
//                    
//                    Constants.DB.event.child(id as! String).observeSingleEvent(of: .value, with: { (snapshot) in
//                        if let info = snapshot.value as? [String : Any], info.count > 0{
//                            let event = Event.toEvent(info: info)
//                            event?.id = id as! String
//                            
//                            let eventLocation = CLLocation(latitude: Double((info["longitude"])! as! String)!, longitude: Double((info["longitude"])! as! String)!)
//                            
//                            event?.distance = eventLocation.distance(from: AuthApi.getLocation()!)
//                            if let attending = info["attendingList"] as? [String:Any]{
//                                event?.setAttendessCount(count: attending.count)
//                            }
//                            
//                            
//                            self.attending.append(event!)
//                            if self.attending.count == count{
//                                
//                                for event in self.attending{
//                                    if let index = self.all_events.index(where: { $0.id == event.id }) {
//                                        self.all_events.remove(at: index)
//                                    }
//                                }
//                                
//                                self.attending.sort {
//                                    return $0.distance < $1.distance
//                                }
//                                
//                                self.events = self.attending + self.all_events
//                                
//                                self.filtered = self.events
//                                self.tableView.reloadData()
//                            }
//                            
//                        }
//            
//
//                    })
//                }
//            }
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logCustomEvent(withName: "Screen",
                               customAttributes: [
                                "Name": "Search Event"
            ])
        
//        if showInvitePopup {
//            self.invitePopupView.isHidden = false
//            UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
//                self.invitePopupView.center.y -= 129
//                self.invitePopupViewBottomConstraint.constant += 129
//            }, completion: { animate in
//                UIView.animate(withDuration: 2.5, delay: 3.0, options: .curveEaseInOut, animations: {
//                    self.invitePopupView.center.y += 129
//                    self.invitePopupViewBottomConstraint.constant -= 129
//                }, completion: nil)
//            })
//            self.showInvitePopup = false
//        }
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
        //2 and 6
        
        let feed = self.feeds[indexPath.row]
        
        if feed.type == .Pin && feed.item?.imageURL == nil{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedOneCell", for: indexPath) as? FeedOneTableViewCell{
                let data = feed.item?.data["pin"] as! [String:Any]
    
                    cell.pin = pinData(UID: data["fromUID"] as! String, dateTS: data["time"] as! Double, pin: data["pin"] as! String, location: data["formattedAddress"] as! String, lat: data["lat"] as! Double, lng: data["lng"] as! Double, path: Constants.DB.pins.child(feed.item?.data["key"] as! String), focus: data["focus"] as? String ?? "")
                cell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (cell.pin?.dateTimeStamp)!), numericDates: true, shortVersion: true)
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    cell.nameLabel.text = user.username
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            cell.userImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    addGreenDot(label: cell.interestLabel, content: (pinData["focus"] as? String)!)
                    
                    cell.addressLabel.text = (pinData["formattedAddress"] as? String)?.components(separatedBy: ";;")[0]
                    cell.nameDescriptionLabel.text = pinData["pin"] as? String
                    
                    
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    cell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                }
                return cell
            }
            
        }
        else if feed.type == .Pin && feed.item?.imageURL != nil{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedFiveCell", for: indexPath) as? FeedPlaceImageTableViewCell{
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    cell.usernameLabel.setTitle(user.username, for: .normal)
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            cell.usernameImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    
                    cell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (pinData["time"] as! Double)), numericDates: true, shortVersion: true)
                    
                    addGreenDot(label: cell.interestLabel, content: (pinData["focus"] as? String)!)
                    
                    cell.addressLabel.setTitle((pinData["formattedAddress"] as? String)?.components(separatedBy: ";;")[0], for: .normal)
                    cell.pinCaptionLabel.text = pinData["pin"] as? String

                    
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    cell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                    
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
                        
                        cell.imagePlace.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_pin"))
                        cell.imagePlace.setShowActivityIndicator(true)
                        cell.imagePlace.setIndicatorStyle(.gray)
                    })
                }
                return cell
            }
        }
        else if feed.type == .Created{
            let feedCreatedEventCell = tableView.dequeueReusableCell(withIdentifier: "FeedSixCell", for: indexPath) as! FeedCreatedEventTableViewCell
            feedCreatedEventCell.event = feed.item?.data["event"] as? Event
            feedCreatedEventCell.timeSince.text = DateFormatter().timeSince(from: feed.time!, numericDates: true, shortVersion: true)
            getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                feedCreatedEventCell.usernameLabel.setTitle(user.username, for: .normal)
                if let image = user.image_string{
                    if let url = URL(string: image){
                        feedCreatedEventCell.usernameImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                    }
                }
                
            })
            
            feedCreatedEventCell.actionLabel.text = "created"
            
            feedCreatedEventCell.parentVC = self
            cell = feedCreatedEventCell
        }
        else if feed.type == .Going{
            let feedEventCell = tableView.dequeueReusableCell(withIdentifier: "FeedTwoCell", for: indexPath) as! FeedEventTableViewCell
            feedEventCell.inviteButton.addTarget(self, action: #selector(SearchEventsViewController.goToInvitePage), for: .touchUpInside)
            cell = feedEventCell
        }
        else if feed.type == .Like{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedThreeCell", for: indexPath) as? FeedPlaceTableViewCell{
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    cell.usernameWhoLikedLabel.setTitle(user.username, for: .normal)
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            cell.usernameImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    let user = pinData["fromUID"] as? String
                    
                    cell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (pinData["time"] as! Double)), numericDates: true, shortVersion: true)
                    
                    
                    getUserData(id: user!, gotUser: {user in
                        cell.usernameWhoIsBeingLiked.setTitle("\(user.username!)'s", for: .normal)
                    })
                    
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    cell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                    
                    let caption = pinData["pin"] as! String
                    cell.placeBeingLiked.setTitle("\(caption)", for: .normal)
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
                            
                            cell.placePhoto.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_pin"))
                            cell.placePhoto.setShowActivityIndicator(true)
                            cell.placePhoto.setIndicatorStyle(.gray)
                        })
                    }
                    else{
                        cell.placePhoto.image = #imageLiteral(resourceName: "placeholder_pin")
                    }
                }
                return cell
            }
            
        }
        else if feed.type == .Comment{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedFourCell", for: indexPath) as? FeedCommentTableViewCell{
                getUserData(id: (feed.sender?.uuid)!, gotUser: {user in
                    cell.usernameWhoCommentedLabel.setTitle(user.username, for: .normal)
                    if let image = user.image_string{
                        if let url = URL(string: image){
                            cell.usernameImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                    
                })
                
                if let pinData = feed.item?.data["pin"] as? [String: Any]{
                    let user = pinData["fromUID"] as? String
                    
                    cell.timeSince.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (pinData["time"] as! Double)), numericDates: true, shortVersion: true)
                    
                    
                    getUserData(id: user!, gotUser: {user in
                        cell.usernameReceivingCommentLabel.setTitle("\(user.username!)'s", for: .normal)
                    })
                    
                    let pinLocation = CLLocation(latitude: Double((pinData["lat"] as? Double)!), longitude: Double((pinData["lng"] as? Double)!))
                    cell.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: pinLocation,addBracket: false)
                    
                    let caption = pinData["pin"] as! String
                    cell.eventNameLabel.setTitle("\(caption)", for: .normal)
                    cell.eventNameLabel.setTitleColor(Constants.color.green, for: .normal)
                    cell.commentLabel.text = feed.item?.itemName
                    
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
                            
                            cell.eventImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_pin"))
                            cell.eventImage.setShowActivityIndicator(true)
                            cell.eventImage.setIndicatorStyle(.gray)
                        })
                    }
                    else{
                        cell.eventImage.image = #imageLiteral(resourceName: "placeholder_pin")
                    }
                }
                return cell
            }
        }
        
        
//        if indexPath.row == 0{
//            cell = tableView.dequeueReusableCell(withIdentifier: "FeedOneCell", for: indexPath) as! FeedOneTableViewCell
//        }
//        else if indexPath.row == 1{
//            let feedEventCell = tableView.dequeueReusableCell(withIdentifier: "FeedTwoCell", for: indexPath) as! FeedEventTableViewCell
//            feedEventCell.inviteButton.addTarget(self, action: #selector(SearchEventsViewController.goToInvitePage), for: .touchUpInside)
//            cell = feedEventCell
//        }else if indexPath.row == 2{
//            cell = tableView.dequeueReusableCell(withIdentifier: "FeedThreeCell", for: indexPath) as! FeedPlaceTableViewCell
//        }else if indexPath.row == 3{
//            cell = tableView.dequeueReusableCell(withIdentifier: "FeedFourCell", for: indexPath) as! FeedCommentTableViewCell
//        }
//        else if indexPath.row == 4{
//            cell = tableView.dequeueReusableCell(withIdentifier: "FeedFiveCell", for: indexPath) as! FeedPlaceImageTableViewCell
//        }
//        else if indexPath.row == 5{
//            var feedCreatedEventCell = tableView.dequeueReusableCell(withIdentifier: "FeedSixCell", for: indexPath) as! FeedCreatedEventTableViewCell
//            var searchEventCell = feedCreatedEventCell.searchEventTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SearchEventTableViewCell
//            searchEventCell.inviteButton.addTarget(self, action: #selector(SearchEventsViewController.goToInvitePage), for: .touchUpInside)
//            cell = feedCreatedEventCell
//        }
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
            
        }
        else if feed.type == .Going{
        
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat?
        let feed = self.feeds[indexPath.row]
        
        if feed.type == .Pin && feed.item?.imageURL == nil{
            return 115
        }
        else if feed.type == .Pin && feed.item?.imageURL != nil{
            return 220
        }
        else if feed.type == .Created{
            return 227
        }
        else if feed.type == .Going{
            return 130
        }
        else if feed.type == .Like{
            return 120
        }
        else if feed.type == .Comment{
            return 150
        }
        
//        if indexPath.row == 0{
//            rowHeight = 115
//        }else if indexPath.row == 1{
//            rowHeight = 130
//        }else if indexPath.row == 2{
//            rowHeight = 120
//        }else if indexPath.row == 3{
//            rowHeight = 150
//        }else if indexPath.row == 4{
//            rowHeight = 220
//        }else if indexPath.row == 5{
//            rowHeight = 227
//        }else{
//            rowHeight = 80
//        }
        return 80
    }
    
}
