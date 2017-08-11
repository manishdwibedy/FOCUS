//
//  SelectAllContactsTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/11/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SelectAllContactsTableViewCell: UITableViewCell {
    @IBOutlet weak var selectAllFollowersButton: UIButton!

    var delegate: SelectAllContactsDelegate?
    
    @IBOutlet weak var inviteAllFollowers: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectAllFollowersButton.layer.borderWidth = 1
        self.selectAllFollowersButton.layer.borderColor = UIColor.white.cgColor
        self.selectAllFollowersButton.roundButton()
        
        self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "Interest_blank"), for: .normal)
        self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "Green.png"), for: .selected)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func selectedAllFollowers(_ sender: Any) {
        self.selectAllFollowersButton.isSelected = !self.selectAllFollowersButton.isSelected
        if self.selectAllFollowersButton.isSelected{
            self.isSelected = true
            delegate?.selectedAllFollowers()
        }else{
            self.isSelected = false
            delegate?.deselectAllFollowers()
        }
    }
}
