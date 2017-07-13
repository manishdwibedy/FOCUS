//
//  EventOtherWillLikeTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class EventOtherWillLikeTableViewCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.eventImage.layer.borderWidth = 1
        self.eventImage.layer.borderColor = Constants.color.pink.cgColor
        self.eventImage.roundedImage()
        self.inviteButton.roundCorners(radius: 5.0)
        self.timeLabel.text = "17:00 - 21:00"
        self.distanceLabel.text = "2.8 mi"
        self.ratingLabel.text = "4.7 (134 ratings)"
        self.eventNameLabel.text = "Event Name"
        addGreenDot(label: self.interestLabel, content: "Interest")
        self.eventAddress.text = "1234 Main St., Los Angeles, CA 91101"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
