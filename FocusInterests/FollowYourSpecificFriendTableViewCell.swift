//
//  FollowYourSpecificFriendTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowYourSpecificFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.usernameImage.roundedImage()
        
        self.followButton.setImage(UIImage(named: "GreyCircle.png"), for: .normal)
        self.followButton.setImage(UIImage(named: "Green.png"), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
