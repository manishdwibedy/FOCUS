//
//  SelectedTimeTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SelectedTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedTimeButton: UIButton!
    var contactListArray = [String]() //will need to change this to CNContacts later
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupBottomBorderForSelectedTimeButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupBottomBorderForSelectedTimeButton(){
        let bottomBorder: CALayer = CALayer()
        bottomBorder.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRect(x: 0, y: self.selectedTimeButton.frame.height, width: self.selectedTimeButton.frame.width, height: 1)
        self.selectedTimeButton.layer.addSublayer(bottomBorder)
    }
}
