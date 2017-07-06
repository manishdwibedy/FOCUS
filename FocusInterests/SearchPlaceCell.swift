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
    var parentVC: SearchPlacesViewController? = nil
    var searchVC: SearchViewController? = nil
    var place: Place?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addressTextView.contentInset = UIEdgeInsetsMake(-4,-4,0,0);
        // Initialization code
        
//        Follow button
        
        self.followButtonOut.clipsToBounds = true
        self.followButtonOut.isSelected = false
        self.followButtonOut.roundCorners(radius: 5)
        self.followButtonOut.layer.shadowOpacity = 0.5
        self.followButtonOut.layer.masksToBounds = false
        self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
        self.followButtonOut.layer.shadowRadius = 5.0
        
        self.followButtonOut.setTitleColor(UIColor.white, for: .normal)
        self.followButtonOut.setTitleColor(UIColor.white, for: .selected)

        self.followButtonOut.setTitle("Follow", for: UIControlState.normal)
        self.followButtonOut.setTitle("Unfollow", for: UIControlState.selected)
        
//        invite button
        self.inviteButtonOut.clipsToBounds = true
        self.inviteButtonOut.roundCorners(radius: 5)
        self.inviteButtonOut.layer.shadowOpacity = 0.5
        self.inviteButtonOut.layer.masksToBounds = false
        self.inviteButtonOut.layer.shadowColor = UIColor.black.cgColor
        self.inviteButtonOut.layer.shadowRadius = 5.0

//        image
        placeImage.layer.borderWidth = 1
        placeImage.layer.borderColor = UIColor(red: 72/255.0, green: 255/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        placeImage.roundedImage()
        
//        category label
        self.categoryLabel.textColor = UIColor(red: 119/255.0, green: 197/255.0, blue: 53/255.0, alpha: 1.0)
        
//        cell view
        placeCellView.allCornersRounded(radius: 10.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followButton(_ sender: Any) {
        
        
        if self.followButtonOut.isSelected == false{
            
//            unfollow button appearance
            self.followButtonOut.isSelected = true
            self.followButtonOut.layer.borderWidth = 1
            self.followButtonOut.layer.borderColor = UIColor.white.cgColor
            self.followButtonOut.backgroundColor = UIColor(red: 97/255.0, green: 115/255.0, blue: 129/255.0, alpha: 1.0)
            self.followButtonOut.tintColor = UIColor.clear
            self.followButtonOut.layer.shadowOpacity = 0.5
            self.followButtonOut.layer.masksToBounds = false
            self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
            self.followButtonOut.layer.shadowRadius = 5.0
            
            let time = NSDate().timeIntervalSince1970
            Follow.followPlace(id: (place?.id)!)
            

        } else if self.followButtonOut.isSelected == true {
            
            
            let unfollowAlertController = UIAlertController(title: "Are you sure you want to unfollow \(self.place!.name)?", message: nil, preferredStyle: .actionSheet)
            
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                
//            follow button appearance
                self.followButtonOut.isSelected = false
                self.followButtonOut.layer.borderWidth = 1
                self.followButtonOut.layer.borderColor = UIColor.clear.cgColor
                self.followButtonOut.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
                self.followButtonOut.tintColor = UIColor.clear
                self.followButtonOut.layer.shadowOpacity = 0.5
                self.followButtonOut.layer.masksToBounds = false
                self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
                self.followButtonOut.layer.shadowRadius = 5.0

                Follow.unFollowPlace(id: (self.place?.id)!)
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            parentVC?.present(unfollowAlertController, animated: true, completion: nil)
            
            
            
        }
        
    }
   
    @IBAction func inviteButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "place"
        ivc.parentCell = self
        ivc.id = self.placeID
        ivc.place = place
        ivc.searchPlace = parentVC
        if let VC = self.parentVC{
            VC.present(ivc, animated: true, completion: nil)
        }
        else{
            self.searchVC?.present(ivc, animated: true, completion: nil)
        }
        
        
        
    }
    
    func checkForFollow(id:String){
        print(id)
        print(searchVC)
        
        if let parent = parentVC{
            if (parent.followingPlaces.contains(self.place!)){
                self.followButtonOut.isSelected = true
                self.followButtonOut.layer.borderColor = UIColor.white.cgColor
                self.followButtonOut.layer.borderWidth = 1
                
                self.followButtonOut.backgroundColor = UIColor(red: 97/255.0, green: 115/255.0, blue: 129/255.0, alpha: 1.0)
                self.followButtonOut.tintColor = UIColor.clear
                self.followButtonOut.layer.shadowOpacity = 0.5
                self.followButtonOut.layer.masksToBounds = false
                self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
                self.followButtonOut.layer.shadowRadius = 5.0
            }
            else{
                self.followButtonOut.isSelected = false
                self.followButtonOut.layer.borderColor = UIColor.clear.cgColor
                self.followButtonOut.layer.borderWidth = 1
                self.followButtonOut.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
                self.followButtonOut.tintColor = UIColor.clear
                self.followButtonOut.layer.shadowOpacity = 0.5
                self.followButtonOut.layer.masksToBounds = false
                self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
                self.followButtonOut.layer.shadowRadius = 5.0
                
            }
        }
        else if let parent = searchVC{
            if (parent.places.contains(self.place!)){
                self.followButtonOut.isSelected = true
                self.followButtonOut.layer.borderColor = UIColor.white.cgColor
                self.followButtonOut.layer.borderWidth = 1
                
                self.followButtonOut.backgroundColor = UIColor(red: 97/255.0, green: 115/255.0, blue: 129/255.0, alpha: 1.0)
                self.followButtonOut.tintColor = UIColor.clear
                self.followButtonOut.layer.shadowOpacity = 0.5
                self.followButtonOut.layer.masksToBounds = false
                self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
                self.followButtonOut.layer.shadowRadius = 5.0
            }
            else{
                self.followButtonOut.isSelected = false
                self.followButtonOut.layer.borderColor = UIColor.clear.cgColor
                self.followButtonOut.layer.borderWidth = 1
                self.followButtonOut.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
                self.followButtonOut.tintColor = UIColor.clear
                self.followButtonOut.layer.shadowOpacity = 0.5
                self.followButtonOut.layer.masksToBounds = false
                self.followButtonOut.layer.shadowColor = UIColor.black.cgColor
                self.followButtonOut.layer.shadowRadius = 5.0
                
            }
        }
        
    }
}
