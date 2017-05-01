//
//  FollowCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/26/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell, UserProfileCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var photo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        photo.image = UIImage(named: "UserPhoto")
        photo.layer.cornerRadius = 29
        photo.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureFor(user: FocusUser) {
        Username.text = user.userName!
        if let desc = user.description {
            descriptionLabel.text = desc
        } else {
            descriptionLabel.text = "No description available for \(user.userName!)"
        }
    }
}
