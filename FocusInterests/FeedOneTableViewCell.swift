//
//  FeedOneTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Crashlytics

class FeedOneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameDescriptionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesAmountLabel: UILabel!
    @IBOutlet weak var timeAmountLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var pin: pinData? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImage.roundedImage()
        self.usernameLabel.text = "username"
        self.addressLabel.text = "1600 Campus Road"
        self.distanceLabel.text = "2 mi"
        addGreenDot(label: self.interestLabel, content: "Sports")
        self.nameDescriptionLabel.text = "Watching NBA Awards - Westbrook for MVP!"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likePin(_ sender: Any) {
        if (self.likeButton.imageView?.image?.isEqual(#imageLiteral(resourceName: "Like")))!
        {
            pin?.dbPath.child("like/num").observeSingleEvent(of: .value, with: {snapshot in
                if let num = snapshot.value as? Int{
                    self.pin?.dbPath.child("like").updateChildValues(["num": num + 1])
                    
                    Answers.logCustomEvent(withName: "Like Pin",
                                           customAttributes: [
                                            "liked": true,
                                            "user": AuthApi.getFirebaseUid()!,
                                            "likeCount": num + 1
                        ])
                }
            })
            pin?.dbPath.child("like").child("likedBy").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
            
            self.likeButton.setImage(#imageLiteral(resourceName: "Liked"), for: UIControlState.normal)
            
            
            
        }
        else{
            pin?.dbPath.child("like/num").observeSingleEvent(of: .value, with: {snapshot in
                if let num = snapshot.value as? Int{
                    self.pin?.dbPath.child("like").updateChildValues(["num": num - 1])
                    
                    Answers.logCustomEvent(withName: "Like Pin",
                                           customAttributes: [
                                            "liked": true,
                                            "user": AuthApi.getFirebaseUid()!,
                                            "likeCount": num -
                                            1
                        ])
                }
            })
            
            pin?.dbPath.child("like").child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                if let value = value
                {
                    for (id, _) in value{
                        self.pin?.dbPath.child("like").child("likedBy").child(id).removeValue()
                    }
                    
                    
                }
            })
            
            
            self.likeButton.setImage(#imageLiteral(resourceName: "Like"), for: UIControlState.normal)
            
            Answers.logCustomEvent(withName: "Like Pin",
                                   customAttributes: [
                                    "liked": false,
                                    "user": AuthApi.getFirebaseUid()!,
                                    "likeCount": self.likes
                ])
        }
    }
}
