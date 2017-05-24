//
//  inviteCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class inviteCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inviteButtonOut: UIButton!
    
    var data: inviteData!
    var parent: invitePlaceCV!
    override func awakeFromNib() {
        super.awakeFromNib()
        inviteButtonOut.backgroundColor = UIColor.clear
        inviteButtonOut.layer.borderColor = UIColor.white.cgColor
        inviteButtonOut.layer.borderWidth = 1
        inviteButtonOut.layer.cornerRadius = 5
        inviteButtonOut.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load()
    {
        Constants.DB.user.child(data.UID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.nameLabel.text = value?["username"] as? String
                
            }
        })
    }
    
    
    @IBAction func inviteButton(_ sender: Any) {
        self.parent.inviteUIDList.append(data.UID)
        self.inviteButtonOut.backgroundColor = UIColor(red: 119/255, green: 197/255, blue: 53/255, alpha: 1)
        self.inviteButtonOut.layer.borderColor = UIColor.clear.cgColor
        self.inviteButtonOut.isEnabled = false
        
    }
    
}

class inviteData
{
    var UID = String()
}
