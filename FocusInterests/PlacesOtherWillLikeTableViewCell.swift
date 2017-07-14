//
//  PlacesOtherWillLikeTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PlacesOtherWillLikeTableViewCell: UITableViewCell {

    @IBOutlet weak var placesImage: UIImageView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var openHoursLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.placesImage.layer.borderWidth = 1
        self.placesImage.layer.borderColor = Constants.color.lightBlue.cgColor
        self.placesImage.roundedImage()
        self.inviteButton.roundCorners(radius: 5.0)
        self.openHoursLabel.text = "Hours today: 17:00 - 23:30"
        self.distanceLabel.text = "3.1 mi"
        self.ratingsLabel.text = "4.7 (215 ratings)"
        self.placesLabel.text = "Place Name"
        addGreenDot(label: self.interestLabel, content: "Interest")
        self.addressLabel.text = "1234 Main St."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
