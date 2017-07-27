//
//  SingleInterestTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SingleInterestTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var interestLabel: UIButton!
    @IBOutlet weak var interestImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func selectInterest(_ sender: Any) {
        print("select interest")
        if self.accessoryType == .checkmark{
            self.interestLabel.isSelected = false
            self.accessoryType = .none
        }else{
            self.interestLabel.isSelected = true
            self.accessoryType = .checkmark
        }
    }
    
}
