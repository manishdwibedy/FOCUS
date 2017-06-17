//
//  notificationTabCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class notificationTabCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var typePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var whatLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var data: NSDictionary!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.profileImage.layer.borderWidth = 2
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.clipsToBounds = true
        
        self.typePic.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.typePic.layer.borderWidth = 2
        self.typePic.layer.cornerRadius = self.profileImage.frame.width/2
        self.typePic.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
     func setupCell(notif: FocusNotification) {
        
        data = notif.item?.data
        
        
             Constants.DB.user.child(data["senderID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    self.usernameLabel.text = value?["username"] as? String
                }
                
                let placeholderImage = UIImage(named: "empty_event")
                self.profileImage.sd_setImage(with: URL(string:(value?["image_string"])! as! String), placeholderImage: placeholderImage)
                
                
                self.profileImage.setShowActivityIndicator(true)
                self.profileImage.setIndicatorStyle(.gray)

             })
        if data["type"] as! String == "event"{
        Constants.DB.event.child(data["id"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let placeholderImage = UIImage(named: "empty_event")
            self.typePic.sd_setImage(with: URL(string:(snapshot.key)), placeholderImage: placeholderImage)
            
            self.profileImage.setShowActivityIndicator(true)
            self.profileImage.setIndicatorStyle(.gray)
            
        })
        }else{
        
        }
        
        self.timeLabel.text = getTimeSince(date: notif.time!)
        
        
        
        if data["actionType"] as! String == "Like"{
            actionLabel.text = "liked your"
            
        }else{
            actionLabel.text = "commented on your"
        }
        if data["type"] as! String == "event"{
            whatLabel.text = "event"
        }else{
            whatLabel.text = "pin"
        }
        
       
     }
    
    func getTimeSince(date:Date) -> String
    {
        var returnString = ""
        let now = Date()
        let seconds = now.timeIntervalSince(date)
        let minutes = seconds/60
        let hours = minutes/60
        let days = hours/24
        if Int(days) >= 1
        {
            returnString = String(Int(days)) + " days ago"
            
        }else if Int(hours) >= 1
        {
            returnString = String(Int(hours)) + " hours ago"
            
        }else if Int(minutes) >= 1
        {
            returnString = String(Int(minutes)) + " minutes ago"
            
        }else if seconds < 60
        {
            returnString = "seconds ago"
        }
        
        return returnString
    }

    
    
    
    
    
    
    
}
