//
//  DisplayInterestsCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 4/1/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class DisplayInterestsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
    }
    
    func layoutButtons() {
        var even: CGFloat = 40.0
        var odd: CGFloat = (self.frame.width - 90)
        var y = 40
        for n in 0..<FirebaseDownstream.shared.giantInterestMap.keys.count {
            //Logic for button placement 
        }
    }
    
}
