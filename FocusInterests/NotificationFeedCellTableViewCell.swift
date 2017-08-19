//
//  NotificationFeedCellTableViewCell.swift
//  FocusInterests
//
//  Created by Nicolas on 01/06/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

//Alex Jang Todo List
//TODO: Tell Arya that we need a Blue Circle Icon for Location Pic
//TODO: Need to figure out how to readjust size of "See You There" Button

import UIKit
import SDWebImage
import Crashlytics

class NotificationFeedCellTableViewCell: UITableViewCell {

    @IBOutlet weak var nextTimeButton: UIButton!
    @IBOutlet weak var seeYouThereButton: UIButton!
    @IBOutlet weak var timeOfNotificationLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var userProfilePic: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentBackView: UIView!
   
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nextTimeHeight: NSLayoutConstraint!
    
    @IBOutlet weak var seeYouHeight: NSLayoutConstraint!
    let time = DateFormatter()
    let date = DateFormatter()
    var isFeed = false
    var type = ""
    var selectedButton = false
    var notif: FocusNotification!
    var parentVC: NotificationFeedViewController!
    var userInfo = [String:Any]()
    
    var nofArray = [FocusNotification]()
    var invArray = [FocusNotification]()
    var feedAray = [FocusNotification]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTaped))
        self.addGestureRecognizer(tap)
        
        time.dateFormat = "h:mm a"
        date.dateFormat = "MM/dd/yy"
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(notif: FocusNotification) {
        self.roundButtonsAndPictures()
        
        if isFeed{
            nextTimeHeight.constant = 0
        }
        else{
            nextTimeHeight.constant = 24
        }
        if isFeed{
            seeYouHeight.constant = 0
        }
        else{
            seeYouHeight.constant = 24
        }
//        self.userProfilePic.image = notif.sender?.username
        _ = (notif.sender?.username)! + " "//! + " " + (notif.type?.rawValue)! + " " + (notif.item?.itemName!)!
        
        if !isFeed{
            if notif.item?.type == "place"{
                let placeID = notif.item?.id
                
                getYelpByID(ID: placeID!, completion: { place in
                    let url = URL(string: place.image_url)
                    _ = UIImage(named: "empty_event")
                    
                    
                    SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                        (receivedSize :Int, ExpectedSize :Int) in
                        
                    }, completed: {
                        (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                        
                        if image != nil && finished{
                            self.locationImage.image = image
                        }
                    })
                })
            }
            else if notif.item?.type == "event"{
                let eventID = notif.item?.id
                
                if let image = notif.item?.data["image"] as? String{
                    if let url = URL(string: image){
                        self.locationImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_event"))
                    }
                }
                else{
                    let reference = Constants.storage.event.child("\(eventID!).jpg")
                    print(reference.fullPath)
                    let placeholderImage = UIImage(named: "empty_event")
                    
                    self.locationImage.image = placeholderImage
                    reference.downloadURL(completion: { (url, error) in
                        
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                            return
                        }
                        
                        self.locationImage.sd_setImage(with: url, placeholderImage: placeholderImage)
                        self.locationImage.setShowActivityIndicator(true)
                        self.locationImage.setIndicatorStyle(.gray)
                        
                    })
                }
                

            }
        }
        
        Constants.DB.user.child((notif.sender?.uuid)!).observeSingleEvent(of: .value, with: {snapshot in
            if let info = snapshot.value as? [String:Any]{
                self.userInfo = info
                if let image_string = info["image_string"]{
                    SDWebImageManager.shared().downloadImage(with: URL(string: image_string as! String), options: .continueInBackground, progress: {
                        (receivedSize :Int, ExpectedSize :Int) in
                        
                    }, completed: {
                        (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                        
                        if image != nil && finished{
                            self.userProfilePic.setImage(image, for: .normal)
                        }
                    })
                }
            }
            
            
        })
        
        if let type = notif.item?.type, type.characters.count > 0{
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations").child(type).queryOrdered(byChild: "ID").queryEqual(toValue: notif.item?.id).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                
                if let value = value{
                    for (id, _) in value{
                        let info = value[id] as? [String:Any]
                        if let status = info?["status"] as? String{
                            let invite_time = info?["inviteTime"] as? String
                            
                            if let data = self.notif.item?.data{
                                if invite_time == data["inviteTime"] as? String{
                                    if status == "accepted"{
                                        self.nextTimeButton.isHidden = true
                                        self.nextTimeButton.isEnabled = false
                                        self.statusLabel.text = "Accepted"
                                        self.seeYouThereButton.setTitle("Message", for: .normal)
                                    }
                                    else if status == "declined"{
                                        self.nextTimeButton.isHidden = true
                                        self.nextTimeButton.isEnabled = false
                                        self.statusLabel.text = "Declined"
                                        self.seeYouThereButton.setTitle("Undo", for: .normal)
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                }
            })
        }
        
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: (notif.sender?.username)! + " ")
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 122/255, green: 201/255, blue: 1/255, alpha: 1), range: NSMakeRange(0,  (notif.sender?.username?.characters.count)!))
        
        let descString: NSMutableAttributedString = NSMutableAttributedString(string: (notif.type?.rawValue)! + " ")
        descString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, (notif.type?.rawValue.characters.count)!))
        
        attrString.append(descString);
        if isFeed{
            if notif.type == .Pin || notif.type == .Comment || notif.type == .Like{
                let pin_name = notif.item?.itemName!
                let descString2: NSMutableAttributedString = NSMutableAttributedString(string: pin_name!)
                descString2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1), range: NSMakeRange(0, (pin_name?.characters.count)!))
                
                if let image_string = notif.item?.imageURL{
                    SDWebImageManager.shared().downloadImage(with: URL(string: image_string)!, options: .continueInBackground, progress: {
                        (receivedSize :Int, ExpectedSize :Int) in
                        
                    }, completed: {
                        (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                        
                        if image != nil && finished{
                            self.locationImage.image = image
                        }
                    })
                }
                
                attrString.append(descString2);
            }
            else{
                let descString2: NSMutableAttributedString = NSMutableAttributedString(string: (notif.item?.itemName!)!)
                descString2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1), range: NSMakeRange(0, (notif.item?.itemName?.characters.count)!))
                
                attrString.append(descString2);
            }
            
        }
        else{
            if let name = notif.item?.itemName{
                let descString2: NSMutableAttributedString = NSMutableAttributedString(string: name)
                descString2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1), range: NSMakeRange(0, name.characters.count))
                attrString.append(descString2);
            }
            
        }
        
        if let data = notif.item?.data{
            if let time = data["inviteTime"] as? String{
                let time_string = " at \(time)"
                let descString2: NSMutableAttributedString = NSMutableAttributedString(string: time_string)
                descString2.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, time_string.characters.count))
                attrString.append(descString2);
            }
            
        }
        
        if !isFeed{
            let notif_time = notif.time!
            let plain_time = "\(time.string(from: notif_time)) \(date.string(from: notif_time))"
            self.timeLabel.text = plain_time
        }
        
        
        self.userNameLabel.attributedText = attrString

        
        
        self.notif = notif
        
    }
    
    
    @IBAction func showUser(_ sender: Any) {
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UserProfileViewController
        
        VC.otherUser = true
        VC.userID = (self.notif?.sender?.uuid)!
        VC.previous = .notification
        dropfromTop(view: (parentVC?.view)!)
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
    
    func roundButtonsAndPictures(){
        self.seeYouThereButton.layer.cornerRadius = 6
        self.nextTimeButton.layer.cornerRadius = 6
        
        self.userProfilePic.layer.borderWidth = 2
        self.locationImage.layer.borderWidth = 2
        
        self.userProfilePic.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.locationImage.layer.borderColor = UIColor.cyan.cgColor
        
        self.userProfilePic.imageView?.roundedImage()
        self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.width/2
        self.userProfilePic.clipsToBounds = true
        self.locationImage.roundedImage()
    }
    
//    TODO: Does not disable NextTime button
    @IBAction func seeYouTherePushed(_ sender: Any) {
        
        if seeYouThereButton.titleLabel?.text == "See You There"{
            selectedButton = true
            nextTimeButton.isHidden = true
            nextTimeButton.isEnabled = false
         
            statusLabel.text = "Accepted"
            seeYouThereButton.setTitle("Message", for: .normal)
            
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations").child((notif.item?.type)!).queryOrdered(byChild: "ID").queryEqual(toValue: notif.item?.id).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? [String:Any]
                    
                    if let value = value{
                        for (id, invite) in value{
                            
                            if let inviteData = invite as? [String:Any]{
                                let host = inviteData["fromUID"] as? String
                                let invite_time = inviteData["inviteTime"] as? String
                                
                                if invite_time == self.notif.item?.data["inviteTime"] as? String{
                                    Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations").child((self.notif.item?.type)!).child(id).updateChildValues(["status": "accepted"])
                                    
                                    let accepted = Constants.DB.user.child(host!).child("send_invites").child((self.notif.item?.type)!).childByAutoId()
                                    accepted.updateChildValues(["time": NSDate().timeIntervalSince1970, "user": AuthApi.getFirebaseUid()!, "type": self.notif.item?.type, "id": self.notif.item?.id, "name": self.notif.item?.itemName])
                                }
                                
                                Answers.logCustomEvent(withName: "Accept Invite",
                                                       customAttributes: [
                                                        "type": self.notif.item?.type,
                                                        "user": AuthApi.getFirebaseUid()!,
                                                        "name": self.notif.item?.itemName,
                                                        "host": inviteData["fromUID"] as? String
                                    ])
                            }
                        }
                    }
                
                
            })
            
        }
        else if seeYouThereButton.titleLabel?.text == "Message"{
            let storyboard = UIStoryboard(name: "Messages", bundle: nil)
            let root = storyboard.instantiateViewController(withIdentifier: "otherUserProfileNavigation") as! UINavigationController

            let VC = storyboard.instantiateViewController(withIdentifier: "chat") as? ChatViewController
            VC?.user = self.userInfo
            VC?.inviteUser = true
            VC?.nofArray = self.nofArray
            VC?.invArray = self.invArray
            VC?.feedAray = self.feedAray
            
            root.pushViewController(VC!, animated: true)
            
            self.parentVC.present(root, animated: true, completion: nil)
        }
        else if seeYouThereButton.titleLabel?.text == "Undo"{
            statusLabel.text = ""
            seeYouThereButton.setTitle("See You There", for: .normal)
            nextTimeButton.setTitle("Next Time", for: .normal)
            nextTimeButton.isHidden = false
            nextTimeButton.isEnabled = true
            
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations").child((notif.item?.type)!).queryOrdered(byChild: "ID").queryEqual(toValue: notif.item?.id).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                
                if let value = value{
                    for (id, invite) in value{
                        if let inviteData = invite as? [String:Any]{
                            let host = inviteData["fromUID"] as? String
                            let invite_time = inviteData["inviteTime"] as? String
                            
                            if invite_time == self.notif.item?.data["inviteTime"] as? String{
                                Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations").child((self.notif.item?.type)!).child(id).updateChildValues(["status": "unknown"])
                            }
                        }
                    }
                }
                
                
            })
        }
    }
    
    
