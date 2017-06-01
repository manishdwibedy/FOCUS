//
//  PinLookViewController.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/29/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase

class PinLookViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var viewForMap: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addressTopOut: UIButton!
    @IBOutlet weak var optionsOut: UIButton!
    @IBOutlet weak var likeOut: UIButton!
    @IBOutlet weak var commentOut: UIButton!
    @IBOutlet weak var sendOut: UIButton!
    @IBOutlet weak var addressBottom: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var pinMessageLabel: UILabel!
    @IBOutlet weak var moreOut: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var data: pinData!
    var likes = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let camera = GMSCameraPosition.camera(withLatitude: data.coordinates.latitude, longitude: data.coordinates.longitude, zoom: 17)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.viewForMap.frame.width, height: self.viewForMap.frame.height), camera: camera)
        mapView.delegate = self
        mapView.mapType = .normal
        viewForMap.addSubview(mapView)
        
        let position = CLLocationCoordinate2D(latitude: data.coordinates.latitude, longitude: data.coordinates.longitude)
        let marker = GMSMarker(position: position)
        marker.title = data.pinMessage
        marker.map = mapView
        
        print(data.fromUID)
        Constants.DB.user.child(data.fromUID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                print(value)
                self.usernameLabel.text = value?["username"] as? String
                //self.pinMessageLabel.text = (value?["username"] as? String)! + " " + self.data.pinMessage
//                print(value?["username"] as? String)
//                let boldText  = (value?["username"] as? String)!
//                let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
//                let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
//
//                let normalText = " " + self.data.pinMessage
//                let normalString = NSMutableAttributedString(string:normalText)
//                attributedString.append(normalString)
//                self.pinMessageLabel.attributedText = attributedString
                
            }
        })
        
        addressTopOut.setTitle(data.locationAddress, for: UIControlState.normal)
        addressBottom.text = data.locationAddress
        pinMessageLabel.text = data.pinMessage
        
        
        //check for likes
        data.dbPath.child("like").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.likes = (value?["num"] as? Int)!
                self.likesLabel.text = String(self.likes) + " likes"
            }
        })
        
        data.dbPath.child("like").child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.likeOut.isEnabled = false
            }
        })
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func addressOut(_ sender: Any) {
    }
    
    @IBAction func options(_ sender: Any) {
    }
    
    @IBAction func like(_ sender: Any) {
       
        self.likes = self.likes + 1
        data.dbPath.child("like").updateChildValues(["num": likes])
        data.dbPath.child("like").child("likedBy").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
        self.likeOut.isEnabled = false
        self.likesLabel.text = String(self.likes) + " likes"
       
    }
    
    @IBAction func comment(_ sender: Any) {
    }
    
    @IBAction func send(_ sender: Any) {
    }
    
    @IBAction func more(_ sender: Any) {
    }
    

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}


class pinData
{
    var fromUID = String()
    var dateTimeStamp = Double()
    var pinMessage = String()
    var locationAddress = String()
    var coordinates = CLLocationCoordinate2D()
    var dbPath = DatabaseReference()
    
    
    init(UID:String, dateTS:Double, pin: String, location: String, lat: Double, lng: Double, path: DatabaseReference) {
        self.fromUID = UID
        self.dateTimeStamp = dateTS
        self.pinMessage = pin
        self.locationAddress = location
        self.coordinates.latitude = lat
        self.coordinates.longitude = lng
        self.dbPath = path
    
        
    }
}
