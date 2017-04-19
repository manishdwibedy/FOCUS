//
//  DisplayInterestsCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 4/1/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class DisplayInterestsCell: UITableViewCell, InterestDelegate {
    
    var interestNames = [String]()

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        label.font = UIFont(name: "Futura", size: 18)
        label.textColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
    }
    
    func configure() {
        
        if self.interestNames.count > 0 {
            var str = ""
            
            var n = 0
            for word in interestNames {
                if n % 2 == 0 {
                    str.append(word)
                } else {
                    str.append("\t\t\(word)\n")
                }
                n += 1
            }

        } else {
            label.text = "I have not selected interests yet."
        }
    }
    
    func passInterests(interests: [String]) {
        self.interestNames = interests
        configure()
    }
    
}
