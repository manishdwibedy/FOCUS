//
//  FollowingOptionTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowingOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var checkMarkButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followingIsSelected(_ sender: Any) {
        self.checkMarkButton.isHidden = !self.checkMarkButton.isHidden
        self.followingButton.isSelected = !self.followingButton.isSelected
        self.checkMarkButton.isSelected = !self.checkMarkButton.isSelected
        self.isSelected = !self.isSelected
    }
}
