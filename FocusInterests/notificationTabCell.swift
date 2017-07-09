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
    var parentVC: NotificationFeedViewController? = nil
    var notification: FocusNotification? = nil
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
        
        self.contentView.backgroundColor = Constants.color.navy
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
     func setupCell(notif: FocusNotification) {
        self.notification = notif
        data = notif.item?.data
        
        var usernameStr = ""
        var actionStr = ""
        var whatStr = ""
        
        if let sender = data["senderID"] as? String{
            Constants.DB.user.child(sender).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                self.profileImage.sd_setImage(with: URL(string:(value?["image_string"])! as! String), placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                
                self.profileImage.setShowActivityIndicator(true)
                self.profileImage.setIndicatorStyle(.gray)
                
            })

        }
        
        self.profileImage.image = #imageLiteral(resourceName: "placeholder_people")
        if let image_url = notif.sender?.imageURL{
            self.profileImage.sd_setImage(with: URL(string:(image_url)), placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
            
            
            self.profileImage.setShowActivityIndicator(true)
            self.profileImage.setIndicatorStyle(.gray)
        }
        
        
        if data["type"] as! String == "event"{
            Constants.DB.event.child(data["id"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                _ = snapshot.value as? NSDictionary
                
                let placeholderImage = UIImage(named: "empty_event")
                
                let reference = Constants.storage.event.child("\(self.data["id"] as! String ).jpg")
                
                
                reference.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        return
                    }
                    
                    self.typePic.sd_setImage(with: url, placeholderImage: placeholderImage)
                    self.typePic.setShowActivityIndicator(true)
                    self.typePic.setIndicatorStyle(.gray)
                    
                })
        })
        }
        else if data["type"] as! String == "pin"{
        
        }
        
        self.timeLabel.text = getTimeSince(date: notif.time!)
        
        
        
        if data["actionType"] as! String == "like"{
            actionStr = "liked your"
            
        } else if data["actionType"] as! String == "comment"{
            actionStr = "commented on your"
        } else{
            actionStr = "is coming to your"
        }
        
        if data["type"] as! String == "event"{
            if data["actionType"] as! String == "like"{
                whatStr = "Event - \(notif.item!.itemName!)"
            }
            else{
                whatStr = "Event: \"\(notif.item!.itemName!)\""
            }
        } else if data["type"] as! String == "pin"{
            if data["actionType"] as! String == "like"{
                whatStr = "Pin - \(notif.item!.itemName!)"
            }
            else{
                whatStr = "Pin: \"\(notif.item!.itemName!)\""
            }
            
        }
        else if data["type"] as! String == "place"{
            if data["actionType"] as! String == "like"{
                whatStr = "Place - \(notif.item!.itemName!)"
            }
            else{
                whatStr = "Place: \"\(notif.item!.itemName!)\""
            }
            
        }
        
        loadAttr(component1: (notif.sender?.username)!, component2: actionStr, component3: whatStr)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showUser(sender:)))
        self.profileImage.isUserInteractionEnabled = true
        self.profileImage.addGestureRecognizer(tap)
        
     }
    
    
    func showUser(sender: UITapGestureRecognizer)
    {
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UserProfileViewController
        
        VC.otherUser = true
        VC.previous = .notification
        VC.userID = (self.notification?.sender?.uuid)!
        dropfromTop(view: (parentVC?.view)!)
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
    func loadAttr(component1:String,component2:String,component3:String){
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string:component1 + " ")
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 122/255, green: 201/255, blue: 1/255, alpha: 1), range: NSMakeRange(0,  component1.characters.count))
        
        let descString: NSMutableAttributedString = NSMutableAttributedString(string: component2 + " ")
        descString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, component2.characters.count))
        
        let descString2: NSMutableAttributedString = NSMutableAttributedString(string: component3)
        descString2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1), range: NSMakeRange(0, component3.characters.count))
        
        attrString.append(descString);
        attrString.append(descString2);
        
        self.usernameLabel.attributedText = attrString
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
            returnString = String(Int(days)) + "d ago"
            
        }else if Int(hours) >= 1
        {
            returnString = String(Int(hours)) + "h ago"
            
        }else if Int(minutes) >= 1
        {
            returnString = String(Int(minutes)) + "m ago"
            
        }else if seconds < 60
        {
            returnString = "s ago"
        }
        
        return returnString
    }

    
    
    
    
    
    
    
}
