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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectedAllFollowers(_ sender: Any) {
        if(self.selectAllFollowersButton.image(for: .normal) == #imageLiteral(resourceName: "GreyCircle")){
            self.selectAllFollowersButton.isSelected = true
            self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "GreenCheck"), for: .selected)
            delegate?.selectedAllFollowers()
        }else{
            self.selectAllFollowersButton.isSelected = false
            self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "GreyCircle"), for: .normal)
            delegate?.deselectAllFollowers()
        }
    }
}
