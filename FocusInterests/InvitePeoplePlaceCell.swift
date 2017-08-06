//
//  InvitePeoplePlaceCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

protocol InvitePeoplePlaceCellDelegate {
    func haveInvitedSomeoneToAPlace()
}

class InvitePeoplePlaceCell: UITableViewCell, InvitePeoplePlaceCellDelegate{

    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var inviteButtonOut: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var inviteCellContentView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var ratingsStarImage: UIImageView!
    
    var UID = ""
    var username = ""
    var isMeetup = false
    var inviteFromOtherUserProfile = false
    var place: Place!
    var invitePeopleVCDelegate: InvitePeopleViewControllerDelegate!
    var parentVC: InvitePeopleViewController!
    var otherUser: OtherUserProfileViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.inviteButtonOut.layer.cornerRadius = 6
        self.inviteButtonOut.clipsToBounds = true
        self.inviteButtonOut.roundCorners(radius: 5)
        self.inviteButtonOut.layer.shadowOpacity = 0.5
        self.inviteButtonOut.layer.masksToBounds = false
        self.inviteButtonOut.layer.shadowColor = UIColor.black.cgColor
        self.inviteButtonOut.layer.shadowRadius = 5.0
        
        self.followButton.layer.cornerRadius = 6
        self.followButton.clipsToBounds = true
        self.followButton.roundCorners(radius: 5)
        self.followButton.layer.shadowOpacity = 0.5
        self.followButton.layer.masksToBounds = false
        self.followButton.layer.shadowColor = UIColor.black.cgColor
        self.followButton.layer.shadowRadius = 5.0
        
        self.followButton.setTitle("Follow", for: UIControlState.normal)
        self.followButton.setTitleColor(UIColor.white, for: .normal)
        self.followButton.setTitle("Following", for: UIControlState.selected)
        self.followButton.setTitleColor(Constants.color.navy, for: .selected)
        
        self.placeImage.roundedImage()
        self.placeImage.layer.borderWidth = 2
        self.placeImage.layer.borderColor = UIColor(red: 72/255.0, green: 255/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        self.inviteCellContentView.allCornersRounded(radius: 6.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        inviteCellContentView.addGestureRecognizer(tap)
        
        addressTextView.textContainerInset = UIEdgeInsets.zero
        //        let longP = UILongPressGestureRecognizer(target: self, action: #selector(longP(sender:)))
        //        longP.minimumPressDuration = 0.3
        //        self.addGestureRecognizer(longP)
    }
    
    override func layoutSubviews() {
        self.inviteCellContentView.setNeedsLayout()
        
        self.inviteCellContentView.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: self.inviteCellContentView.bounds, cornerRadius: 10)
        
        let mask = CAShapeLayer()
        let shortbackgroundMask = CAShapeLayer()
        
        mask.path = path.cgPath
        
        self.inviteCellContentView.layer.mask = mask
    }
    
    func tap(sender: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
        
        if parentVC != nil{
            controller.map = parentVC.tabBarController?.viewControllers?[0] as? MapViewController
        }
        
        controller.place = place as! Place
        
        if let VC = parentVC{
            VC.present(controller, animated: true, completion: nil)
        }
        else if let VC = otherUser{
            VC.present(controller, animated: true, completion: nil)
        }
    }
    

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        //super.setSelected(selected, animated: animated)
//    }
//    
    
