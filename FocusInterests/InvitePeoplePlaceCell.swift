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
    @IBOutlet weak var inviteCellContentView: UIView!
    
    var UID = ""
    var place: Place!
    var parentVC: InvitePeopleViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        inviteButtonOut.layer.cornerRadius = 6
        inviteButtonOut.clipsToBounds = true
        
        self.placeImage.roundedImage()
        self.placeImage.layer.borderWidth = 2
        self.placeImage.layer.borderColor = UIColor(red: 72/255.0, green: 255/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        self.inviteCellContentView.allCornersRounded(radius: 6.0)
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
        parentVC.dismiss(animated: true, completion: nil)
    }
    
    
}
