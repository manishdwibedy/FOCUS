//
//  AllOptionTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class AllOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var checkMarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func allisSelected(_ sender: Any) {
        self.checkMarkButton.isHidden = !self.checkMarkButton.isHidden
        self.allButton.isSelected = !self.allButton.isSelected
        self.checkMarkButton.isSelected = !self.checkMarkButton.isSelected
        self.isSelected = !self.isSelected
    }
}
