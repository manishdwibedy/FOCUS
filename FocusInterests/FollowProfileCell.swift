//
//  FollowProfileCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase

class FollowProfileCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followOut: UIButton!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    let ref = Database.database().reference()
    var data: followProfileCellData!
    var parentVC: attendeeVC? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.followOut.layer.cornerRadius = 6
        self.followOut.clipsToBounds = true
        self.followOut.roundCorners(radius: 5)
        self.followOut.layer.shadowOpacity = 0.7
        self.followOut.layer.masksToBounds = false
        self.followOut.layer.shadowColor = UIColor.black.cgColor
        self.followOut.layer.shadowRadius = 5.0
        self.profileImage.roundedImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData()
    {
        print("loading username")
        print(data.uid)
        ref.child("users").child(data.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                if let fullNameVal = value?["fullname"] as? String{
                    if (fullNameVal == ""){
                        self.usernameLabel.text = value?["username"] as? String
                    }else{
                        self.fullnameLabel.text = fullNameVal
                        if let usernameLabel = self.usernameLabel.text{
                            var usernameAttribute = NSMutableAttributedString()
                            usernameAttribute = NSMutableAttributedString(string: usernameLabel, attributes: [NSFontAttributeName:UIFont(name: "Avenir Heavy", size: 15.0)!])
                            self.usernameLabel.attributedText = usernameAttribute
                        }
                    }
                }
                
                self.data.username = (value?["username"] as? String)!
                self.ifFollowing(uid: self.data.uid, completionIt: {(boolV) -> () in
                
                    if boolV == true
                    {
                        self.followOut.layer.borderColor = UIColor.white.cgColor
                        self.followOut.layer.borderWidth = 1
                        self.followOut.backgroundColor = UIColor.clear
                        self.followOut.setTitle("Following", for: UIControlState.normal)
                    }
                })
            }
        })
    }
    
    func ifFollowing(uid:String,completionIt: @escaping (_ result: Bool)->())
    {
        ref.child("users").child(AuthApi.getFirebaseUid()!).child("following").queryOrdered(byChild: "UID").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                completionIt(true)
            }else
            {
                completionIt(false)
            }
           
        })
       
    }
    
    
    @IBAction func follow(_ sender: Any) {
        if followOut.titleLabel?.text == "Follow"{
            Follow.followUser(uid: data.uid)
            
            followOut.layer.borderColor = UIColor.white.cgColor
            followOut.layer.borderWidth = 1
            followOut.backgroundColor = UIColor.clear
            followOut.setTitle("Following", for: UIControlState.normal)
            
        }
        else{
            ref.child("users").child(AuthApi.getFirebaseUid()!).child("following").childByAutoId().updateChildValues(["UID": data.uid])
            followOut.backgroundColor = Constants.color.green
            followOut.setTitle("Follow", for: UIControlState.normal)
            
            let unfollowAlertController = UIAlertController(title: "Unfollow", message: "Are you sure you want to unfollow \(data.username)", preferredStyle: .actionSheet)
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                Follow.unFollowUser(uid: self.data.uid)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            parentVC?.present(unfollowAlertController, animated: true, completion: nil)
            
            
            
        }
        
    }
    
}

class followProfileCellData
{
    var username = String()
    var uid = String()
}
