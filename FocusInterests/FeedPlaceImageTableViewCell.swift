//
//  FeedPlaceImageTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedPlaceImageTableViewCell: UITableViewCell {

    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var pinCaptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UIButton!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var imagePlace: UIImageView!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeSince: UILabel!
    
    var parentVC: SearchEventsViewController? = nil
    var pin: [String:Any]? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.usernameLabel.setTitle("arya", for: .normal)
        self.addressLabel.setTitle("1001 Rose Bowl Dr", for: .normal)
        self.distanceLabel.text = "10 mi"
        self.pinCaptionLabel.text = "Rose Bowl"
        addGreenDot(label: self.interestLabel, content: "Sports")
        self.usernameImage.roundedImage()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cellContentView.setNeedsLayout()
        
        self.cellContentView.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: self.cellContentView.bounds, cornerRadius: 10)
        
        let mask = CAShapeLayer()
        let shortbackgroundMask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.cellContentView.layer.mask = mask
        
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
