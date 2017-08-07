//
//  ChooseLocationTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 8/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class ChooseLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var currentLocationLabel: UILabel!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var locationDistanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = Constants.color.navy
        self.tintColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
