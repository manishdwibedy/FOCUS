//
//  RatingViewCell.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Cosmos

class RatingViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var comments: UITextView!
    @IBOutlet weak var rating: CosmosView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
