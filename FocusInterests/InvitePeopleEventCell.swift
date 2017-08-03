//
//  InvitePeopleEventCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Crashlytics

protocol InvitePeopleEventCellDelegate {
    func haveInvitedSomeoneToAnEvent()
}

class InvitePeopleEventCell: UITableViewCell, InvitePeopleEventCellDelegate{

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var inviteOut: UIButton!
    @IBOutlet weak var inviteEventCellContentView: UIView!
    @IBOutlet weak var attendButton: UIButton!
    
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var event: Event!
    var UID: String!
    var username = ""
    var invitePeopleVCDelegate: InvitePeopleViewControllerDelegate!
    var isMeetup = false
    var inviteFromOtherUserProfile = false
    var parentVC: InvitePeopleViewController!
    var otherUser: OtherUserProfileViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.inviteEventCellContentView.allCornersRounded(radius: 6.0)
        
        self.inviteOut.layer.cornerRadius = 6
        self.inviteOut.clipsToBounds = true
        self.inviteOut.roundCorners(radius: 5)
        self.inviteOut.layer.shadowOpacity = 0.5
        self.inviteOut.layer.masksToBounds = false
        self.inviteOut.layer.shadowColor = UIColor.black.cgColor
        self.inviteOut.layer.shadowRadius = 5.0
        
        self.attendButton.layer.cornerRadius = 6
        self.attendButton.clipsToBounds = true
        self.attendButton.roundCorners(radius: 5)
        self.attendButton.layer.shadowOpacity = 0.5
        self.attendButton.layer.masksToBounds = false
        self.attendButton.layer.shadowColor = UIColor.black.cgColor
        self.attendButton.layer.shadowRadius = 5.0
        self.attendButton.setTitle("Attend", for: .normal)
        self.attendButton.setTitleColor(UIColor.white, for: .normal)
        self.attendButton.setTitle("Attending", for: .selected)
        self.attendButton.setTitleColor(Constants.color.navy, for: .selected)
        
