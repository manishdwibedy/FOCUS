//
//  NewMessageTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class NewMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(){
        self.userProfileImage.layer.borderWidth = 2
        self.userProfileImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userProfileImage.roundedImage()
    }
    
}
