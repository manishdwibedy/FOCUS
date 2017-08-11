//
//  FeedEventTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedEventTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabelButton: UIButton!
    @IBOutlet weak var nameLabelButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var usernameImage: UIButton!
    @IBOutlet weak var eventNameLabelButton: UIButton!
    
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var eventImage: UIButton!
    @IBOutlet weak var isAttendLabel: UILabel!
    @IBOutlet weak var isAttendingLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var globeImage: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.nameLabelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.eventNameLabelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.isAttendLabel.adjustsFontSizeToFitWidth = true
//        self.isAttendingLabelWidth.constant = self.isAttendLabel.intrinsicContentSize.width
        
        self.nameLabelButton.setTitle("arya", for: .normal)
        self.eventNameLabelButton.setTitle("Event B", for: .normal)
        addGreenDot(label: self.interestLabel, content: "Food")
        self.distanceLabel.text = "21 mi"
        self.usernameImage.roundButton()
        self.eventImage.roundButton()
        self.attendButton.layer.borderWidth = 1.0
        self.attendButton.layer.borderColor = UIColor.white.cgColor
        self.attendButton.roundCorners(radius: 6.0)
        self.inviteButton.roundCorners(radius: 6.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func goBackToMap(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
        vc.willShowPin = true
        //        vc.showPin = pin
        //        vc.location = CLLocation(latitude: pinData.coordinates.la, longitude: coordinates.longitude)
        vc.selectedIndex = 0
    }
    
}
