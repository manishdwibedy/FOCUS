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
        if(self.selectAllFollowersButton.image(for: .normal) == #imageLiteral(resourceName: "Interest_blank")){
            self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "Interest_Filled"), for: .normal)
            delegate?.selectedAllFollowers()
        }else{
            self.selectAllFollowersButton.setImage(#imageLiteral(resourceName: "Interest_blank"), for: .normal)
            delegate?.deselectAllFollowers()
        }
    }
}
