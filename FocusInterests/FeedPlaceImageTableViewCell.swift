//
//  FeedPlaceImageTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedPlaceImageTableViewCell: UITableViewCell, UITextViewDelegate{

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var globeButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var pinCaptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UIButton!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var usernameImage: UIButton!
    @IBOutlet weak var imagePlace: UIImageView!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var commentPostView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    
    var parentVC: SearchEventsViewController? = nil
    var pin: [String:Any]? = nil
    var delegate: showMarkerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.commentTextView.delegate = self
        self.commentTextView.textContainer.maximumNumberOfLines = 0
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor.white.cgColor
        self.commentTextView.layer.cornerRadius = 5.0
        self.commentPostView.isHidden = true
    
        self.postButton.allCornersRounded(radius: 4.0)
        let placeholderAttributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!
        ]
        let placeholderTextAttributes: NSAttributedString = NSAttributedString(string: "Add a comment", attributes: placeholderAttributes)
        self.commentTextView.attributedText = placeholderTextAttributes
        
        self.usernameImage.roundButton()
        self.likeButton.setImage(#imageLiteral(resourceName: "Liked"), for: .selected)
        self.likeButton.setImage(#imageLiteral(resourceName: "Like"), for: .normal)
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
        
        
        
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.commentPostView.isHidden = true
        }
        self.endEditing(true)
    }
    
    @IBAction func commentButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.commentPostView.isHidden = !self.commentPostView.isHidden
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        self.likeButton.isSelected = !self.likeButton.isSelected
    }
    
    @IBAction func goBackToMap(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
        vc.willShowPin = true
        
        let pinInfo = pinData(UID: self.pin!["fromUID"] as! String, dateTS: self.pin!["time"] as! Double, pin: self.pin!["pin"] as! String, location: self.pin!["formattedAddress"] as! String, lat: self.pin!["lat"] as! Double, lng: self.pin!["lng"] as! Double, path: Constants.DB.pins.child(self.pin!["fromUID"] as! String), focus: self.pin!["focus"] as? String ?? "")
        delegate?.showPinMarker(pin: pinInfo, show: false)
        
        vc.selectedIndex = 0
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        print("post button pressed")
    }
    
    @IBAction func showUserProfile(){
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = pin?["fromUID"] as! String
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
}
