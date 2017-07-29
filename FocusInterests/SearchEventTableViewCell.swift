//
//  SearchEventTableViewCell.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Crashlytics

class SearchEventTableViewCell: UITableViewCell {

    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
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
    var event: Event? = nil
    var parentVC: SearchEventsViewController? = nil
    
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

        self.attendButton.layer.cornerRadius = 6
        self.attendButton.clipsToBounds = true
        self.attendButton.roundCorners(radius: 5)
        self.attendButton.layer.shadowOpacity = 0.5
        self.attendButton.layer.masksToBounds = false
        self.attendButton.layer.shadowColor = UIColor.black.cgColor
        self.attendButton.layer.shadowRadius = 5.0
        
        self.attendButton.setTitle("Attend", for: .normal)
        self.attendButton.setTitleColor(UIColor.white, for: .normal)
        self.attendButton.setTitle("Attending", for: .selected)
        self.attendButton.setTitleColor(Constants.color.navy, for: .selected)
        
        self.cellContentView.allCornersRounded(radius: 10.0)
        
//        Constants.DB.event.child((event?.id)!).child("attendingList").observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? [String:[String:String]]
//            if let value = value
//            {
//                for (_, guest) in value{
//                    print(guest)
//                    if guest["UID"] == AuthApi.getFirebaseUid()!{
//                        self.attendButton.isSelected = true
//                        self.attendButton.layer.borderWidth = 1
//                        self.attendButton.layer.borderColor = UIColor.white.cgColor
//                        self.attendButton.backgroundColor = UIColor(red: 25/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
//                    }
//                }
//                
//            }
//            
//        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cellContentView.setNeedsLayout()
        self.cellContentView.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: self.cellContentView.bounds, cornerRadius: 10)
        
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.cellContentView.layer.mask = mask

        self.attendButton.isSelected = false
        
        Constants.DB.event.child((event?.id)!).child("attendingList").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:[String:String]]
            if let value = value
            {
                for (_, guest) in value{
                    print(guest)
                    if guest["UID"] == AuthApi.getFirebaseUid()!{
                        self.attendButton.isSelected = true
                        self.attendButton.layer.cornerRadius = 6
                        self.attendButton.layer.borderWidth = 1
                        self.attendButton.layer.borderColor = Constants.color.navy.cgColor
                        self.attendButton.layer.shadowOpacity = 0.5
                        self.attendButton.layer.masksToBounds = false
                        self.attendButton.layer.shadowColor = UIColor.black.cgColor
                        self.attendButton.layer.shadowRadius = 5.0
                        
                        self.attendButton.clipsToBounds = true
                        self.attendButton.roundCorners(radius: 5)
                        self.attendButton.backgroundColor = UIColor.white
                        self.attendButton.tintColor = UIColor.clear
                    }
                }
                
            }
            
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func attendClicked(_ sender: Any) {
        
        if !self.attendButton.isSelected{
            self.attendButton.isSelected = true
            let newAmount = (event?.attendeeCount)! + 1
            
            let fullRef = Constants.DB.event.child((event?.id)!)
            let entry = ["UID":AuthApi.getFirebaseUid()!]
            let newEntry = fullRef.child("attendingList").childByAutoId()
            newEntry.updateChildValues(entry)
            fullRef.child("attendingAmount").updateChildValues(["amount":newAmount])
            
            
            let guestText = "\(newAmount) attendees"
            let attributeText = NSAttributedString(string: guestText, attributes: [NSForegroundColorAttributeName : UIColor.white])
            
            self.attendButton.layer.cornerRadius = 6
            self.attendButton.layer.borderWidth = 1
            self.attendButton.layer.borderColor = Constants.color.navy.cgColor
            self.attendButton.layer.shadowOpacity = 0.5
            self.attendButton.layer.masksToBounds = false
            self.attendButton.layer.shadowColor = UIColor.black.cgColor
            self.attendButton.layer.shadowRadius = 5.0
            
            self.attendButton.clipsToBounds = true
            self.attendButton.roundCorners(radius: 5)
            self.attendButton.backgroundColor = UIColor.white
            self.attendButton.tintColor = UIColor.clear
        }else{
            
            let alertController = UIAlertController(title: "Unattend \(event!.title!)?", message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Unattend", style: .destructive) { action in
                Constants.DB.event.child((self.event?.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? [String:Any]{
                        
                        for (id,_) in value{
                            Constants.DB.event.child("\(self.event?.id!)/attendingList/\(id)").removeValue()
                        }
                    }
                    
                    
                })
                
                Constants.DB.event.child((self.event?.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil
                    {
                        let attendingAmount = value?["amount"] as! Int
                        Constants.DB.event.child((self.event?.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount - 1])
                    }
                })
                
                self.attendButton.isSelected = false
                
                self.attendButton.layer.cornerRadius = 6
                self.attendButton.layer.borderWidth = 1
                self.attendButton.layer.borderColor = UIColor.clear.cgColor
                self.attendButton.layer.shadowOpacity = 0.5
                self.attendButton.layer.masksToBounds = false
                self.attendButton.layer.shadowColor = UIColor.black.cgColor
                self.attendButton.layer.shadowRadius = 5.0
                
                self.attendButton.roundCorners(radius: 5)
                self.attendButton.clipsToBounds = true
                self.attendButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
                self.attendButton.tintColor = UIColor.clear
                
                Answers.logCustomEvent(withName: "Attend Event",
                                       customAttributes: [
                                        "user": AuthApi.getFirebaseUid()!,
                                        "event": self.event?.title,
                                        "attend": false
                    ])
            }
            alertController.addAction(OKAction)
            parentVC?.present(alertController, animated: true)
            
            
        }
    }
    
}
