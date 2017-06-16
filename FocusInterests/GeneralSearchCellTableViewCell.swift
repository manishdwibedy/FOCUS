//
//  GeneralSearchCellTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class GeneralSearchCellTableViewCell: UITableViewCell {

    @IBOutlet weak var searchChoiceLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.categoryImage.roundedImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
