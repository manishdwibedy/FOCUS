//
//  FeedCommentTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var eventImage: UIButton!
    @IBOutlet weak var usernameImage: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var usernameReceivingCommentLabel: UIButton!
    @IBOutlet weak var usernameWhoCommentedLabel: UIButton!
    @IBOutlet weak var eventNameLabel: UIButton!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var commentedInfoStack: UIStackView!
    @IBOutlet weak var globeImage: UIButton!
    
    var pin: [String:Any]? = nil
    var parentVC: SearchEventsViewController? = nil
    var feed: FocusNotification? = nil
    var delegate: showMarkerDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.eventImage.roundButton()
        self.usernameImage.roundButton()
        self.usernameWhoCommentedLabel.setTitle("arya", for: .normal)
        self.usernameReceivingCommentLabel.setTitle("username's", for: .normal)
        
        var eventName = "Rose Bowl"
        var eventPin = "Event: \(eventName)"
        self.eventNameLabel.setTitle(eventPin, for: .normal)
        self.distanceLabel.text = "15 mi"
        self.commentLabel.text = "\"sum has been the industry's standard dummy\""
        addGreenDot(label: self.interestLabel, content: "Meet up")
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkLengthOfLabel(){
        if self.usernameReceivingCommentLabel.intrinsicContentSize.width > self.usernameReceivingCommentLabel.bounds.width{
            self.usernameWhoCommentedLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            self.usernameWhoCommentedLabel.titleLabel?.lineBreakMode = .byClipping
            
            self.usernameReceivingCommentLabel.titleLabel?.adjustsFontSizeToFitWidth = true
            self.usernameReceivingCommentLabel.titleLabel?.lineBreakMode = .byClipping
            
            self.commentLabel.adjustsFontSizeToFitWidth = true
            self.commentLabel.lineBreakMode = .byClipping

        }
    }
    
    @IBAction func goBackToMap(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
        vc.willShowPin = true
        
        
        let pinInfo = pinData(UID: self.pin!["fromUID"] as! String, dateTS: self.pin!["time"] as! Double, pin: self.pin!["pin"] as! String, location: self.pin!["formattedAddress"] as! String, lat: self.pin!["lat"] as! Double, lng: self.pin!["lng"] as! Double, path: Constants.DB.pins.child(self.pin!["fromUID"] as! String), focus: self.pin!["focus"] as? String ?? "")
        delegate?.showPinMarker(pin: pinInfo, show: false)
        
        vc.selectedIndex = 0
    }
    
    @IBAction func showUserProfile(){
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = pin?["fromUID"] as! String
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
    @IBAction func showDetail(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
        
        if let data = pin{
            ivc.data = pinData(UID: data["fromUID"] as! String, dateTS: data["time"] as! Double, pin: data["pin"] as! String, location: data["formattedAddress"] as! String, lat: data["lat"] as! Double, lng: data["lng"] as! Double, path: Constants.DB.pins.child(feed?.item?.data["key"] as! String), focus: data["focus"] as? String ?? "")
    
        }
        
        
        parentVC?.present(ivc, animated: true, completion: { _ in })
    }
    
}
