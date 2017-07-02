//
//  EventDetailViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import GeoFire
import ChameleonFramework

class EventDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var eventInterests: UILabel!
    @IBOutlet weak var eventAmount: UILabel!
    @IBOutlet weak var eventAmountHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var likeOut: UIButton!
    @IBOutlet weak var attendOut: UIButton!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBackOut: UIBarButtonItem!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var inviteOut: UIButton!
    @IBOutlet weak var mapOut: UIButton!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var addCommentView: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userInfoEditButton: UIButton!
    @IBOutlet weak var moreCommentsButton: UIButton!
    @IBOutlet weak var postCommentsButton: UIButton!
    @IBOutlet weak var moreOtherLikesButton: UIButton!
    
    
    @IBOutlet weak var guestButtonOut: UIButton!
    @IBOutlet weak var image: UIImageView!
    var event: Event?
    let ref = Database.database().reference()
    let commentsCList = NSMutableArray()
    var keyboardUp = false
    var attendingAmount = 0
    var isAttending = false
    var suggestions = [Event]()
    let geoFire = GeoFire(firebaseRef: Database.database().reference().child("event_locations"))
    var guestList = [String:[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.eventsTableView.delegate = self
        self.eventsTableView.dataSource = self
        self.eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        if event?.price != nil && (event?.price)! > 0.0{
            eventAmount.text = "$ \(String(describing: event?.price))"
        }
        else{
            eventAmountHeight.constant = 0
        }
        
        attendOut.layer.cornerRadius = 6
        attendOut.clipsToBounds = true
        
        inviteOut.layer.cornerRadius = 6
        inviteOut.clipsToBounds = true
        
        mapOut.layer.cornerRadius = 6
        mapOut.clipsToBounds = true
        
        
        let commentsNib = UINib(nibName: "commentCell", bundle: nil)
        commentsTableView.register(commentsNib, forCellReuseIdentifier: "cell")
        
        let eventsNib = UINib(nibName: "OtherLikesTableViewCell", bundle: nil)
        eventsTableView.register(eventsNib, forCellReuseIdentifier: "otherLikesEventCell")
        
        self.setupViewsAndButton()
        
        // Reference to an image file in Firebase Storage
        
        self.navigationItem.title = self.event?.title
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        if let id = event?.id{
            let reference = Constants.storage.event.child("\(id).jpg")
            
            
            reference.downloadURL(completion: { (url, error) in
                
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                self.image.sd_setImage(with: url, placeholderImage: placeholderImage)
                self.image.setShowActivityIndicator(true)
                self.image.setIndicatorStyle(.gray)
                
            })

        }
        else{
            self.image.sd_setImage(with: URL(string:(event?.image_url)!), placeholderImage: placeholderImage)
            self.image.setShowActivityIndicator(true)
            self.image.setIndicatorStyle(.gray)
            
        }
        
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        commentTextField.layer.borderWidth = 1
        commentTextField.layer.cornerRadius = 5
        commentTextField.clipsToBounds = true
        commentTextField.layer.borderColor = UIColor.white.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
        navTitle.title = event?.title
        eventNameLabel.text = event?.title
        timeLabel.text = event?.date
        addressLabel.text = event?.fullAddress?.replacingOccurrences(of: ";;", with: ", ")
        descriptionLabel.text = event?.eventDescription
        
        
//        TODO:THERE IS A BUG THAT RETURNS NIL BEFORE VIEW LOADS
        
        ref.child("users").child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                let placeString = "Add comment"
                self.hostNameLabel.text = value?["username"] as? String
                self.fullnameLabel.text = value?["fullname"] as? String
                var placeHolder = NSMutableAttributedString()
                placeHolder = NSMutableAttributedString(string:placeString, attributes: [NSFontAttributeName:UIFont(name: "Avenir Book", size: 15.0)!])
                placeHolder.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 255, green: 255, blue: 255, alpha: 0.8), range:NSRange(location:0,length:placeString.characters.count))
                self.commentTextField.attributedPlaceholder = placeHolder
                
            }
            
        })
        
        if event?.id != nil{
            let fullRef = ref.child("events").child((event?.id)!).child("comments")
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
                }
                
                self.commentsTableView.reloadData()
                if self.commentsCList.count != 0
                {
                    let oldLastCellIndexPath = NSIndexPath(row: self.commentsCList.count-1, section: 0)
                    self.commentsTableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)
                }
                
            })
            
            //check for likes
            ref.child("events").child((event?.id)!).child("likeAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    self.likeCount.text = String(value?["num"] as! Int)
                }
            })
            
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
                    let text = String(self.attendingAmount) + " guests"
                    
                    
                    let textRange = NSMakeRange(0, text.characters.count)
                    let attributedText = NSMutableAttributedString(string: text)
                    attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
                    self.guestButtonOut.setAttributedTitle(attributedText, for: UIControlState.normal)
                    
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
                            self.isAttending = true
                            
                            self.attendOut.layer.cornerRadius = 6
                            self.attendOut.layer.borderWidth = 1
                            self.attendOut.backgroundColor = .clear
                            self.attendOut.layer.borderColor = UIColor.black.cgColor

                            self.attendOut.setTitle("Attending", for: UIControlState.normal)
                        }
                    }
                    
                }
                
            })
            
            
            // interests
            ref.child("events").child((event?.id)!).child("interests").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? String
                if value != nil{
                    self.eventInterests.text = value
                    
                }
                else{
                    self.eventInterests.text = "N.A."
                }
                
            })
            
            
            getEventSuggestions()
            
            self.attendOut.titleLabel?.textAlignment = .left
        }
        
        if event?.creator == AuthApi.getFirebaseUid(){
            
            userInfoEditButton.isHidden = true
        }
        
        self.commentTextField.delegate = self
        
        hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func inviteEvent(_ sender: UIButton) {
        let ivc = UIStoryboard(name: "Invites", bundle: nil).instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "event"
        ivc.id = (event?.id!)!
        ivc.event = event
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    @IBAction func likeEvent(_ sender: UIButton) {
        let fullRef = ref.child("events").child((event?.id)!)
        let newLike = Int(likeCount.text!)! + 1
        fullRef.child("likeAmount").updateChildValues(["num":newLike])
        fullRef.child("likedBy").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
        likeCount.text = String(newLike)
        likeOut.isEnabled = false
        
    }
    
    @IBAction func attendEvent(_ sender: UIButton) {
        if isAttending == false
        {
            self.isAttending = true
            
            let newAmount = attendingAmount + 1
            attendingAmount = newAmount
            
            let fullRef = ref.child("events").child((event?.id)!)
            let entry = ["UID":AuthApi.getFirebaseUid()!]
            let newEntry = fullRef.child("attendingList").childByAutoId()
            newEntry.updateChildValues(entry)
            fullRef.child("attendingAmount").updateChildValues(["amount":newAmount])
            
            self.guestList[newEntry.key] = entry
            
            let guestText = "\(newAmount) guests"
            let textRange = NSMakeRange(0, guestText.characters.count)
            let attributedText = NSMutableAttributedString(string: guestText)
            attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            self.guestButtonOut.setAttributedTitle(attributedText, for: UIControlState.normal)
            
            attendOut.layer.cornerRadius = 6
            attendOut.layer.borderWidth = 1
            attendOut.backgroundColor = .clear
            attendOut.layer.borderColor = UIColor.black.cgColor

            self.attendOut.setTitle("Attending", for: UIControlState.normal)
        }else{
            ref.child("events").child((event?.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
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
                    
                    let guestText = "\(newAmount) guests"
                    let textRange = NSMakeRange(0, guestText.characters.count)
                    let attributedText = NSMutableAttributedString(string: guestText)
                    attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
                    self.guestButtonOut.setAttributedTitle(attributedText, for: UIControlState.normal)
            
                    self.attendOut.backgroundColor = Constants.color.green
                    self.attendOut.setTitle("Attend", for: UIControlState.normal)
                }
                
            })

            
        }
    }
    
    @IBAction func mapEvent(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
        VC?.showEvent = true
        VC?.location = CLLocation(latitude: Double((event?.latitude)!)!, longitude: Double((event?.longitude)!)!)
        self.present(VC!, animated: true, completion: nil)
    }
    
    @IBAction func postComment(_ sender: Any) {
        let unixDate = NSDate().timeIntervalSince1970
        let fullRef = ref.child("events").child((event?.id)!).child("comments").childByAutoId()
        fullRef.updateChildValues(["fromUID":AuthApi.getFirebaseUid()!, "comment":commentTextField.text!, "like":["num":0], "date": NSNumber(value: Double(unixDate))])
        
        let data = commentCellData(from: AuthApi.getFirebaseUid()!, comment: commentTextField.text!, commentFirePath: fullRef, likeCount: 0, date: Date(timeIntervalSince1970: TimeInterval(unixDate)))
        if self.commentsCList.count != 0
        {
            self.commentsCList.removeObject(at: 0)
        }
        self.commentsCList.add(data)
        commentsTableView.reloadData()
        //tableView.beginUpdates()
        //tableView.insertRows(at: [IndexPath(row: commentsCList.count-1, section: 0)], with: .automatic)
        //tableView.endUpdates()
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
        self.scrollView.frame.origin.y = 0
        self.view.frame.origin.y = 0
        let oldLastCellIndexPath = NSIndexPath(row: commentsCList.count-1, section: 0)
        self.commentsTableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)
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
            let keyboardHeight = keyboardSize.height
            //self.scrollView.contentOffset.y = ((keyboardHeight)) + self.commentTextField.frame.height + 100
            
            
            
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardUp = true
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //self.scrollView.contentOffset.y = (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) + 60
            
            scrollView.setContentOffset(CGPoint(x: 0, y: (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) + 60), animated: true)
        }
        
    }
    func keyboardDidHide(notification: NSNotification) {
        keyboardUp = false
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int = 0
        if(tableView.tag == 0){
            rowCount = commentsCList.count
        }else if(tableView.tag == 1){
            print("SUGGESTIONS")
            print(self.suggestions.count)
            print(self.suggestions.count)
//            rowCount = self.suggestions.count
            rowCount = 3
        }
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tableCell = UITableViewCell()
        
        if(tableView.tag == 0){
            let commentCell = self.commentsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? commentCell
            commentCell?.data = (commentsCList[indexPath.row] as! commentCellData)
            commentCell?.commentLabel.text = (commentsCList[indexPath.row] as! commentCellData).comment
//            commentCell?.likeCount.text = String((commentsCList[indexPath.row] as! commentCellData).likeCount)
//            commentCell?.checkForLike()
            
            tableCell = commentCell!
            
        }
        
        if(tableView.tag == 1){
            
            print("setting up event table view cell")
            let eventCell = self.eventsTableView.dequeueReusableCell(withIdentifier: "otherLikesEventCell", for: indexPath) as? OtherLikesTableViewCell
            
//            let suggestion = self.suggestions[indexPath.row]
//            
//            let suggestionLocation = CLLocation(latitude: Double((event?.latitude!)!)!, longitude: Double(suggestion.longitude!)!)
//            
//            eventCell?.distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: suggestionLocation,addBracket: false)
//            
//            if let category = suggestion.category{
//                eventCell?.categoryLabel.text = category.components(separatedBy: ",")[0]
//            }
//            else{
//                addGreenDot(label: (eventCell?.categoryLabel)!, content: "N.A.")
////                eventCell?.categoryLabel.text = "N.A."
//            }
//            
//            let reference = Constants.storage.event.child("\(suggestion.id).jpg")
//            
//            let placeholderImage = UIImage(named: "empty_event")
//            reference.downloadURL(completion: { (url, error) in
//                
//                if error != nil {
//                    print(error?.localizedDescription)
//                    return
//                }
//                
//                eventCell?.userProfileImage.sd_setImage(with: url, placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: nil)
//                
//                
//            })
//            
//
//            eventCell?.addressLabel.text = suggestion.shortAddress
//            eventCell?.dateAndTimeLabel.text = suggestion.date
//            eventCell?.locationLabel.text = suggestion.eventDescription
            
            
            eventCell?.addressLabel.text = "1435 Glendale Ave"
            eventCell?.dateAndTimeLabel.text = "May 5 2015"
            eventCell?.locationLabel.text = "Glendale"
            eventCell?.distanceLabel.text = "31 mi"
            addGreenDot(label: (eventCell?.categoryLabel)!, content: "N.A.")
            
            tableCell = eventCell!
            
        }

        return tableCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight = CGFloat()
        
        if(tableView.tag == 0){
            rowHeight = 85
        }else if(tableView.tag == 1){
            rowHeight = 80
        }
        return rowHeight
        
    }
    
    
    
    @IBAction func guestButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "attendeeVC") as! attendeeVC
        ivc.parentVC = self
        ivc.parentEvent = event
        ivc.guestList = self.guestList
        self.present(ivc, animated: true, completion: { _ in })
    }
   
    
    
    
    @IBAction func navBack(_ sender: Any) {
        if keyboardUp == false
        {
            dismiss(animated: true, completion: nil)
        }else
        {
            commentTextField.resignFirstResponder()
            commentTextField.text = ""
        }
    }
    
    func getEventSuggestions(){
        let center = CLLocation(latitude: Double((event?.latitude)!)!, longitude: Double((event?.latitude)!)!)
        if let circleQuery = self.geoFire?.query(at: center, withRadius: 20.0) {
            _ = circleQuery.observe(.keyEntered) { (key, location) in
                    print("Key '\(key)' entered the search area and is at location '\(location)'")
                
                Constants.DB.event.child(key!).observeSingleEvent(of: .value, with: {snapshot in
                    let info = snapshot.value as? [String : Any] ?? [:]
                    
                        let event = Event(title: (info["title"])! as! String, description: (info["description"])! as! String, fullAddress: (info["fullAddress"])! as! String, shortAddress: (info["shortAddress"])! as! String, latitude: (info["latitude"])! as! String, longitude: (info["longitude"])! as! String, date: (info["date"])! as! String, creator: (info["creator"])! as! String, id: snapshot.key, category: info["interests"] as? String)
                    
                        if let attending = info["attendingList"] as? [String:Any]{
                            event.setAttendessCount(count: attending.count)
                        }
                        
                        if event.id != self.event?.id{
                            self.suggestions.append(event)
                        }
                        
//                    self.eventsTableView.reloadData()
                })
                self.eventsTableView.reloadData()
            }
    
            circleQuery.observeReady{
                print("All initial data has been loaded and events have been fired for circle query!")
            }
        }
        
    }
    
    func setupViewsAndButton(){
        userProfileImage.roundedImage()
        
        attendOut.roundCorners(radius: 7.0)
        inviteOut.roundCorners(radius: 7.0)
        mapOut.roundCorners(radius: 7.0)
        
        userInfoEditButton.layer.borderWidth = 1
        moreCommentsButton.layer.borderWidth = 1
        postCommentsButton.layer.borderWidth = 1
        moreOtherLikesButton.layer.borderWidth = 1
        
        userInfoEditButton.layer.borderColor = UIColor.white.cgColor
        moreCommentsButton.layer.borderColor = UIColor.white.cgColor
        postCommentsButton.layer.borderColor = UIColor.white.cgColor
        moreOtherLikesButton.layer.borderColor = UIColor.white.cgColor
        
        userInfoEditButton.roundCorners(radius: 7.0)
        moreCommentsButton.roundCorners(radius: 7.0)
        postCommentsButton.roundCorners(radius: 7.0)
        moreOtherLikesButton.roundCorners(radius: 7.0)
    }
    
    
    @IBAction func valueChanged(_ sender: UITextField) {
        
        if (sender.text?.characters.count)! > 0{
            postCommentsButton.setTitleColor(UIColor(hexString: "7ac901"), for: .normal)
            postCommentsButton.isEnabled = true
        }
        else{
            postCommentsButton.setTitleColor(UIColor.lightGray, for: .normal)
            postCommentsButton.isEnabled = false
        }
    }
    
    @IBAction func showComments(_ sender: Any) {
        
        
        let storyboard = UIStoryboard(name: "Comments", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "comments") as! CommentsViewController
//        ivc.data = self.commentsCList
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
}



















