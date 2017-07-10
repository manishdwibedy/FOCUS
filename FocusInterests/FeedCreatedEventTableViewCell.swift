//
//  FeedCreatedEventTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedCreatedEventTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var usernameImage: UIImageView!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var eventNameLabel: UIButton!
    @IBOutlet weak var searchEventTableView: UITableView!
    @IBOutlet weak var interestLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.usernameImage.roundedImage()
        self.usernameLabel.setTitle("arya", for: .normal)
        self.eventNameLabel.setTitle("Event A", for: .normal)
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
        
        cell.address.text = "2656 Ellendale Pl Los Angeles"
        cell.name.text = "Event A"
        cell.distance.text = "4.6 mi"
        self.distanceLabel.text = cell.distance.text
        cell.interest.textColor = UIColor.white
        cell.interest.text = "5 attendees"
        cell.guestCount.isHidden = true
        addGreenDot(label: self.interestLabel, content: "Meet up")
        cell.price.text = "Free"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
