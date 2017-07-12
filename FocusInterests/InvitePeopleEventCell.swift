//
//  InvitePeopleEventCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var distance: UILabel!
    var event: Event!
    var UID: String!
    var username = ""
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
        let shortbackgroundMask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.inviteEventCellContentView.layer.mask = mask
    }
    
    func tap(sender: UITapGestureRecognizer)
    {
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
        controller.event = event as! Event
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
    
    func haveInvitedSomeoneToAnEvent() {
        self.parentVC.dismiss(animated: true, completion: { inviteEvent in
            self.parentVC.searchPeopleDelegate?.haveInvitedSomeoneToAPlaceOrAnEvent()
        })
    }
}
