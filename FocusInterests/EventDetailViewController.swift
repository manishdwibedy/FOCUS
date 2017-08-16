//
//  EventDetailViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
import Firebase
import GeoFire
import ChameleonFramework
import Crashlytics

protocol EventDetailViewControllerDelegate{
    func showPopup()
}

class EventDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, EventDetailViewControllerDelegate{
    @IBOutlet weak var hostNameLabel: UILabel!
    
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var distanceLabelInNavBar: UIButton!
    
    @IBOutlet weak var invitePopupView: UIView!
    @IBOutlet weak var invitePopupTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var globeButton: UIButton!
    @IBOutlet weak var eventInterests: UILabel!
    @IBOutlet weak var eventAmount: UILabel!
    @IBOutlet weak var eventAmountHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBackOut: UIBarButtonItem!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var addCommentView: UIView!
    
    @IBOutlet weak var moreCommentsButton: UIButton!
    @IBOutlet weak var postCommentsButton: UIButton!
    @IBOutlet weak var moreOtherLikesButton: UIButton!
    @IBOutlet weak var guestButtonOut: UIButton!
    
//    MARK: Event Details View
    @IBOutlet weak var timeAmountAddressStack: UIStackView!
    @IBOutlet weak var eventDetailsView: UIView!
    
//    MARK: ATTEND TOP VIEW PROPERTIES
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var pinHereButton: UIButton!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventName: UILabel!
    
//    MARK: Comments Stack
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsStack: UIStackView!
    @IBOutlet weak var noCommentLabel: UILabel!
    @IBOutlet weak var commentsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var moreCommentsView: UIView!
    @IBOutlet weak var commentsTextViewContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var youMayAlsoLikeView: UIView!
    var invitePeopleEventDelegate: InvitePeopleEventCellDelegate?
    var event: Event?
    var showInvitePopup = false
    
    let ref = Database.database().reference()
    let commentsCList = NSMutableArray()
    
    var keyboardUp = false
    var attendingAmount = 0
    var isAttending = false
    var suggestions = [Event]()
    let geoFire = GeoFire(firebaseRef: Database.database().reference().child("event_locations"))
    var guestList = [String:[String:String]]()
    var map: MapViewController? = nil
    
    var commentDF = DateFormatter()
    var eventDateDF = DateFormatter()
    let screenSize = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    var delegate: showMarkerDelegate?
    var ticketMasterDF = DateFormatter()
    var eventDF = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.globeButton.setImage(UIImage(named: "Globe_White"), for: .normal)

        self.commentsTableView.delegate = self
        self.commentsTableView.dataSource = self
        self.commentsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.commentsTableView.estimatedRowHeight = 100
        self.commentsTableView.rowHeight = UITableViewAutomaticDimension
        
        self.eventsTableView.delegate = self
        self.eventsTableView.dataSource = self
        self.eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.eventsTableView.estimatedRowHeight = 100
        self.eventsTableView.rowHeight = UITableViewAutomaticDimension
        if event?.price != nil && (event?.price)! > 0.0{
            eventAmount.text = "$ \(String(describing: event!.price!))"
        }else{
            self.timeAmountAddressStack.removeArrangedSubview(self.eventAmount)
            self.eventAmount.isHidden = true
            self.eventDetailsView.bounds.size.height -= self.eventAmount.frame.size.height
        }
        
        let commentsNib = UINib(nibName: "commentCell", bundle: nil)
        commentsTableView.register(commentsNib, forCellReuseIdentifier: "cell")
        
        let eventsNib = UINib(nibName: "OtherLikesTableViewCell", bundle: nil)
        eventsTableView.register(eventsNib, forCellReuseIdentifier: "otherLikesEventCell")
        
        self.setupViewsAndButton()
        
        self.screenWidth = self.screenSize.width
        self.screenHeight = self.screenSize.height
        
        self.invitePopupView.center.y = self.screenHeight - 20
        self.invitePopupTopConstraint.constant = self.screenHeight - 20
        // Reference to an image file in Firebase Storage
        //        self.navigationItem.title = self.event?.title
        
