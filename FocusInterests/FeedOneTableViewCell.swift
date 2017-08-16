//
//  FeedOneTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Crashlytics

class FeedOneTableViewCell: UITableViewCell, UITextViewDelegate{
    
    @IBOutlet weak var feedOneStackView: UIStackView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var commentPostView: UIView!
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var nameDescriptionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesAmountLabel: UILabel!
    @IBOutlet weak var timeAmountLabel: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentStackHeight: NSLayoutConstraint!
    
    var pin: pinData? = nil
    var parentVC: SearchEventsViewController? = nil
    var delegate: showMarkerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.commentTextView.delegate = self
        self.commentTextView.textContainer.maximumNumberOfLines = 0
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor.white.cgColor
        self.commentTextView.layer.cornerRadius = 5.0
        self.userImage.roundButton()
        
        self.postButton.allCornersRounded(radius: 5.0)
        
        let placeholderAttributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!
        ]
        let placeholderTextAttributes: NSAttributedString = NSAttributedString(string: "Add a comment", attributes: placeholderAttributes)
        
        self.commentTextView.attributedText = placeholderTextAttributes
        
        self.feedOneStackView.translatesAutoresizingMaskIntoConstraints = false
        self.commentPostView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likePin(_ sender: Any) {
        if (self.likeButton.imageView?.image?.isEqual(#imageLiteral(resourceName: "Like")))!
        {
            pin?.dbPath.child("like/num").observeSingleEvent(of: .value, with: {snapshot in
                if let num = snapshot.value as? Int{
                    self.pin?.dbPath.child("like").updateChildValues(["num": num + 1])
                    
                    Answers.logCustomEvent(withName: "Like Pin",
                                           customAttributes: [
                                            "liked": true,
                                            "user": AuthApi.getFirebaseUid()!,
                                            "likeCount": num + 1
                        ])
                }
                else{
                    self.pin?.dbPath.child("like").updateChildValues(["num": 1])
                    
                    Answers.logCustomEvent(withName: "Like Pin",
                                           customAttributes: [
                                            "liked": true,
                                            "user": AuthApi.getFirebaseUid()!,
                                            "likeCount":  1
                        ])
                }
            })
            pin?.dbPath.child("like").child("likedBy").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
            
            self.likeButton.setImage(#imageLiteral(resourceName: "Liked"), for: UIControlState.normal)
            
            
            
        }
        else{
            pin?.dbPath.child("like/num").observeSingleEvent(of: .value, with: {snapshot in
                if let num = snapshot.value as? Int{
                    self.pin?.dbPath.child("like").updateChildValues(["num": num - 1])
                    
                    Answers.logCustomEvent(withName: "Like Pin",
                                           customAttributes: [
                                            "liked": true,
                                            "user": AuthApi.getFirebaseUid()!,
                                            "likeCount": num - 1
                        ])
                }
            })
            
            pin?.dbPath.child("like").child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                if let value = value
                {
                    for (id, _) in value{
                        self.pin?.dbPath.child("like").child("likedBy").child(id).removeValue()
                    }
                    
                    
                }
            })
            
            self.likeButton.setImage(#imageLiteral(resourceName: "Like"), for: UIControlState.normal)
            
        }
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        if self.commentTextView.text == "" || self.commentTextView.text == "Add a comment"{
            self.postButton.isEnabled = false
        }else{
            self.postButton.isEnabled = true
            let time = NSDate().timeIntervalSince1970
            
            let UID = self.pin!.fromUID
            
            Constants.DB.pins.child(UID).child("comments").childByAutoId().updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "comment": commentTextView.text!, "date": Double(time)])
            
            commentTextView.resignFirstResponder()
            
            commentTextView.text = ""
            
            sendNotification(to: UID, title: "New Comment", body: "\(AuthApi.getUserName()!) commented on your Pin", actionType: "", type: "", item_id: "", item_name: "")
            
            Answers.logCustomEvent(withName: "Comment Pin",
                                   customAttributes: [
                                    "user": AuthApi.getFirebaseUid()!,
                                    "comment": commentTextView.text
                ])
        }
    }
    
    @IBAction func commentPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.commentPostView.isHidden = !self.commentPostView.isHidden
        }
    }
    
    @IBAction func goBackToMap(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
        vc.willShowPin = true
        
        vc.location = CLLocation(latitude: (pin?.coordinates.latitude)!, longitude: (pin?.coordinates.longitude)!)
        vc.selectedIndex = 0
        vc.showPin = pin
        AuthApi.setShowPin(show: true)
        
        delegate?.showPinMarker(pin: pin!, show: false)
        //parentVC?.present(vc, animated: true, completion: nil)
        
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
//        vc.willShowPin = true
//        vc.showPin = pin
//
//        vc.selectedIndex = 0
//        
    }
    
    @IBAction func showUserProfile(){
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = (pin?.fromUID)!
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.commentPostView.isHidden = true
        }
        self.endEditing(true)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
}