    @IBAction func followButtonPressed(_ sender: Any) {
        
        if self.followButton.isSelected == false{
            
            //            unfollow button appearance
            self.followButton.isSelected = true
            self.followButton.layer.borderWidth = 1
            self.followButton.layer.borderColor = Constants.color.navy.cgColor
            self.followButton.backgroundColor = UIColor.white
            self.followButton.tintColor = UIColor.clear
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.masksToBounds = false
            self.followButton.layer.shadowColor = UIColor.black.cgColor
            self.followButton.layer.shadowRadius = 5.0
            
            let time = NSDate().timeIntervalSince1970
            Follow.followPlace(id: (place?.id)!)
            
            
        } else if self.followButton.isSelected == true {
            
            
            let unfollowAlertController = UIAlertController(title: "Are you sure you want to unfollow \(self.place!.name)?", message: nil, preferredStyle: .actionSheet)
            
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                
                //            follow button appearance
                self.followButton.isSelected = false
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = UIColor.clear.cgColor
                self.followButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
                self.followButton.tintColor = UIColor.clear
                self.followButton.layer.shadowOpacity = 0.5
                self.followButton.layer.masksToBounds = false
                self.followButton.layer.shadowColor = UIColor.black.cgColor
                self.followButton.layer.shadowRadius = 5.0
                
                Follow.unFollowPlace(id: (self.place?.id)!)
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            
            if let VC = parentVC{
                VC.present(unfollowAlertController, animated: true, completion: nil)
            }
            else if let VC = otherUser{
                VC.present(unfollowAlertController, animated: true, completion: nil)
            }
        }
        /*
        self.followButton.isSelected = !self.followButton.isSelected
        if self.followButton.isSelected == true{
            self.followButton.layer.borderWidth = 1
            self.followButton.layer.borderColor = UIColor.white.cgColor
            self.followButton.backgroundColor = UIColor(red: 25/255.0, green: 54/255.0, blue: 81/255.0, alpha: 1.0)
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.masksToBounds = false
            self.followButton.layer.shadowColor = UIColor.black.cgColor
            self.followButton.layer.shadowRadius = 5.0
        }else if self.followButton.isSelected == false {
            self.followButton.layer.borderWidth = 0.0
            self.followButton.backgroundColor = Constants.color.navy
            self.followButton.layer.shadowOpacity = 0.5
            self.followButton.layer.masksToBounds = false
            self.followButton.layer.shadowColor = UIColor.black.cgColor
            self.followButton.layer.shadowRadius = 5.0
            
        }
 */
    }
    
    @IBAction func invite(_ sender: Any) {
        print("sending invite")
        if isMeetup{
            self.parentVC.performSegue(withIdentifier: "unwindBackToSearchPeopleViewControllerSegueWithSegue", sender: self.parentVC)
        }else if inviteFromOtherUserProfile{
            self.otherUser.otherUserProfileDelegate?.hasSentUserAnInvite()
            self.otherUser.dismiss(animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Invites", bundle: nil)
            let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
            ivc.type = "place"
            ivc.id = self.place.id
            ivc.place = place
            ivc.username = self.username
            ivc.searchPeoplePlaceDelegate = self
//            ivc.needToGoBackToSearchPeopleViewController = self.needToGoBackToSearchPeopleViewController
            if let VC = self.parentVC{
                VC.present(ivc, animated: true, completion: nil)
            }
        }
    }
    
    func haveInvitedSomeoneToAPlace() {
        print("going back to invitepeoplevc")
        self.invitePeopleVCDelegate.showPopupView()
    }
    
    func checkForFollow(){
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").queryOrdered(byChild: "placeID").queryEqual(toValue: place!.id).observeSingleEvent(of: .value, with: {snapshot in
            
            if let data = snapshot.value as? [String:Any]{
                self.followButton.isSelected = true
                self.followButton.layer.borderWidth = 1
                self.followButton.layer.borderColor = Constants.color.navy.cgColor
                self.followButton.backgroundColor = UIColor.white
                self.followButton.tintColor = UIColor.clear
                self.followButton.layer.shadowOpacity = 0.5
                self.followButton.layer.masksToBounds = false
                self.followButton.layer.shadowColor = UIColor.black.cgColor
                self.followButton.layer.shadowRadius = 5.0
            }
            else{
                self.followButton.isSelected = false
                self.followButton.layer.borderColor = UIColor.clear.cgColor
                self.followButton.layer.borderWidth = 1
                self.followButton.backgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
                self.followButton.tintColor = UIColor.clear
                self.followButton.layer.shadowOpacity = 0.5
                self.followButton.layer.masksToBounds = false
                self.followButton.layer.shadowColor = UIColor.black.cgColor
                self.followButton.layer.shadowRadius = 5.0
            }
        })
    }
    
    func setRatingAmount(ratingAmount: Double){
        
        switch ratingAmount{
        case 0.0...0.9:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_0")
        case 1.0...1.4:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_1")
        case 1.5...1.9:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_1_half")
        case 2.0...2.4:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_2")
        case 2.5...2.9:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_2_half")
        case 3.0...3.4:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_3")
        case 3.5...3.9:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_3_half")
        case 4.0...4.4:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_4")
        case 4.5...4.9:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_4_half")
        case 5.0:
            ratingsStarImage.image = #imageLiteral(resourceName: "small_5")
        default:
            break
        }
    }
}
