//
//  InterestTableViewCell.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InterestTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var selectedInterestLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
