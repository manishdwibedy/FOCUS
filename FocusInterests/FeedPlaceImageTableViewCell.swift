//
//  FeedPlaceImageTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedPlaceImageTableViewCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UIButton!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var imagePlace: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.usernameLabel.setTitle("arya", for: .normal)
        self.addressLabel.setTitle("11661 Goshen Ave", for: .normal)
        self.distanceLabel.text = "10mi"
        self.usernameImage.roundedImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
