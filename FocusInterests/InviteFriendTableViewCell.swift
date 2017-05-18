//
//  InviteFriendTableViewCell.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InviteFriendTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var selectFriendBttn: UIButton!
    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var friendIconImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
