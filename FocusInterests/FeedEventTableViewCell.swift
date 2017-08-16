//
//  FeedEventTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Crashlytics

class FeedEventTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabelButton: UIButton!
    @IBOutlet weak var nameLabelButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var usernameImage: UIButton!
    @IBOutlet weak var eventNameLabelButton: UIButton!
    
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var eventImage: UIButton!
    @IBOutlet weak var isAttendLabel: UILabel!
    @IBOutlet weak var isAttendingLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var globeImage: UIButton!
    
    var delegate: showMarkerDelegate?
    var event: Event?
    var feedVC: SearchEventsViewController?
    var isAttending = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.nameLabelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.eventNameLabelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.isAttendLabel.adjustsFontSizeToFitWidth = true
//        self.isAttendingLabelWidth.constant = self.isAttendLabel.intrinsicContentSize.width
        
        self.usernameImage.roundButton()
        self.eventImage.roundButton()
        
        self.attendButton.setTitle("Attend", for: .normal)
        self.attendButton.setTitleColor(Constants.color.navy, for: .normal)
        
        self.attendButton.setTitle("Attending", for: .selected)
        self.attendButton.setTitleColor(UIColor.white, for: .selected)
        
        self.attendButton.layer.borderWidth = 1.0
        self.attendButton.layer.borderColor = UIColor.white.cgColor
        self.attendButton.roundCorners(radius: 6.0)
        self.inviteButton.roundCorners(radius: 6.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkIfAttending(){
        Constants.DB.event.child((event?.id)!).child("attendingList").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:[String:String]]
            if let value = value{
                for (_, guest) in value{
                    if guest["UID"] == AuthApi.getFirebaseUid()!{
                        self.attendButton.isSelected = true
                        self.attendButton.layer.borderWidth = 1
                        self.attendButton.layer.borderColor = UIColor.white.cgColor
                        self.attendButton.backgroundColor = Constants.color.navy
                        self.attendButton.tintColor = UIColor.clear
                        self.isAttending = true
                        
                        break
                    }
                }
                
                if !self.isAttending{
                    self.isAttending = false
                    self.attendButton.isSelected = false
                    self.attendButton.layer.borderWidth = 1.0
                    self.attendButton.layer.borderColor = Constants.color.navy.cgColor
                    self.attendButton.backgroundColor = UIColor.white
                    self.attendButton.tintColor = UIColor.clear
                }
            }else{
                self.isAttending = false
                self.attendButton.isSelected = false
                self.attendButton.layer.borderWidth = 1.0
                self.attendButton.layer.borderColor = Constants.color.navy.cgColor
                self.attendButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
                self.attendButton.tintColor = UIColor.clear
            }
            
        })
        
    }
    
    @IBAction func attend(_ sender: Any) {
        if let event = self.event{
            if self.attendButton.isSelected == false{
            attendButton.isSelected = true
            attendButton.layer.borderWidth = 1
            attendButton.layer.borderColor = UIColor.white.cgColor
            attendButton.backgroundColor = Constants.color.navy
            attendButton.tintColor = UIColor.clear
            self.isAttending = true
                
            Constants.DB.event.child((event.id)!).child("attendingList").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
                
                
                Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil
                    {
                        let attendingAmount = value?["amount"] as! Int
                        Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount + 1])
                    }
                    else{
                        Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount": 1])
                    }
                })
                
                Answers.logCustomEvent(withName: "Attend Event",
                                       customAttributes: [
                                        "user": AuthApi.getFirebaseUid()!,
                                        "event": event.title,
                                        "attend": true
                    ])
                
            }else if attendButton.isSelected == true{
                
                let alertController = UIAlertController(title: "Unattend \(event.title!)?", message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
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
                    
                    self.isAttending = false
                    self.attendButton.isSelected = false
                    self.attendButton.layer.borderWidth = 1
                    self.attendButton.layer.borderColor = Constants.color.navy.cgColor
                    self.attendButton.backgroundColor = UIColor.white
                    self.attendButton.tintColor = UIColor.clear
                    
                    Answers.logCustomEvent(withName: "Attend Event",
                                           customAttributes: [
                                            "user": AuthApi.getFirebaseUid()!,
                                            "event": event.title,
                                            "attend": false
                    ])
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(OKAction)
                
                if let VC = feedVC{
                    VC.present(alertController, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    @IBAction func invite(_ sender: Any) {
        let inviteVC = UIStoryboard(name: "Invites", bundle: nil).instantiateViewController(withIdentifier: "NewInviteViewController") as? NewInviteViewController
        inviteVC?.event = event
        feedVC!.present(inviteVC!, animated: true, completion: nil)
    }
    
    @IBAction func goBackToMap(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
        vc.willShowEvent = true
        
        delegate?.showEventMarker(event: event!)
        vc.selectedIndex = 0
    }
    
}
