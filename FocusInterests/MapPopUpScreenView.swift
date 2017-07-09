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
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var startImage: UIImageView!
    
    @IBOutlet weak var boldLabel: UILabel!
    
    @IBOutlet weak var mileLabel: UILabel!
    
    @IBOutlet weak var interestLabel: UILabel!
    
    @IBOutlet weak var bottomText: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var captionLeading: NSLayoutConstraint!
    @IBOutlet weak var hoursLabel: UILabel!
    
    @IBOutlet weak var inviteButton: UIButton!
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
        
        inviteButton.roundCorners(radius: 5)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        self.view.addGestureRecognizer(tap)
        
    }
    func loadEvent(name:String, date: String, miles: String, interest: String, address: String)
    {
        self.startImage.isHidden = true
        boldLabel.text = name
        bottomText.text = date
        mileLabel.text = miles
        if interest.components(separatedBy: ";").count > 1{
            addGreenDot(label: interestLabel, content: interest.components(separatedBy: ";")[0])
        }
        else{
            addGreenDot(label: interestLabel, content: interest)
        }
        
        addressLabel.text = address
        
        captionLeading.constant = -25
        
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
    
    
    func loadPlace(name: String, rating: String, reviews: String, miles: String, interest: String, address:String, is_closed: Bool)
    {
        self.startImage.isHidden = false
        boldLabel.text = name
        
        bottomText.text = rating + "   " + reviews
        mileLabel.text = miles
        
        addGreenDot(label: interestLabel, content: interest)
        addressLabel.text = address
        
        captionLeading.constant = 8
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.profileImage.layer.borderColor = UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1).cgColor
        self.profileImage.layer.borderWidth = 1
        self.profileImage.clipsToBounds = true
        self.profileImage.isHidden = false
        
        if is_closed{
            self.hoursLabel.text = "Closed"
        }
        else{
            self.hoursLabel.text = "Open"
        }
        self.layer.borderColor = UIColor(red: 36/255, green: 209/255, blue: 219/255, alpha: 1).cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        
        self.type = "place"
        
    }
    
    func loadPin(name: String, pin: String, distance: String, focus: String, address: String, time: Double)
    {
        
        self.startImage.isHidden = true
        boldLabel.text = name
        bottomText.text = pin
        addressLabel.text = address
        mileLabel.text = distance
        
        addGreenDot(label: interestLabel, content: focus)
        
        captionLeading.constant = -20
        self.profileImage.image = #imageLiteral(resourceName: "placeholder_pin")
        if let data = object as? pinData{
            print(data)
            
            data.dbPath.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    
                    if value?["images"] != nil
                    {
                        var firstVal = ""
                        print("images")
                        print((value?["images"])!)
                        for (key,_) in (value?["images"] as! NSDictionary)
                        {
                            firstVal = key as! String
                            break
                        }
                        
                        let reference = Constants.storage.pins.child(((value?["images"] as! NSDictionary)[firstVal] as! NSDictionary)["imagePath"] as! String)
                        reference.downloadURL(completion: { (url, error) in
                            
                            if error != nil {
                                print(error?.localizedDescription ?? "")
                                return
                            }
                            
                            self.profileImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_pin"))
                            self.profileImage.setShowActivityIndicator(true)
                            self.profileImage.setIndicatorStyle(.gray)
                            
                        })
                        
                    }
                    else{
                        self.profileImage.sd_setImage(with: URL(string: AuthApi.getUserImage()!))
                    }
                }
            })
        }
        
        self.hoursLabel.text = DateFormatter().timeSince(from: Date(timeIntervalSince1970: (time)), numericDates: false, shortVersion: true)
        
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
                ivc.mapView = self.parentVC
                parentVC.present(ivc, animated: true, completion: { _ in })
                
            }
        
        }
    }
}
