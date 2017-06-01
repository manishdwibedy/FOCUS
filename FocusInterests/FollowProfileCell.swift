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
    
    let ref = Database.database().reference()
    var data: followProfileCellData!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        followOut.layer.cornerRadius = 6
        followOut.clipsToBounds = true
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
                self.usernameLabel.text = value?["username"] as? String
                self.data.username = (value?["username"] as? String)!
                self.ifFollowing(uid: self.data.uid, completionIt: {(boolV) -> () in
                
                    if boolV == true
                    {
                        self.followOut.isEnabled = false
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
        
        ref.child("users").child(AuthApi.getFirebaseUid()!).child("following").childByAutoId().updateChildValues(["UID": data.uid])
        followOut.isEnabled = false
        followOut.layer.borderColor = UIColor.white.cgColor
        followOut.layer.borderWidth = 1
        followOut.backgroundColor = UIColor.clear
        followOut.setTitle("Following", for: UIControlState.normal)
        
    }
    
}

class followProfileCellData
{
    var username = String()
    var uid = String()
}
