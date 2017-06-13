//
//  MapPopUpScreenView.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class MapPopUpScreenView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet weak var backImage: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var startImage: UIImageView!
    
    @IBOutlet weak var boldLabel: UILabel!
    
    @IBOutlet weak var mileLabel: UILabel!
    
    @IBOutlet weak var interestLabel: UILabel!
    
    @IBOutlet weak var bottomText: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    var object: Any!
    var type = ""
    var parentVC: MapViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("MapPopUpScreenView", owner: self, options: nil)
        self.addSubview(self.view)
        print(self.view.frame.size)
        print(self.frame.size)
        self.view.frame.size = CGSize(width: self.frame.width, height: 195)
        self.view.layoutIfNeeded()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        self.view.addGestureRecognizer(tap)
        
    }
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
        self.profileImage.isHidden = false

        self.layer.borderColor = UIColor(red: 254/255, green: 55/255, blue: 103/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
        self.type = "event"
        
    }
    
    
    func loadPlace(name: String, rating: String, reviews: String, miles: String, interest: UILabel, address:String)
    {
        self.startImage.isHidden = false
        boldLabel.text = name
        bottomText.text = rating + "   " + reviews
        mileLabel.text = miles
        interestLabel.text = interest.attributedText?.string
        addressLabel.text = address
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.layer.borderColor = UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1).cgColor
        self.profileImage.layer.borderWidth = 1
        self.profileImage.clipsToBounds = true
        self.profileImage.isHidden = true
        
        
        self.layer.borderColor = UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
        self.type = "place"
        
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
        self.profileImage.isHidden = false
        
        self.layer.borderColor = UIColor(red: 125/255, green: 201/255, blue: 49/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
        self.type = "pin"
        
    }
    
    
    
    func tap(sender: UITapGestureRecognizer)
    {
        
        if object != nil{
            if type == "event"{
                let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
                controller.event = object as? Event
                parentVC.present(controller, animated: true, completion: nil)
                
            }else if type == "place"{
                
                let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
                controller.place = object as? Place
                parentVC.present(controller, animated: true, completion: nil)
                
            }else if type == "pin"{
                
                 let storyboard = UIStoryboard(name: "Pin", bundle: nil)
                let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
                ivc.data = object as! pinData
                parentVC.present(ivc, animated: true, completion: { _ in })
                
            }
        
    }
    
    
    
}
    
    
}
























