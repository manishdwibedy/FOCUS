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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "Green.png"), for: .selected)
        self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "Interest_blank"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectedAllFollowers(_ sender: Any) {
        if(self.selectAllFollowersButton.isSelected == false){
            self.selectAllFollowersButton.isSelected = true
//            delegate?.selectedAllFollowers()
        }else{
            self.selectAllFollowersButton.isSelected = false
//            delegate?.deselectAllFollowers()
        }
    }
}
