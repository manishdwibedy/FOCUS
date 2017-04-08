//
//  SelectedInterestCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 4/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SelectedInterestCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        accessoryType = .none
        backgroundColor = UIColor.white
        tintColor = UIColor.black
    }
    
}