        self.commentTextView.delegate = self
        self.commentTextView.layer.borderWidth = 1
        self.commentTextView.layer.cornerRadius = 5
        self.commentTextView.clipsToBounds = true
        self.commentTextView.layer.borderColor = UIColor.white.cgColor
        
        let placeholderAttributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!
        ]
        let placeholderTextAttributes: NSAttributedString = NSAttributedString(string: "Add a comment", attributes: placeholderAttributes)
        self.commentTextView.attributedText = placeholderTextAttributes
        
        self.eventImage.layer.borderWidth = 1
        self.eventImage.layer.borderColor = Constants.color.pink.cgColor
        self.eventImage.roundedImage()
        
        self.invitePopupView.layer.cornerRadius = 10.0
        self.inviteButton.roundCorners(radius: 5.0)
        
        self.pinHereButton.roundCorners(radius: 5.0)
        self.pinHereButton.setTitle("I\'m Here", for: .normal)
        self.pinHereButton.setTitleColor(UIColor.white, for: .normal)
        self.pinHereButton.setTitle("I\'m Here!", for: .selected)
        self.pinHereButton.setTitleColor(UIColor.white, for: .selected)
        
        self.attendButton.roundCorners(radius: 5.0)
        self.attendButton.setTitle("Attend", for: .normal)
        self.attendButton.setTitleColor(UIColor.white, for: .normal)
        self.attendButton.setTitle("Attending", for: .selected)
        self.attendButton.setTitleColor(UIColor.white, for: .selected)
        self.checkIfAttending()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
        navTitle.title = event?.title
        
        ticketMasterDF.dateFormat = "yyyy-MM-dd HH:mm:ss"
        eventDF.dateFormat = "MMM d, hh:mm a"
        
        
        if let date = self.ticketMasterDF.date(from: (event?.date!)!){
            timeLabel.text = eventDF.string(from: date)
        }
        else{
            timeLabel.text = event?.date!
        }
        
        addressLabel.text = event?.fullAddress?.replacingOccurrences(of: ";;", with: ", ")
    
        guard let eventDescription = event?.eventDescription else {
            return
        }
        
        let newEventDescription = eventDescription.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression, range: nil)
        
        self.descriptionTextView.textContainer.maximumNumberOfLines = 0
        self.descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        self.descriptionTextView.text = newEventDescription
        self.descriptionTextView.textContainerInset = .zero
        self.descriptionTextView.textContainer.lineFragmentPadding = 0
        
        eventDateDF.dateFormat = "MMM d, hh:mm a"
        if (event?.creator?.characters.count)! > 0{
            let reference = Constants.storage.event.child("\(event!.id!).jpg")
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
                        self.eventImage.image = crop(image: image!, width: 50, height: 50)
                    }
                })
            })
        }
        else{
            if let url = URL(string: (event?.image_url!)!){
                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                    (receivedSize :Int, ExpectedSize :Int) in
                    
                }, completed: {
                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                    
                    if image != nil && finished{
                        self.eventImage.image = crop(image: image!, width: 50, height: 50)
                    }
                })
            }
            
        }
        
        
        if event?.id != nil{
            let fullRef = ref.child("events").child((event?.id)!).child("comments")
            
            if (event?.creator?.characters.count)! > 0{
                ref.child("users").child(event!.creator!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil{
                        
                        
                    }
                    
                })
            }
            
            
            fullRef.queryOrdered(byChild: "date").queryLimited(toFirst: 3).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    for (key,_) in value!
                    {
                        let dict = value?[key] as! NSDictionary
                        let data = commentCellData(from: dict["fromUID"] as! String, comment: dict["comment"] as! String, commentFirePath: fullRef.child(String(describing: key)), likeCount: (dict["like"] as! NSDictionary)["num"] as! Int, date: Date(timeIntervalSince1970: TimeInterval(dict["date"] as! Double)))
                        self.commentsCList.add(data)
                    }
                    
                    self.commentsStack.removeArrangedSubview(self.noCommentLabel)
                    self.noCommentLabel.isHidden = true
                }else{
                    
                    self.noCommentLabel.isHidden = false
                    self.commentsStack.addArrangedSubview(self.noCommentLabel)
                    self.commentsStack.addArrangedSubview(self.addCommentView)
                    self.commentsStack.removeArrangedSubview(self.moreCommentsView)
                    self.commentsStack.removeArrangedSubview(self.commentsTableView)
                    self.moreCommentsButton.isHidden = true
                    
                }
                
                self.commentsTableView.reloadData()
                if self.commentsCList.count != 0{
                    let oldLastCellIndexPath = NSIndexPath(row: self.commentsCList.count-1, section: 0)
                    self.commentsTableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)
                }
                
            })
            
            //check for likes
