//
//  FeedPlaceTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedPlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameImage: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placePhoto: UIButton!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var placeBeingLiked: UIButton!
    @IBOutlet weak var usernameWhoIsBeingLiked: UIButton!
    @IBOutlet weak var usernameWhoLikedLabel: UIButton!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var globeButton: UIButton!
    
    var pin: [String:Any]? = nil
    var parentVC: SearchEventsViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.usernameImage.roundButton()
        self.placePhoto.roundButton()
        addGreenDot(label: interestLabel, content: "Food")
        self.distanceLabel.text = "50 mi"
        var pinPlace = "UCLA Pavilion"
        var pinName = "Pin: \(pinPlace)"
        
        self.placeBeingLiked.setTitle(pinName, for: .normal)
        self.usernameWhoLikedLabel.setTitle("arya", for: .normal)
        self.usernameWhoIsBeingLiked.setTitle("username's", for: .normal)
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
    
    @IBAction func showUserProfile(){
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = pin?["fromUID"] as! String
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
}