//    TODO: error that occurs is below
//    Terminating app due to uncaught exception 'InvalidPathValidation', reason: '(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
    @IBAction func nextTimePushed(_ sender: Any) {
        selectedButton = true
        nextTimeButton.isEnabled = false
        nextTimeButton.isHidden = true
        
        seeYouThereButton.setTitle("Undo", for: .normal)
        statusLabel.text = "Declined"
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations").child((notif.item?.type)!).queryOrdered(byChild: "ID").queryEqual(toValue: notif.item?.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:Any]
            
            if let value = value{
                for (id, invite) in value{
                    if let inviteData = invite as? [String:Any]{
                        let host = inviteData["fromUID"] as? String
                        let invite_time = inviteData["inviteTime"] as? String
                        
                        if invite_time == self.notif.item?.data["inviteTime"] as? String{
                            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("invitations").child((self.notif.item?.type)!).child(id).updateChildValues(["status": "declined"])
                        }
                    }
                }
            }
            
            
        })
    }
    
    @IBAction func profilePicPushed(_ sender: Any) {
        
        //go to profile here
        print("inside pic")
        
    }
    
    

    @IBAction func profilePicOutsideTouch(_ sender: Any) {
         print("outsidepic")
        
        
    }
    
    func screenTaped()
    {
        print("screen taped")
        if notif.item?.type == "event" && notif.item?.id != nil{
            Constants.DB.event.child((notif.item?.id)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let info = snapshot.value as? [String : Any] ?? [:]
                
                if let event = Event.toEvent(info: info){
                    event.id = self.notif.item?.id
                    
                    let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
                    controller.event = event
                    self.parentVC.present(controller, animated: true, completion: nil)
                }
            })
        }else if notif.item?.type == "place" && notif.item?.id != nil{
            
            //    TODO: error that occurs is below
            //    Terminating app due to uncaught exception 'InvalidPathValidation', reason: '(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
            print("getting data")
            print((notif.item?.id)!)
            getYelpByID(ID:(notif.item?.id)!,completion: {Place in
                let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
                controller.place = Place
                self.parentVC.present(controller, animated: true, completion: nil)
                  
            })
        }
    }
}
    
    
    

    
    
    













