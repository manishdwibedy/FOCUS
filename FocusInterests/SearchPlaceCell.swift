//
//  SearchPlaceCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SearchPlaceCell: UITableViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var followButtonOut: UIButton!
    @IBOutlet weak var inviteButtonOut: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var placeID = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        followButtonOut.layer.cornerRadius = 6
        followButtonOut.clipsToBounds = true
        inviteButtonOut.layer.cornerRadius = 6
        inviteButtonOut.clipsToBounds = true
        
       
        
 

    }
    
    func checkForFollow(id:String)
    {
        print(id)
        Constants.DB.following_place.child(id).child("userIDList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                
                self.followButtonOut.layer.borderColor = UIColor.white.cgColor
                self.followButtonOut.layer.borderWidth = 1
                self.followButtonOut.backgroundColor = UIColor.clear
                self.followButtonOut.setTitle("Following", for: UIControlState.normal)
                self.followButtonOut.isEnabled = false
            }else
            {
                self.followButtonOut.layer.borderColor = UIColor.clear.cgColor
                self.followButtonOut.layer.borderWidth = 0
                self.followButtonOut.backgroundColor = UIColor(red: 31/225, green: 50/255, blue: 73/255, alpha: 1)
                self.followButtonOut.setTitle("Follow", for: UIControlState.normal)
                self.followButtonOut.isEnabled = true

            }
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followButton(_ sender: Any) {
        Constants.DB.following_place.child(placeID).child("userIDList").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
        self.followButtonOut.layer.borderColor = UIColor.white.cgColor
        self.followButtonOut.layer.borderWidth = 1
        self.followButtonOut.backgroundColor = UIColor.clear
        self.followButtonOut.setTitle("Following", for: UIControlState.normal)
        self.followButtonOut.isEnabled = false
    }
   
    @IBAction func inviteButton(_ sender: Any) {
    }
    
    
}
