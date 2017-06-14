//
//  UserProfileCollectionViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/9/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class UserProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userEventsImage: UIImageView!
    @IBOutlet weak var userEventsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userEventsImage.layer.borderWidth = 1
        self.userEventsImage.layer.borderColor = UIColor.darkGreen().cgColor
        self.userEventsImage.roundedImage()
    }

}
