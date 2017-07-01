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
    @IBOutlet weak var likeOut: UIButton!
    @IBOutlet weak var commentOut: UIButton!
    @IBOutlet weak var sendOut: UIButton!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var pinMessageLabel: UILabel!
    @IBOutlet weak var moreOut: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var commentsStackView: UIStackView!
    @IBOutlet weak var commentHeight: NSLayoutConstraint!
    var data: pinData!
    var dictData = NSDictionary()
    var likes = 0
    var mapView: MapViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        profileImage.roundedImage()
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let imageAttachment = NSTextAttachment()
        
        imageAttachment.image = UIImage(image: UIImage(named: "Green.png"), scaledTo: CGSize(width: 12.0, height: 12.0))
        
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let primaryFocus = NSMutableAttributedString(string: "")
        primaryFocus.append(attachmentString)
        primaryFocus.append(NSMutableAttributedString(string: " \(data.focus) "))
        interestsLabel.attributedText = primaryFocus
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubletap(sender:)))
        doubleTap.numberOfTapsRequired = 2
        self.viewForMap.addGestureRecognizer(doubleTap)
        
        Constants.DB.user.child(data.fromUID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                let username = value?["username"] as! String
                self.usernameLabel.text = username
                
                
                let messageText = "\(String(describing: username)) \(self.data.pinMessage)"
                
                let length = messageText.characters.count - username.characters.count
                let range = NSMakeRange(username.characters.count, length)

                self.pinMessageLabel.attributedText = attributedString(from: messageText, boldRange: range)


            }
        })
        
        addressTopOut.setTitle(data.locationAddress.replacingOccurrences(of: ";;", with: "\n", options: .literal, range: nil), for: UIControlState.normal)
        
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: data.dateTimeStamp)
        dateLabel.text = formatter.timeSince(from: date, numericDates: false, shortVersion: true)
        
        //check for images
        data.dbPath.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.dictData = value!
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
                    let bigImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.viewForMap.frame.width, height: self.viewForMap.frame.height))
                    
                    bigImage.contentMode = UIViewContentMode.scaleAspectFill
                    bigImage.clipsToBounds = true
                    
                    self.viewForMap.addSubview(bigImage)
                    
                    let placeholderImage = UIImage(named: "empty_event")
                    
                    let reference = Constants.storage.pins.child(((value?["images"] as! NSDictionary)[firstVal] as! NSDictionary)["imagePath"] as! String)
                    reference.downloadURL(completion: { (url, error) in
                        
                        if error != nil {
                            print(error?.localizedDescription)
                            return
                        }
                        
                        bigImage.sd_setImage(with: url, placeholderImage: placeholderImage)
                        bigImage.setShowActivityIndicator(true)
                        bigImage.setIndicatorStyle(.gray)
                        
                    })
                    
                }else
                {
                    let camera = GMSCameraPosition.camera(withLatitude: self.data.coordinates.latitude, longitude: self.data.coordinates.longitude, zoom: 13)
                    let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.viewForMap.frame.width, height: self.viewForMap.frame.height), camera: camera)
                    mapView.delegate = self
                    
                    let position = CLLocationCoordinate2D(latitude: Double(self.data.coordinates.latitude), longitude: Double(self.data.coordinates.longitude))
                    
                    let marker = GMSMarker(position: position)
                    marker.map = mapView
                    let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
                    image.image = UIImage(named: "pin")
                    image.contentMode = .scaleAspectFit
                    marker.iconView = image
                    
                    mapView.mapType = .normal
                    self.viewForMap.addSubview(mapView)
                }
                
            }
        })
        
        
        //check for likes
        data.dbPath.child("like").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.likes = (value?["num"] as? Int)!
                
                if self.likes > 1{
                    self.likesLabel.text = String(self.likes) + " likes"
                }
                else{
                    self.likesLabel.text = String(self.likes) + " like"
                }
            }
        })
        
        data.dbPath.child("like").child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                
                self.likeOut.setImage(UIImage(named: "Liked"), for: UIControlState.normal)
            }
        })
        
        
        for view in commentsStackView.subviews{
            view.removeFromSuperview()
        }
        
        data.dbPath.child("comments").queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let value = value
            {
                if value.count > 2{
                    let textLabel = UILabel()

                    textLabel.textColor = .white
                    textLabel.font = UIFont(name: "Avenir-Book", size: 15)
                    textLabel.text  = "View \(value.count) comments"
                    textLabel.textAlignment = .left
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.showComments(sender:)))
                    textLabel.addGestureRecognizer(tap)

                    self.commentsStackView.addArrangedSubview(textLabel)
                    self.commentsStackView.translatesAutoresizingMaskIntoConstraints = false;
                }
                
                let keys = value.allKeys as? [String]
                for (index,id) in (keys?.enumerated())!{
                    if index == 3{
                        break
                        
                    }
                    let data = value[id] as? [String:Any]
                    Constants.DB.user.child(data?["fromUID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        if value != nil
                        {
                            let username = value?["username"] as! String
                            self.usernameLabel.text = username
                            
                            let textLabel = UILabel()
                            
                            textLabel.textColor = .white
                            
                            let messageText = "\(username) \(data?["comment"] as! String)"
                            
                            let length = messageText.characters.count - username.characters.count
                            let range = NSMakeRange(username.characters.count, length)
                            
                            textLabel.attributedText = attributedString(from: messageText, nonBoldRange: range)
                            textLabel.textAlignment = .left
                            
                            
                            
                            self.commentsStackView.addArrangedSubview(textLabel)
                            self.commentsStackView.translatesAutoresizingMaskIntoConstraints = false;

                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.showComments(sender:)))
                            self.commentsStackView.addGestureRecognizer(tap)

                        }
                    })
                    
                }
                
                if value.count < 3{
                    self.commentHeight.constant = CGFloat(20 * value.count)
                }
                
