//
//  FeedPlaceTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedPlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameImage: UIImageView!

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placePhoto: UIImageView!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var placeBeingLiked: UIButton!
    @IBOutlet weak var usernameWhoIsBeingLiked: UIButton!
    @IBOutlet weak var usernameWhoLikedLabel: UIButton!    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.usernameImage.roundedImage()
        self.placePhoto.roundedImage()
        addGreenDot(label: interestLabel, content: "Food")
        self.distanceLabel.text = "50 mi"
        var pinPlace = "UCLA Pavilion"
        var pinName = "Pin: \(pinPlace)"
        
        self.placeBeingLiked.setTitle(pinName, for: .normal)
        self.usernameWhoLikedLabel.setTitle("arya", for: .normal)
        self.usernameWhoIsBeingLiked.setTitle("username's", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
