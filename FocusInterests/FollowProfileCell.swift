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
    
    let ref = FIRDatabase.database().reference()
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
            print(value)
            if value != nil
            {
                self.usernameLabel.text = value?["username"] as? String
                self.data.username = (value?["username"] as? String)!
            }
        })
    }
    
    
    @IBAction func follow(_ sender: Any) {
        
        
    }
    
}

class followProfileCellData
{
    var username = String()
    var uid = String()
}