//                for (index, category) in (place.categories.enumerated()){
//                    let textLabel = UILabel()
//                    
//                    textLabel.textColor = .white
//                    textLabel.text  = getInterest(yelpCategory: category.alias)
//                    textLabel.textAlignment = .left
//                    
//                    
//                    commentsStackView.addArrangedSubview(textLabel)
//                    commentsStackView.translatesAutoresizingMaskIntoConstraints = false;
//                }
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
       if (self.likeOut.imageView?.image?.isEqual(UIImage(named: "Like")))!
       {
            self.likes = self.likes + 1
            data.dbPath.child("like").updateChildValues(["num": likes])
            data.dbPath.child("like").child("likedBy").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
            self.likeOut.isEnabled = false
        
            if self.likes > 1{
                self.likesLabel.text = String(self.likes) + " likes"
            }
            else{
                self.likesLabel.text = String(self.likes) + " like"
            }
        
            self.likeOut.setImage(UIImage(named: "Liked"), for: UIControlState.normal)
        }
       else{
        self.likes = self.likes - 1
        data.dbPath.child("like").updateChildValues(["num": likes])
        
        data.dbPath.child("like").child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
//                data.dbPath.child("like").child("likedBy").
                print(value)
            }
        })
        
//        data.dbPath.child("like").child("likedBy").rem
        self.likeOut.isEnabled = false
        
        if self.likes > 1{
            self.likesLabel.text = String(self.likes) + " likes"
        }
        else{
            self.likesLabel.text = String(self.likes) + " like"
        }
        self.likeOut.setImage(UIImage(named: "Liked"), for: UIControlState.normal)
        }
       
    }
    
    func didDoubletap(sender:UITapGestureRecognizer)
    {
        if self.likeOut.isEnabled == true
        {
            self.likes = self.likes + 1
            data.dbPath.child("like").updateChildValues(["num": likes])
            data.dbPath.child("like").child("likedBy").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
            self.likeOut.isEnabled = false
            self.likesLabel.text = String(self.likes) + " likes"
            self.likeOut.setImage(UIImage(named: "Liked"), for: UIControlState.normal)
        }
        
    }
    
    @IBAction func comment(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Comments", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "comments") as! CommentsViewController
        ivc.data = dictData
        self.present(ivc, animated: true, completion: { _ in })
        
    }
    
    @IBAction func send(_ sender: Any) {
    }
    
    @IBAction func more(_ sender: Any) {
    }
    

    @IBAction func back(_ sender: Any) {
        mapView!.showPin = true
        mapView!.currentLocation = CLLocation(latitude: self.data.coordinates.latitude, longitude: self.data.coordinates.longitude)
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func showComments(sender:UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Comments", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "comments") as! CommentsViewController
        ivc.data = dictData
        self.present(ivc, animated: true, completion: { _ in })
        
    }
    

    

}

