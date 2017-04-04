//
//  UserDescriptionCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class UserDescriptionCell: UITableViewCell, DescriptionDelegate, EditDelegate, UserProfileCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
        descriptionLabel.font = UIFont(name: "Futura", size: 18)
        descriptionLabel.textColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureFor(user: FocusUser) {
        
    }
    
    func update(description: String) {
        descriptionLabel.text = description
    }
    
    func makeStatic() {
        self.isUserInteractionEnabled = false
    }
    
    func makeEditable(currentString: String) {
        self.descriptionLabel.text = currentString
        self.isUserInteractionEnabled = true
    }
    
    
    
}
