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
    
    
    @IBOutlet weak var contentBackView: UIView!
   
    
    
    var selectedButton = false
    var notif: FocusNotification!
    var parentVC: NotificationFeedViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTaped))
        self.addGestureRecognizer(tap)
        
        self.contentView.backgroundColor = Constants.color.navy
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(notif: FocusNotification) {
        self.roundButtonsAndPictures()
        
//        self.userProfilePic.image = notif.sender?.username
        let content = (notif.sender?.username)! + " "//! + " " + (notif.type?.rawValue)! + " " + (notif.item?.itemName!)!
        
        
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: (notif.sender?.username)! + " ")
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 122/255, green: 201/255, blue: 1/255, alpha: 1), range: NSMakeRange(0,  (notif.sender?.username?.characters.count)!))
        
        let descString: NSMutableAttributedString = NSMutableAttributedString(string: (notif.type?.rawValue)! + " ")
        descString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, (notif.type?.rawValue.characters.count)!))
        
        let descString2: NSMutableAttributedString = NSMutableAttributedString(string: (notif.item?.itemName!)!)
        descString2.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1), range: NSMakeRange(0, (notif.item?.itemName?.characters.count)!))
        
        attrString.append(descString);
        attrString.append(descString2);
        
        
        
        self.userNameLabel.attributedText = attrString

        
        
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
        self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.width/2
        self.userProfilePic.clipsToBounds = true
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
        
        //go to profile here
        print("inside pic")
        
    }
    
    

    @IBAction func profilePicOutsideTouch(_ sender: Any) {
         print("outsidepic")
        
        
    }
    
    func screenTaped()
    {
        print("screen taped")
        if notif.item?.type == "event"{
            
            Constants.DB.event.child((notif.item?.id)!).observeSingleEvent(of: .value, with: { (snapshot) in
                let info = snapshot.value as? [String : Any] ?? [:]
                
                let event = Event(title: (info["title"])! as! String, description: (info["description"])! as! String, fullAddress: (info["fullAddress"])! as? String, shortAddress: (info["shortAddress"])! as? String, latitude: (info["latitude"])! as! String, longitude: (info["longitude"])! as! String, date: (info["date"])! as! String, creator: (info["creator"])! as! String, id: (self.notif.item?.id)!, category: info["interest"] as? String)
                
                if let attending = info["attendingList"] as? [String:Any]{
                    event.setAttendessCount(count: attending.count)
                }
                
                let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
                controller.event = event
                self.parentVC.present(controller, animated: true, completion: nil)
                
                
                
            })
            
            
        }else if notif.item?.type == "place"{
            print("getting data")
            print((notif.item?.id)!)
            getYelpByID(ID:(notif.item?.id)!,completion: {Place in
                
                let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
                controller.place = Place
                self.parentVC.present(controller, animated: true, completion: nil)
                  
            })
            

    }
}

}
    
    
    

    
    
    













