//
//  DisplayInterestsCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 4/1/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class DisplayInterestsCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
    }
    
    func configureFor(user: FocusUser) {
        if user.interests.count > 0 {
            
        } else {
            label.text = "I have not selected interests yet."
        }
    }
    
}
