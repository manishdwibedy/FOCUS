//
//  InvitePeoplePlaceCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InvitePeoplePlaceCell: UITableViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var followButtonOut: UIButton!
    @IBOutlet weak var inviteButtonOut: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var UID = ""
    var place: Place!
    override func awakeFromNib() {
        super.awakeFromNib()
        inviteButtonOut.layer.cornerRadius = 6
        inviteButtonOut.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    @IBAction func invite(_ sender: Any) {
        let time = NSDate().timeIntervalSince1970
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? [String : Any] ?? [:]
            
            let fullname = user["fullname"] as? String
            sendNotification(to: self.UID, title: "\(String(describing: fullname)) invited you to \(String(describing: self.place?.name))", body: "")
        })
        Constants.DB.places.child(place.id).child("invitations").childByAutoId().updateChildValues(["toUID":place.id, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
        Constants.DB.user.child(UID).child("invitations").child("place").childByAutoId().updateChildValues(["ID":place.id, "time":time,"fromUID":AuthApi.getFirebaseUid()!])
    }
    
    
}
