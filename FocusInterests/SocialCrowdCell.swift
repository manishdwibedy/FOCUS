//
//  SocialCrowdCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/27/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SocialCrowdCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureFor(followers: [FocusUser], followed: [FocusUser]) {
        var erString = ""
        var ingString = ""
        
        if followers.count > followed.count {
            leftLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        } else {
            rightLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
        for person in followers {
            erString.append("\(person.getUsername()!)\n")
        }
        for person in followed {
            ingString.append("\(person.getUsername()!)\n")
        }
        rightLabel.text = erString
        leftLabel.text = ingString
        rightLabel.font = UIFont(name: "Futura", size: 18)
        leftLabel.font = UIFont(name: "Futura", size: 18)
        rightLabel.textColor = UIColor.black
        leftLabel.textColor = UIColor.black
    }
    
}
