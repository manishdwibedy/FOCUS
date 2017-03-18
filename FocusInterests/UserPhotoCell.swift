//
//  UserPhotoCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class UserPhotoCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var uploadPhoto: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
