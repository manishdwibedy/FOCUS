//
//  SelectAllInterestsTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SelectAllInterestsTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var showAllButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectAllClicked(_ sender: Any) {
        if self.accessoryType == .checkmark{
            self.showAllButton.isSelected = false
            self.accessoryType = .none
        }else{
            self.showAllButton.isSelected = true
            self.accessoryType = .checkmark
        }
        
    }
    
}
