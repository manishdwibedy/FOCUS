//
//  FeedOneTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedOneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameDescriptionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesAmountLabel: UILabel!
    @IBOutlet weak var timeAmountLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var distanceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImage.roundedImage()
        self.usernameLabel.text = "username"
        self.addressLabel.text = "1600 Campus Road"
        self.distanceLabel.text = "2 mi"
        
        addGreenDot(label: self.interestLabel, content: "Sports")
        self.nameDescriptionLabel.text = "Watching NBA Awards - Westbrook for MVP!"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
