//
//  InvitePeopleEventCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InvitePeopleEventCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var inviteOut: UIButton!
    
    var event: Event!
    var UID: String!
    override func awakeFromNib() {
        super.awakeFromNib()
        inviteOut.layer.cornerRadius = 6
        inviteOut.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func invite(_ sender: Any) {
        let time = NSDate().timeIntervalSince1970
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? [String : Any] ?? [:]
            
            let fullname = user["fullname"] as? String
            sendNotification(to: self.UID, title: "\(String(describing: fullname)) invited you to \(String(describing: self.event.title))", body: "")
        })
        Constants.DB.event.child(event.id!).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
        Constants.DB.user.child(UID).child("invitations").child("event").childByAutoId().updateChildValues(["ID":event.id!, "time":time,"fromUID":AuthApi.getFirebaseUid()!])
    
    }
}