//            ref.child("events").child((event?.id)!).child("likeAmount").observeSingleEvent(of: .value, with: { (snapshot) in
//                let value = snapshot.value as? NSDictionary
//                if value != nil
//                {
//                    self.likeCount.text = String(value?["num"] as! Int)
//                }
//            })
            
            ref.child("events").child((event?.id)!).child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
//                    self.likeOut.setTitleColor(UIColor.red, for: UIControlState.normal)
//                    self.likeOut.isEnabled = false
                }
                
            })
            
            // attending amount
            ref.child("events").child((event?.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    self.attendingAmount = value?["amount"] as! Int
                    let text = String(self.attendingAmount) + " attendees"
                    
                    let attributeText = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.white])
                    self.guestButtonOut.setAttributedTitle(attributeText, for: UIControlState.normal)
                    
                }
                else{
                    let attributeText = NSAttributedString(string: "0 attendees", attributes: [NSForegroundColorAttributeName : UIColor.white])
                    
                    self.guestButtonOut.setAttributedTitle(attributeText, for: UIControlState.normal)
                }
            })
            
            
            //attending
            ref.child("events").child((event?.id)!).child("attendingList").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:[String:String]]
                if value != nil
                {
                    self.guestList = value!
                    
                    for (_, guest) in self.guestList{
                        print(guest)
                        if guest["UID"] == AuthApi.getFirebaseUid()!{
                            self.attendButton.isSelected = true
                            self.isAttending = true
                            
                            self.attendButton.layer.borderWidth = 1
                            self.attendButton.layer.borderColor = UIColor.white.cgColor
                            self.attendButton.backgroundColor = UIColor(red: 25/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
                        }
                    }
                    
                }
                
            })
            
            addGreenDot(label: self.eventInterests, content: (event?.category)!)
            
            getEventSuggestions()
            
            commentDF.dateFormat = "MMM d, h:mm a"
