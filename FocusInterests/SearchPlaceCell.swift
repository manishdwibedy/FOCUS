//
//  SearchPlaceCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SearchPlaceCell: UITableViewCell {

    @IBOutlet weak var placeCellView: UIView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var followButtonOut: UIButton!
    @IBOutlet weak var inviteButtonOut: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var placeID = String()
    var parentVC: SearchPlacesViewController! = nil
    var searchVC: SearchViewController? = nil
    var place: Place?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        followButtonOut.layer.cornerRadius = 6
        followButtonOut.clipsToBounds = true
        inviteButtonOut.layer.cornerRadius = 6
        inviteButtonOut.clipsToBounds = true
        
        self.followButtonOut.roundCorners(radius: 10)
        self.followButtonOut.layer.shadowOpacity = 1.0
        self.followButtonOut.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.followButtonOut.layer.masksToBounds = false
        self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
        self.followButtonOut.layer.shadowRadius = 10.0
        self.followButtonOut.setTitle("Following", for: UIControlState.selected)
        self.followButtonOut.setTitle("Follow", for: UIControlState.normal)
        
        self.inviteButtonOut.roundCorners(radius: 10)
        self.inviteButtonOut.layer.shadowOpacity = 1.0
        self.inviteButtonOut.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.inviteButtonOut.layer.masksToBounds = false
        self.inviteButtonOut.layer.shadowColor = UIColor.black.cgColor
        self.inviteButtonOut.layer.shadowRadius = 10.0
        
        
        placeImage.layer.borderWidth = 1
        placeImage.layer.borderColor = UIColor(red: 72/255.0, green: 255/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        placeImage.roundedImage()
        placeCellView.allCornersRounded(radius: 6.0)
    }
    
    func checkForFollow(id:String)
    {
        print(id)
        Constants.DB.following_place.child(id).child("followers").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                
                self.followButtonOut.layer.borderColor = UIColor.white.cgColor
                self.followButtonOut.layer.borderWidth = 1
                self.followButtonOut.backgroundColor = UIColor.clear
//                self.followButtonOut.setTitle("Following", for: UIControlState.normal)
//                self.followButtonOut.isEnabled = false
                self.followButtonOut.isSelected = true
                
            }else
            {
                self.followButtonOut.layer.borderColor = UIColor.clear.cgColor
                self.followButtonOut.layer.borderWidth = 0
                self.followButtonOut.backgroundColor = UIColor(red: 31/225, green: 50/255, blue: 73/255, alpha: 1)
//                self.followButtonOut.setTitle("Follow", for: UIControlState.normal)
                self.followButtonOut.isSelected = false
                
            }
        })    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followButton(_ sender: Any) {
//         let time = NSDate().timeIntervalSince1970
//        Constants.DB.following_place.child(placeID).child("followers").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":Double(time)])
//        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("places").childByAutoId().updateChildValues(["placeID":placeID, "time":time])
//        Constants.DB.places.child(placeID).child("followers").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":Double(time)])
        
        if self.followButtonOut.state == .normal{
            self.followButtonOut.layer.borderColor = UIColor.white.cgColor
            self.followButtonOut.layer.borderWidth = 1
            self.followButtonOut.backgroundColor = UIColor.clear
//            self.followButtonOut.setTitle("Following", for: UIControlState.normal)
//            self.followButtonOut.isEnabled = false
            self.followButtonOut.isSelected = true
        }else if self.followButtonOut.state == .selected{
            self.followButtonOut.layer.borderColor = UIColor.clear.cgColor
            self.followButtonOut.layer.borderWidth = 0
            self.followButtonOut.backgroundColor = UIColor(red: 31/225, green: 50/255, blue: 73/255, alpha: 1)
            self.followButtonOut.isSelected = false
            
//            self.followButton.setTitle("Follow", for: UIControlState.normal)
        }
        
    }
   
    @IBAction func inviteButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.parentCell = self
        ivc.id = self.placeID
        ivc.place = place
        if let VC = self.parentVC{
            VC.present(ivc, animated: true, completion: { _ in })
        }
        else{
            self.searchVC?.present(ivc, animated: true, completion: { _ in })
        }
        
    }
    
    
}
