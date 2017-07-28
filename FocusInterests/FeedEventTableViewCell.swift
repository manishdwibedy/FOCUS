//
//  FeedEventTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedEventTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabelButton: UIButton!
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var eventNameLabelButton: UIButton!
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameLabelButton.setTitle("arya", for: .normal)
        self.eventNameLabelButton.setTitle("Event B", for: .normal)
        addGreenDot(label: self.interestLabel, content: "Food")
        self.distanceLabel.text = "21 mi"
        self.usernameImage.roundedImage()
        self.eventImage.roundedImage()
        self.attendButton.layer.borderWidth = 1.0
        self.attendButton.layer.borderColor = UIColor.white.cgColor
        self.attendButton.roundCorners(radius: 6.0)
        self.inviteButton.roundCorners(radius: 6.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
