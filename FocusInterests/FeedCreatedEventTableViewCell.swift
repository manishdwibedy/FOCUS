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
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var eventNameLabel: UIButton!
    @IBOutlet weak var searchEventTableView: UITableView!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    
    var event: Event? = nil
    var parentVC: SearchEventsViewController? = nil
    
    @IBOutlet weak var actionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.usernameImage.roundedImage()
        
        
        self.searchEventTableView.delegate = self
        self.searchEventTableView.dataSource = self
        self.searchEventTableView.separatorStyle = .none
        self.searchEventTableView.register(UINib(nibName: "SearchEventTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchEventTableViewCell
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
        
        cell.textViewHeight.constant -= 22
        
        
        self.eventNameLabel.setTitle(event!.title, for: .normal)
        
        cell.address.text = event?.shortAddress
        cell.name.text = event?.title
        cell.distance.text = "4.6 mi"
        self.distanceLabel.text = cell.distance.text
        cell.interest.textColor = UIColor.white
        cell.interest.text = "\(event!.attendeeCount) attendess"
        cell.guestCount.isHidden = true
        addGreenDot(label: self.interestLabel, content: (event?.category)!)
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
                }
            })
            
            
        })

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func goToInvitePage(){
        let inviteVC = UIStoryboard(name: "Invites", bundle: nil).instantiateViewController(withIdentifier: "NewInviteViewController")
        parentVC?.present(inviteVC, animated: true, completion: nil)
    }
}
