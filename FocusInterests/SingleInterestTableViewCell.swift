//
//  SingleInterestTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SingleInterestTableViewCell: UITableViewCell {

    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var interestButtonImage: UIButton!
    @IBOutlet weak var interestLabel: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.checkMarkButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectInterest(_ sender: Any) {
        print("select interest")
        
        self.checkMarkButton.isHidden = !self.checkMarkButton.isHidden
    }
    
}
