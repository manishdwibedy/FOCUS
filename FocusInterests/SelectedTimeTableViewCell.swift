//
//  SelectedTimeTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SelectedTimeTableViewCell: UITableViewCell {

    var contactListArray = [String]() //will need to change this to CNContacts later
    @IBOutlet weak var selectedTime: UIButton!
    
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
        bottomBorder.borderWidth = 1;
        bottomBorder.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        
    }
}
