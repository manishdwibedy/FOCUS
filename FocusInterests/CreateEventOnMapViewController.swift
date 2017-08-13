//
//  CreateEventOnMapViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/28/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import AMPopTip
import Crashlytics
import SCLAlertView
import FBSDKLoginKit
import FirebaseAuth
import Gallery

class CreateEventOnMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, GalleryControllerDelegate, gotLocationDelegate{

    // change location stack
    @IBOutlet weak var currentLocationStack: UIStackView!
    @IBOutlet weak var searchLocationTextField: UITextField!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mainChangeLocationView: UIView!
    @IBOutlet weak var searchLocationTableView: UITableView!
    
    // add focus stack
    @IBOutlet weak var addFocusStack: UIStackView!
    @IBOutlet weak var addFocusDropdownButton: UIButton!
    @IBOutlet weak var addFocusButton: UIButton!
    @IBOutlet weak var addFocusTableView: UITableView!
    @IBOutlet weak var mainAddFocusView: UIView!
    
    // main stack
    @IBOutlet weak var mainStackView: UIView!
    @IBOutlet weak var mainStack: UIStackView!
    
    // user stack text view
    @IBOutlet weak var userStatusTextView: UITextView!
    
    // go to camera button
    @IBOutlet weak var cameraButton: UIButton!
    
    // set pin buttons
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var pinImageButton: UIButton!
    
    // side stack
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    
    let loginView = FBSDKLoginManager()
    var pinType: PinType = .normal
    var isPublic = false
    var isTwitter = false
    var isFacebook = false
    var placeEventID = ""
    var delegate: showMarkerDelegate?
    var location = AuthApi.getLocation()!
    var formmatedAddress = ""
    var selectedLocation = false
    let gallery = GalleryController()
    var galleryPicArray = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.mainStackView.layer.cornerRadius = 5.0
        self.mainAddFocusView.layer.cornerRadius = 5.0
        self.mainChangeLocationView.layer.cornerRadius = 5.0
        
        self.userStatusTextView.delegate = self
        self.userStatusTextView.tintColor = UIColor.lightGray
        
        self.addFocusTableView.delegate = self
        self.addFocusTableView.dataSource = self
        self.addFocusTableView.layer.cornerRadius = 5.0
        
        let interestCell = UINib(nibName: "SingleInterestTableViewCell", bundle: nil)
        self.addFocusTableView.register(interestCell, forCellReuseIdentifier: "singleInterestCell")
        self.addFocusStack.removeArrangedSubview(self.addFocusTableView)
        
        self.searchLocationTextField.delegate = self

        self.searchLocationTextField.attributedPlaceholder = NSAttributedString(string: "Current Location", attributes: [NSForegroundColorAttributeName: Constants.color.navy, NSFontAttributeName: UIFont(name: "Avenir Book", size: 17)!])
        
