//
//  SearchPeopleTableViewCell.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/24/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SearchPeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var distanceCategoryStack: UIStackView!
    @IBOutlet weak var whiteBorder: UIView!
    @IBOutlet weak var shortBackground: UIView!
    @IBOutlet weak var addressStack: UIStackView!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    var ID = ""
    var parentVC: SearchPeopleViewController!
    var pinAvailable = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //user image
        self.userImage.layer.borderWidth = 1
        self.userImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userImage.roundedImage()
        
        //cell view
//        self.cellContentView.allCornersRounded(radius: 6.0)
//        
//        self.shortBackground.allCornersRounded(radius: 6.0)
        
        //follow button
        self.followButton.clipsToBounds = true
        self.followButton.isSelected = false
        self.followButton.roundCorners(radius: 5.0)
        self.followButton.layer.shadowOpacity = 0.5
        self.followButton.layer.masksToBounds = false
        self.followButton.layer.shadowColor = UIColor.black.cgColor
        self.followButton.layer.shadowRadius = 5.0
        
        self.followButton.setTitle("Follow", for: UIControlState.normal)
        self.followButton.setTitle("Unfollow", for: UIControlState.selected)
        
        //invite button
        self.inviteButton.clipsToBounds = true
        self.inviteButton.roundCorners(radius: 5.0)
        self.inviteButton.layer.shadowOpacity = 0.5
        self.inviteButton.layer.masksToBounds = false
        self.inviteButton.layer.shadowColor = UIColor.black.cgColor
        self.inviteButton.layer.shadowRadius = 5.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cellContentView.setNeedsLayout()
        self.shortBackground.setNeedsLayout()
        
        self.cellContentView.layoutIfNeeded()
        self.shortBackground.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: self.cellContentView.bounds, cornerRadius: 10)
        let shortBackgroundPath = UIBezierPath(roundedRect: self.shortBackground.bounds, cornerRadius: 10)
        
        let mask = CAShapeLayer()
        let shortbackgroundMask = CAShapeLayer()
        
        mask.path = path.cgPath
        shortbackgroundMask.path = shortBackgroundPath.cgPath
        
        self.cellContentView.layer.mask = mask
        self.shortBackground.layer.mask = shortbackgroundMask
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func checkFollow(){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: ID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print("got follow data")
            print(value)
            if value != nil {
                print("following user is checkFollow")
                self.followButton.isSelected = true
                self.followButton.layer.borderColor = UIColor.white.cgColor
                self.followButton.layer.borderWidth = 1
                self.followButton.backgroundColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
                self.followButton.tintColor = UIColor.clear
                self.followButton.layer.shadowOpacity = 0.5
                self.followButton.layer.masksToBounds = false
                self.followButton.layer.shadowColor = UIColor.black.cgColor
                self.followButton.layer.shadowRadius = 5.0
            } else {
                print("follow user is checkFollow")
                self.followButton.isSelected = false
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor.clear.cgColor
                self.followButton.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
                self.followButton.tintColor = UIColor.clear
                self.followButton.layer.shadowOpacity = 0.5
                self.followButton.layer.masksToBounds = false
                self.followButton.layer.shadowColor = UIColor.black.cgColor
                self.followButton.layer.shadowRadius = 5.0
            }
        })
    }
    
//  MARK: This isn't a necessary method as there is already an action attached to the follow button.  However kept this just incase you need some of the code
    @IBAction func followUser(_ sender: UIButton) {
        let time = NSDate().timeIntervalSince1970

        if self.followButton.isSelected == false{
            Follow.followUser(uid: self.ID)
            sender.isSelected = true
            sender.layer.borderWidth = 1
            sender.layer.borderColor = UIColor.white.cgColor
            sender.backgroundColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
            sender.tintColor = UIColor.clear
            sender.layer.shadowOpacity = 0.5
            sender.layer.masksToBounds = false
            sender.layer.shadowColor = UIColor.black.cgColor
            sender.layer.shadowRadius = 5.0
 
        } else if self.followButton.isSelected == true{

            let unfollowAlertController = UIAlertController(title: "Unfollow \(self.username.text!)?", message: nil, preferredStyle: .actionSheet)
            
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                
                Follow.unFollowUser(uid: self.ID)
                
                sender.isSelected = false
                sender.layer.borderWidth = 1
                sender.layer.borderColor = UIColor.clear.cgColor
                sender.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
                sender.tintColor = UIColor.clear
                sender.layer.shadowOpacity = 0.5
                sender.layer.masksToBounds = false
                sender.layer.shadowColor = UIColor.black.cgColor
                sender.layer.shadowRadius = 5.0
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            parentVC.present(unfollowAlertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func inviteUser(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "search_people", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "invitePeople") as! InvitePeopleViewController
        ivc.UID = ID
        parentVC.present(ivc, animated: true, completion: { _ in })
    }
}


