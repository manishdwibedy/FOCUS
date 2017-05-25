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

    @IBOutlet weak var fullName: UILabel!

    var ID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkFollow(){
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: ID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                
                self.followButton.layer.borderColor = UIColor.white.cgColor
                self.followButton.layer.borderWidth = 1
                self.followButton.backgroundColor = UIColor.clear
                self.followButton.setTitle("Following", for: UIControlState.normal)
            }else
            {
                self.followButton.layer.borderColor = UIColor.clear.cgColor
                self.followButton.layer.borderWidth = 0
                self.followButton.backgroundColor = UIColor(red: 31/225, green: 50/255, blue: 73/255, alpha: 1)
                self.followButton.setTitle("Follow", for: UIControlState.normal)
            }
        })
    }
    
    @IBAction func followUser(_ sender: UIButton) {
        let time = NSDate().timeIntervalSince1970

        if followButton.title(for: .normal) == "Follow"{
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people").childByAutoId().updateChildValues(["UID":ID, "time":Double(time)])
            
            Constants.DB.user.child(ID).child("followers").child("people").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!, "time":time])
            
            self.followButton.layer.borderColor = UIColor.white.cgColor
            self.followButton.layer.borderWidth = 1
            self.followButton.backgroundColor = UIColor.clear
            self.followButton.setTitle("Following", for: UIControlState.normal)
        }
        else{
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
    }
}
