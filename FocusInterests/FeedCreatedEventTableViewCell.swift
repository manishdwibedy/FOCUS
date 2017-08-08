//
//  FeedCreatedEventTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage

class FeedCreatedEventTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var usernameImage: UIButton!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var eventNameLabel: UIButton!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var searchEventTableView: UITableView!
    @IBOutlet weak var searchEventTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var globeButton: UIButton!
    
    var event: Event? = nil
    var parentVC: SearchEventsViewController? = nil
    
    @IBOutlet weak var actionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.usernameImage.roundButton()
        
        self.mainStack.translatesAutoresizingMaskIntoConstraints = false
        self.searchEventTableView.delegate = self
        self.searchEventTableView.dataSource = self
        self.searchEventTableView.separatorStyle = .none
        self.searchEventTableView.register(UINib(nibName: "SearchEventTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.searchEventTableView.rowHeight = UITableViewAutomaticDimension
        self.searchEventTableView.estimatedRowHeight = 90.0
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func showUserProfile(){
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = (event?.creator)!
        
        parentVC?.present(VC, animated:true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchEventTableViewCell
        
        cell.event = event
        cell.parentVC = parentVC
        
        cell.attendButton.roundCorners(radius: 5.0)
        cell.attendButton.layer.shadowOpacity = 0.5
        cell.attendButton.layer.masksToBounds = false
        cell.attendButton.layer.shadowColor = UIColor.black.cgColor
        cell.attendButton.layer.shadowRadius = 5.0
        
        cell.inviteButton.roundCorners(radius: 5.0)
        cell.inviteButton.layer.shadowOpacity = 0.5
        cell.inviteButton.layer.masksToBounds = false
        cell.inviteButton.layer.shadowColor = UIColor.black.cgColor
        cell.inviteButton.layer.shadowRadius = 5.0
        self.eventNameLabel.setTitle(event!.title, for: .normal)
        cell.dateAndTimeLabel.text = "7/20 9:00 P.M."
        cell.placeDateAndTimeStack.addArrangedSubview(cell.dateAndTimeLabel)
        cell.dateAndTimeLabel.isHidden = false
        cell.address.text = event?.shortAddress
        cell.name.text = event?.title
        cell.distance.text = "4.6 mi"
        self.distanceLabel.text = cell.distance.text
        cell.interest.text = "\(event!.attendeeCount) attendees"
        cell.guestCount.isHidden = true
        if let pinFocus = event?.category{
            if pinFocus.characters.first == "●"{
                let startIndex = pinFocus.index(pinFocus.startIndex, offsetBy: 2)
                let interestStringWithoutDot = pinFocus.substring(from: startIndex)
                addGreenDot(label: self.interestLabel, content: interestStringWithoutDot)
            }else{
                addGreenDot(label: self.interestLabel, content: pinFocus)
            }
        }else{
            addGreenDot(label: self.interestLabel, content: "N.A.")
        }
//        addGreenDot(label: self.interestLabel, content: (event?.category)!)
        cell.price.text = event?.price == 0 ? "Free" : "$\(event?.price)"
        
        cell.inviteButton.addTarget(self, action: #selector(self.goToInvitePage), for: .touchUpInside)
        
        let eventLocation = CLLocation(latitude: Double((event?.latitude!)!)!, longitude: Double((event?.longitude!)!)!)
        
        distanceLabel.text = getDistance(fromLocation: AuthApi.getLocation()!, toLocation: eventLocation,addBracket: false)
        
        let reference = Constants.storage.event.child("\(event!.id!).jpg")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            
            SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                (receivedSize :Int, ExpectedSize :Int) in
                
            }, completed: {
                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                
                if image != nil && finished{
                    cell.eventImage.image = crop(image: image!, width: 50, height: 50)
                    var tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToEventDetail))
                    tapGesture.numberOfTapsRequired = 1
                    cell.eventImage.addGestureRecognizer(tapGesture)
                }
            })
            
            
        })
        self.searchEventTableViewHeightConstraint.constant = cell.contentView.frame.size.height
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(self.searchEventTableView.visibleCells)
        if let cell = self.searchEventTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SearchEventTableViewCell{
            return cell.frame.height
        }
        return 100
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("did select event detail cell")
//        print("\(tableView.cellForRow(at: indexPath)?)")
//        let inviteVC = UIStoryboard(name: "eventDetailVC", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
//        
//        parentVC?.present(inviteVC, animated: true, completion: nil)
//    }

    func goToEventDetail(){
        let inviteVC = UIStoryboard(name: "eventDetailVC", bundle: nil).instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController

        parentVC?.present(inviteVC, animated: true, completion: nil)
    }
    
    func goToInvitePage(){
        let inviteVC = UIStoryboard(name: "Invites", bundle: nil).instantiateViewController(withIdentifier: "NewInviteViewController") as! NewInviteViewController
        inviteVC.type = "event"
        
        parentVC?.present(inviteVC, animated: true, completion: nil)
    }
    
    @IBAction func goBackToMap(_ sender: Any){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
        vc.willShowPin = true
        //        vc.showPin = pin
        //        vc.location = CLLocation(latitude: pinData.coordinates.la, longitude: coordinates.longitude)
        vc.selectedIndex = 0
    }
}
