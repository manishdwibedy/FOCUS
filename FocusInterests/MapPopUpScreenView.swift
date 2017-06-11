//
//  MapPopUpScreenView.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class MapPopUpScreenView: UIView {

    @IBOutlet weak var backImage: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var startImage: UIImageView!
    
    @IBOutlet weak var boldLabel: UILabel!
    
    @IBOutlet weak var mileLabel: UILabel!
    
    @IBOutlet weak var interestLabel: UILabel!
    
    @IBOutlet weak var bottomText: UILabel!
    
    func loadEvent(name:String, date: String, miles: String, interest: UILabel)
    {
        self.startImage.isHidden = true
        boldLabel.text = name
        bottomText.text = date
        mileLabel.text = miles
        interestLabel.text = interest.attributedText?.string
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.layer.borderColor = UIColor(red: 254/255, green: 55/255, blue: 103/255, alpha: 1).cgColor
        self.profileImage.layer.borderWidth = 1
        self.profileImage.clipsToBounds = true

        self.layer.borderColor = UIColor(red: 254/255, green: 55/255, blue: 103/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
    }
    
    
    func loadPlace(name: String, rating: String, reviews: String, miles: String, interest: UILabel)
    {
        self.startImage.isHidden = false
        boldLabel.text = name
        bottomText.text = rating + "   " + reviews
        mileLabel.text = miles
        interest.text = interest.attributedText?.string
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.layer.borderColor = UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1).cgColor
        self.profileImage.layer.borderWidth = 1
        self.profileImage.clipsToBounds = true
        
        self.layer.borderColor = UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
    }
    
    func loadPin(name: String, pin: String, distance: String)
    {
        
        self.startImage.isHidden = true
        boldLabel.text = name
        bottomText.text = pin
        mileLabel.text = distance
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.layer.borderColor = UIColor(red: 125/255, green: 201/255, blue: 49/255, alpha: 1).cgColor
        self.profileImage.layer.borderWidth = 1
        self.profileImage.clipsToBounds = true
        
        self.layer.borderColor = UIColor(red: 125/255, green: 201/255, blue: 49/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
    }
}
