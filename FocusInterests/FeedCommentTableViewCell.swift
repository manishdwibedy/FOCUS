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
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var usernameReceivingCommentLabel: UIButton!
    @IBOutlet weak var usernameWhoCommentedLabel: UIButton!
    @IBOutlet weak var eventNameLabel: UIButton!
    @IBOutlet weak var timeSince: UILabel!
    
    var pin: [String:Any]? = nil
    var parentVC: SearchEventsViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.eventImage.roundedImage()
        self.usernameImage.roundedImage()
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
    
    override func layoutSubviews() {
        let userTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserProfile(sender:)))
        usernameImage.isUserInteractionEnabled = true
        userTap.numberOfTapsRequired = 1
        usernameImage.addGestureRecognizer(userTap)
        
    }
    
    func showUserProfile(sender: UITapGestureRecognizer){
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = pin?["fromUID"] as! String
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
}
