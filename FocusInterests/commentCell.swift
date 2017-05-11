//
//  commentCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