        self.eventImage.layer.borderWidth = 2
        self.eventImage.layer.borderColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 120/255.0, alpha: 1.0).cgColor
        self.eventImage.roundedImage()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        inviteEventCellContentView.addGestureRecognizer(tap)
        
        address.textContainerInset = UIEdgeInsets.zero
        //        let longP = UILongPressGestureRecognizer(target: self, action: #selector(longP(sender:)))
        //        longP.minimumPressDuration = 0.3
        //        self.addGestureRecognizer(longP)
    }
    
    override func layoutSubviews() {
        self.inviteEventCellContentView.setNeedsLayout()
        
        self.inviteEventCellContentView.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: self.inviteEventCellContentView.bounds, cornerRadius: 10)
        
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.inviteEventCellContentView.layer.mask = mask
    }
    
    func tap(sender: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
        controller.event = event as! Event
        controller.invitePeopleEventDelegate = self
        if parentVC != nil{
            controller.map = parentVC.tabBarController?.viewControllers?[0] as? MapViewController    
        }
        
        
        
        if let VC = parentVC{
            VC.present(controller, animated: true, completion: nil)
        }
        else if let VC = otherUser{
            VC.present(controller, animated: true, completion: nil)
        }
        
    }
    
    
    func loadLikes()
    {
        Constants.DB.event.child(event.id!).child("likedAmount").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.guestCount.text = String(value?["num"] as! Int) + " guests"
            }
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func invite(_ sender: Any) {
        print("sending invite")
        if isMeetup {
            self.parentVC.performSegue(withIdentifier: "unwindBackToSearchPeopleViewControllerSegueWithSegue", sender: self.parentVC)
        }else if inviteFromOtherUserProfile{
            let storyboard = UIStoryboard(name: "Invites", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
            ivc.type = "event"
            ivc.id = self.event.id!
            ivc.username = self.username
            ivc.event = event
            ivc.searchPeopleEventDelegate = self
            if let VC = self.otherUser{
                VC.present(ivc, animated: true, completion: nil)
            }
        }else{
            let storyboard = UIStoryboard(name: "Invites", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
            ivc.type = "event"
            ivc.id = self.event.id!
            ivc.username = self.username
            ivc.event = event
            ivc.searchPeopleEventDelegate = self
            if let VC = self.parentVC{
                VC.present(ivc, animated: true, completion: nil)
            }
        }
        
        // avoid inviting the user
//        let time = NSDate().timeIntervalSince1970
//        Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
//            let user = snapshot.value as? [String : Any] ?? [:]
//            
//            let fullname = user["fullname"] as? String
//            sendNotification(to: self.UID, title: "\(String(describing: fullname!)) invited you to \(String(describing: self.event.title!))", body: "", actionType: "invite", type: "event", item_id: "", item_name: "")
//        })
//        Constants.DB.event.child(event.id!).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time),"status": "sent"])
//        Constants.DB.user.child(UID).child("invitations").child("event").childByAutoId().updateChildValues(["ID":event.id!, "time":time,"fromUID":AuthApi.getFirebaseUid()!,"status": "sent"])
//        parentVC.searchPeople?.showInvitePopup = true
//        parentVC.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func attendButtonPressed(_ sender: Any) {
        self.attendButton.isSelected = !self.attendButton.isSelected
        if let event = self.event{
            if self.attendButton.isSelected{
                
                attendButton.layer.borderWidth = 1
                attendButton.layer.borderColor = Constants.color.navy.cgColor
                attendButton.backgroundColor = UIColor.white
                
                Constants.DB.event.child((event.id)!).child("attendingList").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
                
                
                Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil
                    {
                        let attendingAmount = value?["amount"] as! Int
                        Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount + 1])
                    }
                })
                
                Answers.logCustomEvent(withName: "Attend Event",
                                       customAttributes: [
                                        "user": AuthApi.getFirebaseUid()!,
                                        "event": event.title,
                                        "attend": true
                    ])
                
            }else{
                
                let alertController = UIAlertController(title: "Unattend \(event.title!)?", message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: "Unattend", style: .destructive) { action in
                    Constants.DB.event.child((event.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? [String:Any]{
                            
                            for (id,_) in value{
                                Constants.DB.event.child("\(event.id!)/attendingList/\(id)").removeValue()
                            }
                        }
                        
                        
                    })
                    
                    Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        if value != nil
                        {
                            let attendingAmount = value?["amount"] as! Int
                            Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount - 1])
                        }
                    })
                    
                    self.attendButton.layer.borderWidth = 0
                    self.attendButton.layer.borderColor = UIColor.clear.cgColor
                    self.attendButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
                    
                    Answers.logCustomEvent(withName: "Attend Event",
                                           customAttributes: [
                                            "user": AuthApi.getFirebaseUid()!,
                                            "event": event.title,
                                            "attend": false
                        ])
                }
                alertController.addAction(OKAction)
                
                if let VC = parentVC{
                    VC.present(alertController, animated: true, completion: nil)
                }
                else if let VC = otherUser{
                    VC.present(alertController, animated: true, completion: nil)
                }
                
            }

        }
    }
    
    func checkIfAttending(){
        //attending
        Constants.DB.event.child((event?.id)!).child("attendingList").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:[String:String]]
            if let value = value
            {
                for (_, guest) in value{
                    if guest["UID"] == AuthApi.getFirebaseUid()!{
                        self.attendButton.isSelected = true
                        self.attendButton.layer.borderWidth = 1
                        self.attendButton.layer.borderColor = Constants.color.navy.cgColor
                        self.attendButton.backgroundColor = UIColor.white
                        break
                    }
                }
                self.attendButton.isSelected = false
                self.attendButton.layer.borderWidth = 0
                self.attendButton.layer.borderColor = UIColor.clear.cgColor
                self.attendButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
            }
            else{
                self.attendButton.isSelected = false
                self.attendButton.layer.borderWidth = 0
                self.attendButton.layer.borderColor = UIColor.clear.cgColor
                self.attendButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
            }
            
        })
        
        Constants.DB.event.child((event?.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                let text = String(value?["amount"] as! Int) + " attendees"
                
                let attributeText = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.black])
                self.guestCount.attributedText = attributeText
            }
            else{
                let attributeText = NSAttributedString(string: "0 attendees", attributes: [NSForegroundColorAttributeName : UIColor.black])
                
                self.guestCount.attributedText = attributeText
            }
        })
    }
    
    func haveSentInviteFromEventDetail(eventDetailVC: EventDetailViewController){
        eventDetailVC.showPopup()
    }
    
    func haveInvitedSomeoneToAnEvent() {
        print("in invitePeopleEventCell")
        self.invitePeopleVCDelegate.showPopupView()
    }
}
