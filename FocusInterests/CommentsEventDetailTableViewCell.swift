//
//  CommentsEventDetailTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/9/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CommentsEventDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likeTotal: UILabel!
    @IBOutlet weak var likeHeartButton: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfileImage.roundedImage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
