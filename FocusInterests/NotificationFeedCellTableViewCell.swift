//
//  NotificationFeedCellTableViewCell.swift
//  FocusInterests
//
//  Created by Nicolas on 01/06/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

//Alex Jang Todo List
//TODO: Tell Arya that we need a Blue Circle Icon for Location Pic
//TODO: Need to figure out how to readjust size of "See You There" Button

import UIKit

class NotificationFeedCellTableViewCell: UITableViewCell {

    @IBOutlet weak var nextTimeButton: UIButton!
    @IBOutlet weak var seeYouThereButton: UIButton!
    @IBOutlet weak var timeOfNotificationLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var userProfilePic: UIButton!
    
    var selectedButton = false
    var notif: FocusNotification!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(notif: FocusNotification) {
        self.roundButtonsAndPictures()
        
//        self.userProfilePic.image = notif.sender?.username
        let content = (notif.sender?.username)! + " " + (notif.type?.rawValue)! + " " + (notif.item?.itemName!)!
        self.userNameLabel.text = (notif.sender?.username)!
        self.locationNameLabel.text = notif.item?.itemName
//        self.notifImgView.image = notif.item?.imageURL
        self.timeLabel.text = "2h"
        
        self.notif = notif
    }
    
    func roundButtonsAndPictures(){
        self.seeYouThereButton.layer.cornerRadius = 6
        self.nextTimeButton.layer.cornerRadius = 6
        
        self.userProfilePic.layer.borderWidth = 2
        self.locationImage.layer.borderWidth = 2
        
        self.userProfilePic.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.locationImage.layer.borderColor = UIColor.cyan.cgColor
        
        self.userProfilePic.imageView?.roundedImage()
        self.locationImage.roundedImage()
    }
    
    
    @IBAction func seeYouTherePushed(_ sender: Any) {
        
        if selectedButton == false{
            selectedButton = true
            seeYouThereButton.isHidden = true
            nextTimeButton.isEnabled = false
            nextTimeButton.setTitle("Accepted", for: UIControlState.normal)
        }
        
    }
    
    @IBAction func nextTimePushed(_ sender: Any) {
        selectedButton = true
        seeYouThereButton.isHidden = true
        nextTimeButton.isEnabled = false
        nextTimeButton.setTitle("Declined", for: UIControlState.normal)
        
    }
    
    @IBAction func profilePicPushed(_ sender: Any) {
        
        if notif.type == NotificationType.Invite{
            print(notif.item?.itemName)
        }
        print(notif.item?.itemName)
        print(notif.type)
        
    }
    
    
    
    
    
    
    
    
}












