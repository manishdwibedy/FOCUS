//
//  FollowersTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowersTableViewCell: UITableViewCell {

    @IBOutlet weak var followerImage: UIImageView!
    @IBOutlet weak var followerUserNameLabel: UILabel!
    @IBOutlet weak var followerFullNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.white.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
