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

    var ID = ""
    var parentVC: SearchPeopleViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImage.layer.borderWidth = 2
        self.userImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userImage.roundedImage()
        self.cellContentView.allCornersRounded(radius: 6.0)
        
        self.followButton.roundCorners(radius: 10)
        self.followButton.layer.shadowOpacity = 1.0
        self.followButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.followButton.layer.masksToBounds = false
        self.followButton.layer.shadowColor = UIColor.black.cgColor
        self.followButton.layer.shadowRadius = 10.0
        
        self.inviteButton.roundCorners(radius: 10)
        self.inviteButton.layer.shadowOpacity = 1.0
        self.inviteButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.inviteButton.layer.masksToBounds = false
        self.inviteButton.layer.shadowColor = UIColor.black.cgColor
        self.inviteButton.layer.shadowRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkFollow(){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: ID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil {
                self.followButton.layer.borderColor = UIColor.white.cgColor
                self.followButton.layer.borderWidth = 1
                self.followButton.backgroundColor = UIColor.clear
                self.followButton.setTitle("Following", for: UIControlState.normal)
            } else {
                self.followButton.layer.borderColor = UIColor.clear.cgColor
                self.followButton.layer.borderWidth = 0
                self.followButton.backgroundColor = UIColor(red: 31/225, green: 50/255, blue: 73/255, alpha: 1)
                self.followButton.setTitle("Follow", for: UIControlState.normal)
            }
        })
    }
    
//    TODO: Bug when trying to unfollow a user
    @IBAction func followUser(_ sender: UIButton) {
        let time = NSDate().timeIntervalSince1970

        if followButton.title(for: .normal) == "Follow"{
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").childByAutoId().updateChildValues(["UID":ID, "time":Double(time)])
            
            Constants.DB.user.child(ID).child("followers").child("people").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":time])
            
            self.followButton.layer.borderColor = UIColor.white.cgColor
            self.followButton.layer.borderWidth = 1
            self.followButton.backgroundColor = UIColor.clear
            self.followButton.setTitle("Following", for: UIControlState.normal)
        } else {
           Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: ID).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                
                for (id, _) in value!{
                    Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people/\(id)").removeValue()
                }
             
                })
            Constants.DB.user.child(self.ID).child("followers").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                
                for (id, _) in value!{
                    Constants.DB.user.child(self.ID).child("followers/people/\(id)").removeValue()
                    
                }
                
            })
            self.followButton.layer.borderColor = UIColor.clear.cgColor
            self.followButton.layer.borderWidth = 0
            self.followButton.backgroundColor = UIColor(red: 31/225, green: 50/255, blue: 73/255, alpha: 1)
            self.followButton.setTitle("Follow", for: UIControlState.normal)
        }
    }
    
    @IBAction func inviteUser(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "search_people", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "invitePeople") as! InvitePeopleViewController
        ivc.UID = ID
        parentVC.present(ivc, animated: true, completion: { _ in })
    }
}


