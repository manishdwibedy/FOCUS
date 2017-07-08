//
//  FeedOneTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedOneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameDescriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesAmountLabel: UILabel!
    @IBOutlet weak var timeAmountLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameLabel.text = "Arya"
        self.likesAmountLabel.text = "0 likes"
        self.timeAmountLabel.text = "21h ago"
        addGreenDot(label: self.interestLabel, content: "Sports")
        self.nameDescriptionLabel.text = "Watching NBA Awards - Westbrook for MVP!"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