//            self.attendOut.titleLabel?.textAlignment = .left
        }
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.view.backgroundColor = Constants.color.navy
        self.navBar.barTintColor = Constants.color.navy
        self.navBar.titleTextAttributes = attrs
        
        let titlelabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        titlelabel.text = self.event?.title
        titlelabel.textColor = UIColor.white
        titlelabel.font = UIFont(name: "Avenir-Black", size: 18.0)
        titlelabel.backgroundColor = UIColor.clear
        titlelabel.baselineAdjustment = .alignCenters
        titlelabel.adjustsFontSizeToFitWidth = false
        titlelabel.textAlignment = .center
        self.navBar.topItem?.titleView = titlelabel
        
        let eventLocation = CLLocation(latitude: Double((event?.latitude!)!)!, longitude: Double((event?.longitude!)!)!)
    
        self.distanceLabelInNavBar.setTitle(getDistance(fromLocation: AuthApi.getLocation()!, toLocation: eventLocation,addBracket: false, precision: 1), for: .normal)
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.youMayAlsoLikeView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showInvitePopup {
            //            self.view.bringSubview(toFront: self.invitePopupView)
            UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.invitePopupView.center.y -= self.invitePopupView.frame.size.height
                self.invitePopupTopConstraint.constant -= self.invitePopupView.frame.size.height
            }, completion: { animate in
                UIView.animate(withDuration: 2.5, delay: 3.0, options: .curveEaseInOut, animations: {
                    self.invitePopupView.center.y += self.invitePopupView.frame.size.height
                    self.invitePopupTopConstraint.constant += self.invitePopupView.frame.size.height
                }, completion: { onCompletion in
//                    self.invitePopupView.isHidden = true
                    //                    self.scrollView.sendSubview(toBack: self.invitePopupView)
                })
            })
            self.showInvitePopup = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func inviteEvent(_ sender: UIButton) {
        
        if let date = eventDateDF.date(from: (event?.date)!){
            if date < Date(){
                showError(message: "Event is over")
                return
            }
            
        }
        else if let date = ticketMasterDF.date(from: (event?.date)!){
            if date < Date(){
                showError(message: "Event is over")
                return
            }
        }
        let ivc = UIStoryboard(name: "Invites", bundle: nil).instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "event"
        ivc.id = (event?.id!)!
        ivc.event = event
        ivc.inviteFromEventDetails = true
        ivc.eventDetailsDelegate = self
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    @IBAction func attendEvent(_ sender: UIButton) {
        
        if let date = eventDateDF.date(from: (event?.date)!){
            if date < Date(){
                showError(message: "Event is over")
                return
            }

        }
        else if let date = ticketMasterDF.date(from: (event?.date)!){
            if date < Date(){
                showError(message: "Event is over")
                return
            }
        }
        
        if sender.isSelected == false{
            self.isAttending = true
            
            let newAmount = attendingAmount + 1
            attendingAmount = newAmount
            
            let fullRef = ref.child("events").child((event?.id)!)
            let entry = ["UID":AuthApi.getFirebaseUid()!]
            let newEntry = fullRef.child("attendingList").childByAutoId()
            newEntry.updateChildValues(entry)
            fullRef.child("attendingAmount").updateChildValues(["amount":newAmount])
            
            self.guestList[newEntry.key] = entry
            
            let guestText = "\(newAmount) attendees"
            let attributeText = NSAttributedString(string: guestText, attributes: [NSForegroundColorAttributeName : UIColor.white])
            self.guestButtonOut.setAttributedTitle(attributeText, for: UIControlState.normal)
            
            sendNotification(to: event!.creator!, title: "New Attendee", body: "\(AuthApi.getUserName()!)", actionType: "", type: "", item_id: "", item_name: "")
            
            sender.isSelected = true
            sender.layer.borderWidth = 1
            sender.layer.borderColor = UIColor.white.cgColor
            sender.backgroundColor = UIColor(red: 25/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
            sender.tintColor = UIColor.clear
        }else if sender.isSelected == true{
            
            let alertController = UIAlertController(title: "Unattend \(event!.title!)?", message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Unattend", style: .destructive) { action in
                
                Constants.DB.event.child((self.event?.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil
                    {
                        for (key,_) in value!
                        {
                            self.ref.child("events").child((self.event?.id)!).child("attendingList").child(key as! String).removeValue()
                            self.guestList.removeValue(forKey: key as! String)
                            
                        }
                        
                        let newAmount = self.attendingAmount - 1
                        self.attendingAmount = newAmount
                        let fullRef = self.ref.child("events").child((self.event?.id)!)
                        fullRef.child("attendingAmount").updateChildValues(["amount":newAmount])
                        
                        self.isAttending = false
                        
                        let guestText = "\(newAmount) attendees"
                        let attributeText = NSAttributedString(string: guestText, attributes: [NSForegroundColorAttributeName : UIColor.white])
                        self.guestButtonOut.setAttributedTitle(attributeText, for: UIControlState.normal)
                        
                        sender.isSelected = false
                        sender.layer.borderWidth = 0.0
                        sender.backgroundColor = Constants.color.green
                        sender.tintColor = UIColor.clear
                    }
                    
                })
                
                Answers.logCustomEvent(withName: "Attend Event",
                                       customAttributes: [
                                        "user": AuthApi.getFirebaseUid()!,
                                        "event": self.event?.title,
                                        "attend": false
                    ])
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true)

            
        }
    }
    
    @IBAction func mapEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
        VC?.willShowEvent = true
        VC?.showEvent = self.event
        VC?.location = CLLocation(latitude: Double((event?.latitude)!)!, longitude: Double((event?.longitude)!)!)
        self.present(VC!, animated: true, completion: nil)
    }
    
    @IBAction func postComment(_ sender: Any) {
        let unixDate = NSDate().timeIntervalSince1970
        let fullRef = ref.child("events").child((event?.id)!).child("comments").childByAutoId()
        fullRef.updateChildValues(["fromUID":AuthApi.getFirebaseUid()!, "comment":commentTextView.text!, "like":["num":0], "date": NSNumber(value: Double(unixDate))])
        
        Answers.logCustomEvent(withName: "Event Comment",
                               customAttributes: [
                                "user": AuthApi.getFirebaseUid()!,
                                "comment": commentTextView.text!,
                                
            ])
        
        sendNotification(to: event!.creator!, title: "New Comment", body: "\(AuthApi.getUserName()!)", actionType: "", type: "", item_id: "", item_name: "")
        
        let data = commentCellData(from: AuthApi.getFirebaseUid()!, comment: commentTextView.text!, commentFirePath: fullRef, likeCount: 0, date: Date(timeIntervalSince1970: TimeInterval(unixDate)))
        if self.commentsCList.count != 0{
            self.commentsCList.removeObject(at: 0)
        }
        
        if self.commentsCList.count <= 0{
            self.commentsStack.removeArrangedSubview(self.noCommentLabel)
            self.noCommentLabel.isHidden = true
        }
        
        self.commentsCList.add(self.commentTextView.text)
        
        self.commentTextView.resignFirstResponder()
        self.commentTextView.text = "Add a comment"
        
        let lastIndex = IndexPath(row: self.commentsCList.count-1, section: 0)
        print("og num of rows \(self.commentsTableView.numberOfRows(inSection: 0))")
        self.commentsTableView.insertRows(at: [IndexPath(row: self.commentsCList.count-1, section: 0)], with: .automatic)
        print("og num of rows in table \(self.commentsTableView.numberOfRows(inSection: 0))")
        
        if let commentsCell = self.commentsTableView.cellForRow(at: lastIndex){
            self.commentsTableViewHeight.constant += commentsCell.frame.size.height
            self.mainStack.frame.size.height += commentsCell.frame.size.height
        }
        self.commentsTableView.reloadData()
    }
    
    
    @IBAction func moreComments(_ sender: Any) {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "allComments") as! allCommentsVC
        ivc.parentVC = self
        ivc.parentEvent = event
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            _ = keyboardSize.height
            //self.scrollView.contentOffset.y = ((keyboardHeight)) + self.commentTextField.frame.height + 100
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardUp = true
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            _ = keyboardSize.height
            //self.scrollView.contentOffset.y = (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) + 60
            
            scrollView.setContentOffset(CGPoint(x: 0, y: (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) + 60), animated: true)
        }
        
    }
    func keyboardDidHide(notification: NSNotification) {
        keyboardUp = false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMapViewControllerWithSegue"{
            let map = self.map
            if let event = event{
                if !(map?.events.contains(event))!{
                    map?.events.append(event)
                    
                    let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                    let marker = GMSMarker(position: position)
                    marker.icon = #imageLiteral(resourceName: "Event")
                    marker.title = event.title
                    marker.map = map?.mapView
                    marker.isTappable = true
                    
                    let index = map?.events.count
                    marker.accessibilityLabel = "event_\(index!)"
                    
                    map?.currentLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
                    map?.willShowEvent = true
                    map?.tapEvent(event: event)
                    
                    map?.viewingEvent = event
                    map?.eventPlaceMarker = marker
                    
                    delegate?.showEventMarker(event: self.event!)
                }
                else{
                    let position = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                    let marker = GMSMarker(position: position)
                    marker.icon = #imageLiteral(resourceName: "Event")
                    marker.title = event.title
                    marker.map = map?.mapView
                    marker.isTappable = true
                    
                    map?.currentLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
                    map?.willShowEvent = true
                    map?.tapEvent(event: event)
                    
                    map?.viewingEvent = event
                    map?.eventPlaceMarker = marker
                    
                    delegate?.showEventMarker(event: self.event!)
                }
            }
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int = 0
        if(tableView.tag == 0){
            rowCount = commentsCList.count
        }else if(tableView.tag == 1){
            rowCount = self.suggestions.count
//            rowCount = 3
        }
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tableCell = UITableViewCell()
        
        if(tableView.tag == 0){
            let commentCell = self.commentsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? commentCell
            commentCell?.data = (commentsCList[indexPath.row] as! commentCellData)
            let comment = commentsCList[indexPath.row] as! commentCellData
            commentCell?.commentLabel.text = comment.comment
            commentCell?.dateLabel.text = commentDF.string(from: comment.date)
            
            Constants.DB.user.child(comment.from).observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? [String:Any]{
                    if let username = data["username"] as? String{
                        commentCell?.usernameLabel.text = username
                    }
                    
                    if let image = data["image_string"] as? String{
                        if let url = URL(string: image){
                            commentCell?.userProfilePhoto.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                        }
                    }
                }
                
            })
            
            tableCell = commentCell!
        }
        
        if(tableView.tag == 1){
            
            print("setting up event table view cell")
            let eventCell = self.eventsTableView.dequeueReusableCell(withIdentifier: "otherLikesEventCell", for: indexPath) as? OtherLikesTableViewCell
            
            let suggestion = self.suggestions[indexPath.row]

            let suggestionLocation = CLLocation(latitude: Double((event?.latitude!)!)!, longitude: Double(suggestion.longitude!)!)
            
            eventCell?.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: suggestionLocation,addBracket: false)
            
            if let category = suggestion.category{
                addGreenDot(label: (eventCell?.categoryLabel)!, content: category.components(separatedBy: ",")[0])
            }
            else{
                addGreenDot(label: (eventCell?.categoryLabel)!, content: "N.A.")
            }
            
            
            let reference = Constants.storage.event.child("\(suggestion.id!).jpg")
            
            let placeholderImage = UIImage(named: "empty_event")
            reference.downloadURL(completion: { (url, error) in
                
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
            })
        
            eventCell?.addressLabel.text = suggestion.shortAddress
            eventCell?.dateAndTimeLabel.text = suggestion.date
            eventCell?.locationLabel.text = suggestion.title
            
            tableCell = eventCell!
            
        }

        return tableCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
            let suggestion = self.suggestions[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: false)
            
            let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
            controller.event = suggestion
            self.present(controller, animated: true, completion: nil)
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var rowHeight = CGFloat()
//        if(tableView.tag == 0){
//            rowHeight = UITableViewAutomaticDimension
//        }else if(tableView.tag == 1){
//            rowHeight = 80
//        }
//        return rowHeight
//        
//    }
//    
    
    
    @IBAction func guestButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "attendeeVC") as! attendeeVC
        ivc.parentVC = self
        ivc.parentEvent = event
        ivc.guestList = self.guestList
        self.present(ivc, animated: true, completion: { _ in })
    }
   
    
    @IBAction func goBackToMap(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMapViewControllerWithSegue", sender: self)
    }
    
    
    @IBAction func navBack(_ sender: Any) {
        if keyboardUp == false
        {
            dismiss(animated: true, completion: nil)
        }else
        {
            commentTextView.resignFirstResponder()
            commentTextView.text = ""
        }
    }
    
    func getEventSuggestions(){
        var suggestionCount = 0
//        let center = CLLocation(latitude: Double((event?.latitude)!)!, longitude: Double((event?.latitude)!)!)
        if let circleQuery = self.geoFire?.query(at: AuthApi.getLocation()!, withRadius: 20.0) {
            _ = circleQuery.observe(.keyEntered) { (key, location) in
                    print("Key '\(String(describing: key))' entered the search area and is at location '\(location)'")
                suggestionCount += 1
                
                Constants.DB.event.child(key!).observeSingleEvent(of: .value, with: {snapshot in
                    let info = snapshot.value as? [String : Any] ?? [:]
                    
                    if let event = Event.toEvent(info: info){
                        event.id = key!
                        if let attending = info["attendingList"] as? [String:Any]{
                            event.setAttendessCount(count: attending.count)
                        }
                        
                        if event.id != self.event?.id && !self.suggestions.contains(event){
                            self.suggestions.append(event)
                        }
                        
                        if suggestionCount < 3 && self.suggestions.count == suggestionCount - 1{
                            self.eventsTableView.reloadData()
                        }
                        else if self.suggestions.count == 3{
                            self.eventsTableView.reloadData()
                        }
                    }
                })                
            }
    
            circleQuery.observeReady{
                print("All initial data has been loaded and events have been fired for circle query!")
                self.moreOtherLikesButton.isHidden = true
            }
        }
        
    }
    
    func setupViewsAndButton(){
        
        moreCommentsButton.layer.borderWidth = 1
        postCommentsButton.layer.borderWidth = 1
        moreOtherLikesButton.layer.borderWidth = 1
        
        moreCommentsButton.layer.borderColor = UIColor.white.cgColor
        postCommentsButton.layer.borderColor = UIColor.white.cgColor
        moreOtherLikesButton.layer.borderColor = UIColor.white.cgColor
        
        moreCommentsButton.roundCorners(radius: 7.0)
        postCommentsButton.roundCorners(radius: 7.0)
        moreOtherLikesButton.roundCorners(radius: 7.0)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.text?.characters.count)! > 0{
            postCommentsButton.setTitleColor(UIColor(hexString: "7ac901"), for: .normal)
            postCommentsButton.isEnabled = true
            var textFrame = textView.frame
            textFrame.size.height = textView.contentSize.height
            textView.frame = textFrame
            self.commentsTextViewContainerHeight.constant = textView.frame.height + (self.commentsTextViewContainerHeight.constant - textView.frame.height)
        }else{
            postCommentsButton.setTitleColor(UIColor.lightGray, for: .normal)
            postCommentsButton.isEnabled = false
        }
    }
    
    @IBAction func showComments(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Comments", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "comments") as! CommentsViewController
        ivc.type = "event"
        ivc.eventComments = commentsCList
        self.present(ivc, animated: true, completion: { _ in })
        
    }
    
    @IBAction func showGoogleMaps(_ sender: Any) {
        let latitude = Double((event?.latitude)!)!
        let longitude = Double((event?.longitude)!)!

        
        let user_location = AuthApi.getLocation()
        let place_location = CLLocation(latitude: latitude, longitude: longitude)
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        
        let distanceInMeters = user_location!.distance(from: place_location)
        
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, distanceInMeters*2, distanceInMeters*2)
        
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event?.title
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    @IBAction func showUber(_ sender: Any) {
        let lat = Double((event?.latitude)!)!
        let long = Double((event?.longitude)!)!
        var address = event?.shortAddress
        
        address = address?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url_string = "uber://?client_id=1Z-d5Wq4PQoVsSJFyMOVdm1nExWzrpqI&action=setPickup&pickup=my_location&dropoff[latitude]=\(lat)&dropoff[longitude]=\(long)&dropoff[nickname]=\(address!)&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d"
        
        //let url  = URL(string: url_string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        let url = URL(string: url_string)
        if UIApplication.shared.canOpenURL(url!) == true
        {
            UIApplication.shared.openURL(url!)
        }
    }
    
    @IBAction func openTicketMaster(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: (event?.url)!)! as URL)

    }
    
    @IBAction func pinButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMapViewControllerFromPersonalUserProfilePlaceDetailsOrEventDetails", sender: self)
    }
    
    func checkIfAttending(){
        if self.attendButton.isSelected == true{
            self.attendButton.layer.borderWidth = 1
            self.attendButton.layer.borderColor = UIColor.white.cgColor
            self.attendButton.backgroundColor = UIColor(red: 25/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
        }else if self.attendButton.isSelected == false {
            self.attendButton.layer.borderWidth = 0.0
            self.attendButton.backgroundColor = Constants.color.green
        }
    }
    
    func pin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "Home") as! PinScreenViewController
        ivc.pinType = .event
        ivc.placeEventID = (event?.id)!
        
        ivc.formmatedAddress = (event?.shortAddress)!
        ivc.coordinates.latitude = Double((event?.latitude)!)!
        ivc.coordinates.longitude = Double((event?.longitude)!)!
        ivc.locationName = (event?.title)!
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    func showPopup(){
        print("have sent invite to this place!")
//        self.invitePopupView.isHidden = false
        self.showInvitePopup = true
        self.pinHereButton.isEnabled = false
    }
}
