//
//  EventInFeedCreatedEventTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/9/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class EventInFeedCreatedEventTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var guestAmountLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var placeNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.eventImage.layer.borderWidth = 1
        self.eventImage.layer.borderColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 120/255.0, alpha: 1.0).cgColor
        self.eventImage.roundedImage()
        
        addressLabel.textContainerInset = UIEdgeInsets.zero
        
        self.attendButton.roundCorners(radius: 5.0)
        self.attendButton.layer.shadowOpacity = 0.5
        self.attendButton.layer.masksToBounds = false
        self.attendButton.layer.shadowColor = UIColor.black.cgColor
        self.attendButton.layer.shadowRadius = 5.0

        self.attendButton.setTitle("Attend", for: .normal)
        self.attendButton.setTitle("Unattend", for: .selected)
        
        self.inviteButton.roundCorners(radius: 5.0)
        self.inviteButton.layer.shadowOpacity = 0.5
        self.inviteButton.layer.masksToBounds = false
        self.inviteButton.layer.shadowColor = UIColor.black.cgColor
        self.inviteButton.layer.shadowRadius = 5.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cellContentView.setNeedsLayout()
        
        self.cellContentView.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: self.cellContentView.bounds, cornerRadius: 10)
        
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.cellContentView.layer.mask = mask
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
