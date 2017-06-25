//
//  SearchEventTableViewCell.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SearchEventTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var attendButton: UIButton!
    
    @IBOutlet weak var inviteButton: UIButton!
//    @IBOutlet weak var attendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.eventImage.layer.borderWidth = 1
        self.eventImage.layer.borderColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 120/255.0, alpha: 1.0).cgColor
        self.eventImage.roundedImage()
        
        address.textContainerInset = UIEdgeInsets.zero
        
        
        
//        self.attendButton.layer.shadowOpacity = 1.0
//        self.attendButton.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
//        self.attendButton.layer.masksToBounds = false
//        self.attendButton.layer.shadowColor = UIColor.purple.cgColor

//        self.attendButton.setTitle("Attend", for: .normal)
//        self.attendButton.setTitle("Unattend", for: .selected)
        
//        self.inviteButton.layer.shadowOpacity = 1.0
//        self.inviteButton.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
//        self.inviteButton.layer.masksToBounds = false
//        self.inviteButton.layer.shadowColor = UIColor.purple.cgColor
//        self.inviteButton.layer.shadowRadius = 10.0
        self.cellContentView.allCornersRounded(radius: 10.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
