//
//  PinPlaceReviewTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PinPlaceReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var timeOfPinLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var categoryImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userProfileImage.layer.borderWidth = 1
        self.userProfileImage.layer.borderColor = UIColor.cyan.cgColor
        self.categoryImage.image = UIImage(named: "Green.png")
        self.userProfileImage.roundedImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
