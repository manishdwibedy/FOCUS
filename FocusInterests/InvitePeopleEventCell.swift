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
    
    @IBOutlet weak var distance: UILabel!
    
    var event: Event!
    var UID: String!
    var username = ""
    var invitePeopleVCDelegate: InvitePeopleViewControllerDelegate!
    var isMeetup = false
    var inviteFromOtherUserProfile = false
    var parentVC: InvitePeopleViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        self.attendButton.setTitleColor(UIColor.white, for: .selected)
        
        self.eventImage.layer.borderWidth = 2
        self.eventImage.layer.borderColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 120/255.0, alpha: 1.0).cgColor
        self.eventImage.roundedImage()
        self.inviteEventCellContentView.allCornersRounded(radius: 6.0)
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
        controller.map = parentVC.tabBarController?.viewControllers?[0] as? MapViewController
        parentVC.present(controller, animated: true, completion: nil)
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
            self.parentVC.otherUserProfileDelegate?.hasSentUserAnInvite()
            self.parentVC.dismiss(animated: true, completion: nil)
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
        
        if let event = self.event{
            if attendButton.title(for: .normal) == "Attend"{
                
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
                
                attendButton.layer.borderWidth = 1
                attendButton.layer.borderColor = UIColor.white.cgColor
                attendButton.backgroundColor = UIColor.clear
                attendButton.setTitle("Attending", for: .normal)
            }
            else{
                
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
                    self.attendButton.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
                    self.attendButton.setTitle("Attend", for: .normal)
                    
                    Answers.logCustomEvent(withName: "Attend Event",
                                           customAttributes: [
                                            "user": AuthApi.getFirebaseUid()!,
                                            "event": event.title,
                                            "attend": false
                        ])
                }
                alertController.addAction(OKAction)
                
                parentVC.present(alertController, animated: true)
                
            }

        }
        
        /*
        self.attendButton.isSelected = !self.attendButton.isSelected
        if self.attendButton.isSelected == true{
            self.attendButton.layer.borderWidth = 1
            self.attendButton.layer.borderColor = UIColor.white.cgColor
            self.attendButton.backgroundColor = UIColor.clear
        }else if self.attendButton.isSelected == false {
            self.attendButton.layer.borderWidth = 0.0
            self.attendButton.backgroundColor = Constants.color.navy
            self.attendButton.layer.shadowOpacity = 0.5
            self.attendButton.layer.masksToBounds = false
            self.attendButton.layer.shadowColor = UIColor.black.cgColor
            self.attendButton.layer.shadowRadius = 5.0
        }*/
    }
    
    func haveSentInviteFromEventDetail(eventDetailVC: EventDetailViewController){
        eventDetailVC.showPopup()
    }
    
    func haveInvitedSomeoneToAnEvent() {
        print("in invitePeopleEventCell")
        self.invitePeopleVCDelegate.showPopupView()
    }
}