        let locationImageView = UIImageView(image: #imageLiteral(resourceName: "location").withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        locationImageView.backgroundColor = UIColor.white
        self.searchLocationTextField.leftView = locationImageView
        self.searchLocationTextField.layer.borderWidth = 0.0
        hideKeyboardWhenTappedAround()
        
        gallery.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !selectedLocation{
            getPlaceName(location: AuthApi.getLocation()!, completion: {address in
                self.formmatedAddress = address
                self.searchLocationTextField.text = address
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func currentLocationPressed(){
        
    }

    @IBAction func lockPressed(_ sender: Any) {
        if isPublic == false
        {
            isPublic = true
            lockButton.setImage(UIImage(named: "LockGreen"), for: UIControlState.normal)
            
        }else
        {
            isPublic = false
            lockButton.setImage(UIImage(named: "LockGray"), for: UIControlState.normal)
        }
        
        if AuthApi.isNewToPage(index: 5){
            let popTip = PopTip()
            popTip.show(text: "Private to your followers", direction: .left, maxWidth: 500, in: lockButton, from: lockButton.frame, duration: 3)
            popTip.entranceAnimation = .scale;
            popTip.actionAnimation = .bounce(20)
            popTip.shouldDismissOnTap = true
            AuthApi.setIsNewToPage(index: 5)
            
        }
    }
    
    @IBAction func facebookPressed(_ sender: Any) {
        if isFacebook == false
        {
            if AuthApi.getFacebookToken() == nil{
                
                loginView.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        self.showLoginFailedAlert(loginType: "Facebook")
                    } else {
                        if let res = result {
                            if res.isCancelled {
                                return
                            }
                            if let tokenString = FBSDKAccessToken.current().tokenString {
                                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                                Auth.auth().currentUser?.link(with: credential) { (user, error) in
                                    if error != nil {
                                        AuthApi.set(facebookToken: tokenString)
                                        self.isFacebook = true
                                        self.facebookButton.setImage(UIImage(named: "facebookGreen"), for: UIControlState.normal)
                                        return
                                    }
                                }
                            }
                        } else {
                            self.showLoginFailedAlert(loginType: "Facebook")
                        }
                    }
                }
            }
            else{
                self.isFacebook = true
                self.facebookButton.setImage(UIImage(named: "facebookGreen"), for: UIControlState.normal)
            }
            
        }else
        {
            isFacebook = false
            facebookButton.setImage(UIImage(named: "facebookGray"), for: UIControlState.normal)
        }
    }
    
    @IBAction func twitterPressed(_ sender: Any) {
        if isTwitter == false
        {
            if AuthApi.getTwitterToken() == nil{
                Share.loginTwitter()
            }
            isTwitter = true
            twitterButton.setImage(UIImage(named: "TwitterGreen"), for: UIControlState.normal)
        }else
        {
            isTwitter = false
            twitterButton.setImage(UIImage(named: "TwitterGray"), for: UIControlState.normal)
        }
    }
    
    @IBAction func pinPressed(_ sender: Any) {
        if addFocusButton.titleLabel?.text == "Add FOCUS"{
            SCLAlertView().showCustom("Oops!", subTitle: "Please enter your FOCUS", color: UIColor.orange, icon: #imageLiteral(resourceName: "placeholder_people"))
            return
        }
        
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).removeValue()

        let time = NSDate().timeIntervalSince1970
        if true
        {
            let imagePaths = NSMutableDictionary()
            for image in galleryPicArray
            {
                let random = Int(time) + Int(arc4random_uniform(10000000))
                let path = AuthApi.getFirebaseUid()!+"/"+String(random)
                imagePaths.addEntries(from: [String(random):["imagePath": path]])
                uploadImage(image: image, path: Constants.storage.pins.child(path))
                
            }
            
            if formmatedAddress.characters.count > 0{
                Constants.DB.pins.child(AuthApi.getFirebaseUid()!).updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": userStatusTextView.text!,"formattedAddress":self.formmatedAddress, "lat": Double(self.location.coordinate.latitude), "lng": Double(self.location.coordinate.longitude), "public": isPublic, "focus": addFocusButton.titleLabel?.text ?? ""] )
                
                Constants.DB.pin_locations!.setLocation(CLLocation(latitude: Double(self.location.coordinate.latitude), longitude: Double(self.location.coordinate.longitude)), forKey: AuthApi.getFirebaseUid()!) { (error) in
                    if (error != nil) {
                        debugPrint("An error occured: \(String(describing: error))")
                    } else {
                        print("Saved location successfully!")
                    }
                }
                
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                    let value = snapshot.value as? [String:Any]
                    
                    if let pinCount = value?["pinCount"] as? Int{
                        Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues(["pinCount": pinCount + 1])
                    }
                    else{
                        Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues(["pinCount": 1])
                    }
                })
                
                if self.pinType == .place{
                    Constants.DB.places.child("\(placeEventID)/pins").updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": userStatusTextView.text!,"formattedAddress":formmatedAddress, "lat": Double(self.location.coordinate.latitude), "lng": Double(self.location.coordinate.longitude), "public": isPublic, "focus": addFocusButton.titleLabel?.text ?? ""] )
                    
                }
                else if self.pinType == .event{
                    Constants.DB.event.child("\(placeEventID)/pins").updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": userStatusTextView.text!,"formattedAddress":formmatedAddress, "lat": Double(self.location.coordinate.latitude), "lng": Double(self.location.coordinate.longitude), "public": isPublic, "focus": addFocusButton.titleLabel?.text ?? ""] )
                }
                Answers.logCustomEvent(withName: "Pin",
                                       customAttributes: [
                                        "user": AuthApi.getFirebaseUid()!,
                                        "interest": addFocusButton.titleLabel?.text,
                                        "address": formmatedAddress,
                                        "imageSelected": false,
                                        "public": isPublic
                    ])
            }
            if isTwitter == true
            {
                Share.postToTwitter(withStatus: userStatusTextView.text!)
            }
            if isFacebook == true
            {
                try! Share.facebookShare(with: URL(string: "http://mapofyourworld.com")!, description: userStatusTextView.text!)
            }
        }
        userStatusTextView.text = "What are you up to? Type here."
        userStatusTextView.font = UIFont(name: "Avenir Book", size: 16)
        
        userStatusTextView.resignFirstResponder()
        
        isPublic = false
        isTwitter = false
        isFacebook = false
        
        
        lockButton.setImage(UIImage(named: "LockGray"), for: UIControlState.normal)
        facebookButton.setImage(UIImage(named: "facebookGray"), for: UIControlState.normal)
        twitterButton.setImage(UIImage(named: "TwitterGray"), for: UIControlState.normal)
        
//        for cell in cellArray
//        {
//            cell.imageView.layer.borderWidth = 0
//        }
        
        var caption = ""
        
        if userStatusTextView.text != "What are you up to? Type Here"{
            caption = userStatusTextView.text
        }
        
        let pin = pinData(UID: AuthApi.getFirebaseUid()!, dateTS: Date().timeIntervalSince1970, pin: caption, location: searchLocationTextField.text!, lat: (location.coordinate.latitude), lng: (location.coordinate.latitude), path: Constants.DB.pins.child(AuthApi.getFirebaseUid()!), focus: (addFocusDropdownButton.titleLabel?.text) ?? "Meet up")
        
        if self.pinType != .normal{
            dismiss(animated: true, completion: nil)
            
            delegate?.showPinMarker(pin: pin)
        }
        else{
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
            vc.willShowPin = true
            //vc.showPin = pinData
            vc.location = CLLocation(latitude: self.location.coordinate.latitude, longitude: self.location.coordinate.longitude)
            vc.selectedIndex = 0
            
            delegate?.showPinMarker(pin: pin)
            dismiss(animated: true, completion: nil)
          
            
            self.present(vc, animated: true, completion: nil)
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        present(gallery, animated: true, completion: nil)
    }
    
    @IBAction func addAFocus(_ sender: Any) {
        self.addFocusDropdownButton.isSelected = !self.addFocusDropdownButton.isSelected
        self.addFocusButton.isSelected = !self.addFocusButton.isSelected
        
        if self.addFocusDropdownButton.isSelected{
            self.addFocusStack.addArrangedSubview(self.addFocusTableView)
            self.view.bringSubview(toFront: self.addFocusStack)
        }else{
            self.addFocusStack.removeArrangedSubview(self.addFocusTableView)
            self.addFocusStack.sendSubview(toBack: self.addFocusStack)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return 2
        }else{
            return Constants.interests.interests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            if indexPath.row == 0{
                let currentLocationCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
                currentLocationCell.interestLabel.text = "Current Location"
                currentLocationCell.interestImage.frame.size.height = 23
                currentLocationCell.interestImage.frame.size.width = 20
                currentLocationCell.interestImage.image = #imageLiteral(resourceName: "Pin icon x1")
                currentLocationCell.layoutIfNeeded()
                currentLocationCell.backgroundColor = UIColor.lightGray
                currentLocationCell.accessoryType = .checkmark
                return currentLocationCell
            }else{
                let searchPlace = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell", for: indexPath) as! SearchPlaceCell
                searchPlace.backgroundColor = UIColor.lightGray
                return searchPlace
            }
            
        }else{
            let interestCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
            let interestName = Constants.interests.interests[indexPath.row]
            
            interestCell.interestLabel.text = interestName
            interestCell.interestImage.image = UIImage(named: "\(interestName) Green")
            return interestCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }else if tableView.tag == 1{
            let interestCell = tableView.cellForRow(at: indexPath) as! SingleInterestTableViewCell
            
            interestCell.accessoryType = .checkmark
            interestCell.tintColor = Constants.color.green
    
            self.addFocusButton.setTitle(interestCell.interestLabel.text, for: .normal)
            self.addFocusButton.setTitle(interestCell.interestLabel.text, for: .selected)
            self.addFocusStack.removeArrangedSubview(self.addFocusTableView)
            self.addFocusStack.sendSubview(toBack: self.addFocusStack)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
            guard let selectedCell = tableView.cellForRow(at: indexPath) else{
                return
            }
            selectedCell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            if indexPath.row == 0{
                return 40
            }else{
                return 110
            }
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        let chooseLocationVC = ChooseLocationViewController(nibName: "ChooseLocationViewController", bundle: nil)
        chooseLocationVC.delegate = self
        
        self.present(chooseLocationVC, animated: true, completion: nil)
    }
    
//    MARK: TextView delegate methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = Constants.color.navy
    }
    
    func gotSelectedLocation(location: LocationSuggestion) {
        self.selectedLocation = true
        self.location = CLLocation(latitude: location.lat, longitude: location.long)
        self.searchLocationTextField.text = location.name
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        gallery.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
        galleryPicArray = images
        
        cameraButton.setImage(crop(image: images[0], width: 50, height: 50), for: .normal)
        cameraButton.roundButton()
        gallery.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func showLoginFailedAlert(loginType: String) {
        let alert = UIAlertController(title: "Login error", message: "There has been an error logging in with \(loginType). Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = UIColor.primaryGreen()
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
