//
//  UserDescriptionCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class UserDescriptionCell: UITableViewCell, DescriptionDelegate, EditDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(description: String) {
        descriptionLabel.text = description
    }
    
    func makeStatic() {
        self.isUserInteractionEnabled = false
    }
    
    func makeEditable() {
        self.isUserInteractionEnabled = true
    }
    
}
