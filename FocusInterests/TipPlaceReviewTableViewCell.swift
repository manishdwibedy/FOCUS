//
//  TipPlaceReviewTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class TipPlaceReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var likeAmountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var tipCommentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userProfileImage.roundedImage()
        self.likeButton.setImage(UIImage(named: "Liked.png"), for: .selected)
        self.likeButton.setImage(UIImage(named: "Like.png"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if(self.likeButton.state == .normal){
            self.likeButton.isSelected = true
        }else if(self.likeButton.state == .selected){
            self.likeButton.isSelected = false
        }
    }
}
