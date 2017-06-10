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

class EventDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
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
    @IBOutlet weak var descriptionEditButton: UIButton!
    @IBOutlet weak var moreCommentsButton: UIButton!
    @IBOutlet weak var postCommentsButton: UIButton!
    @IBOutlet weak var moreOtherLikesButton: UIButton!
    
    @IBOutlet weak var guestButtonOut: UIButton!
    var event: Event?
    @IBOutlet weak var image: UIImageView!
    
    let ref = Database.database().reference()
    let commentsCList = NSMutableArray()
    var keyboardUp = false
    var attendingAmount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
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
        timeLabel.text = event?.date
        addressLabel.text = event?.fullAddress
        descriptionLabel.text = event?.eventDescription
        
//        TODO:THERE IS A BUG THAT RETURNS NIL BEFORE VIEW LOADS
        
        ref.child("users").child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                let placeString = ("Add comment as " + (value?["username"] as! String))
                var placeHolder = NSMutableAttributedString()
                placeHolder = NSMutableAttributedString(string:placeString, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 15.0)!])
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
                    self.likeOut.setTitleColor(UIColor.red, for: UIControlState.normal)
                    self.likeOut.isEnabled = false
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
            ref.child("events").child((event?.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    self.attendOut.isEnabled = false
                    self.attendOut.setTitle("Attending", for: UIControlState.normal)
                }
                
            })
            self.attendOut.titleLabel?.textAlignment = .left
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func inviteEvent(_ sender: UIButton) {
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
        let newAmount = attendingAmount + 1
        attendingAmount = newAmount
        self.guestButtonOut.setTitle(String(self.attendingAmount)+" guests", for: UIControlState.normal)
        let fullRef = ref.child("events").child((event?.id)!)
        fullRef.child("attendingList").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
        fullRef.child("attendingAmount").updateChildValues(["amount":newAmount])
        self.attendOut.isEnabled = false
        self.attendOut.setTitle("Attending", for: UIControlState.normal)
    }
    
    @IBAction func mapEvent(_ sender: Any) {
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
        navBackOut.title = "Cancel"
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //self.scrollView.contentOffset.y = (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) + 60
            
            scrollView.setContentOffset(CGPoint(x: 0, y: (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) + 60), animated: true)
        }
        
    }
    func keyboardDidHide(notification: NSNotification) {
        keyboardUp = false
        navBackOut.title = "Back"
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
            rowCount = 2
        }
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var tableCell = UITableViewCell()
        
        if(tableView.tag == 0){
            let commentCell = self.commentsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? commentCell
            commentCell?.data = (commentsCList[indexPath.row] as! commentCellData)
            commentCell?.commentLabel.text = (commentsCList[indexPath.row] as! commentCellData).comment
            commentCell?.likeCount.text = String((commentsCList[indexPath.row] as! commentCellData).likeCount)
            commentCell?.checkForLike()
            
            tableCell = commentCell!
            
        }else if(tableView.tag == 1){
            let eventCell = self.eventsTableView.dequeueReusableCell(withIdentifier: "otherLikesEventCell", for: indexPath) as? OtherLikesTableViewCell
            eventCell?.distanceLabel.text = "2.1 mi"
            eventCell?.categoryLabel.text = "Summer"
            eventCell?.addressLabel.text = "Pasadena"
            eventCell?.dateAndTimeLabel.text = "August"
            eventCell?.locationLabel.text = "Los Angeles"
            
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
            rowHeight = 95
        }
        return rowHeight
        
    }
    
    
    
    @IBAction func guestButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "attendeeVC") as! attendeeVC
        ivc.parentVC = self
        ivc.parentEvent = event
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
    
    func setupViewsAndButton(){
        userProfileImage.roundedImage()
        
        attendOut.roundCorners(radius: 7.0)
        inviteOut.roundCorners(radius: 7.0)
        mapOut.roundCorners(radius: 7.0)
        
        addCommentView.layer.borderWidth = 1
        userInfoEditButton.layer.borderWidth = 1
        descriptionEditButton.layer.borderWidth = 1
        moreCommentsButton.layer.borderWidth = 1
        postCommentsButton.layer.borderWidth = 1
        moreOtherLikesButton.layer.borderWidth = 1
        
        addCommentView.layer.borderColor = UIColor.white.cgColor
        userInfoEditButton.layer.borderColor = UIColor.white.cgColor
        descriptionEditButton.layer.borderColor = UIColor.white.cgColor
        moreCommentsButton.layer.borderColor = UIColor.white.cgColor
        postCommentsButton.layer.borderColor = UIColor.white.cgColor
        moreOtherLikesButton.layer.borderColor = UIColor.white.cgColor
        
        addCommentView.allCornersRounded(radius: 7.0)
        userInfoEditButton.roundCorners(radius: 7.0)
        descriptionEditButton.roundCorners(radius: 7.0)
        moreCommentsButton.roundCorners(radius: 7.0)
        postCommentsButton.roundCorners(radius: 7.0)
        moreOtherLikesButton.roundCorners(radius: 7.0)
    }
    
}



















