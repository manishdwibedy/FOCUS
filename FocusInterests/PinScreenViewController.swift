//
//  PinScreenViewController.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/25/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Photos
import Gallery
import Firebase
import GooglePlaces
import SCLAlertView
import FBSDKLoginKit
import SDWebImage
import Crashlytics

class PinScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GalleryControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate{

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var changeLocationOut: UIButton!
    @IBOutlet weak var pinTextView: UITextView!
    @IBOutlet weak var cancelOut: UIButton!
    @IBOutlet weak var pinOut: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var cancelButtonOut: UIButton!
    @IBOutlet weak var publicOut: UIButton!
    @IBOutlet weak var facebookOut: UIButton!
    @IBOutlet weak var twitterOut: UIButton!
    @IBOutlet weak var chosseFocusOut: UIButton!
    @IBOutlet weak var focusLabel: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var focusLabelView: UIView!
    
    var pinType = "normal"
    var imageArray = [UIImage]()
    var cellArray = [PinImageCollectionViewCell]()
    let gallery = GalleryController()
    var galleryPicArray = [UIImage]()
    let loginView = FBSDKLoginManager()
    
    let locationManager = CLLocationManager()
    var place: GMSPlace!
    var coordinates = CLLocationCoordinate2D()
    var locationName = ""
    var formmatedAddress = ""
    
    let sidePadding: CGFloat = 0.0
    let numberOfItemsPerRow: CGFloat = 3.0
    let hieghtAdjustment: CGFloat = 0.0
    
    var isPublic = false
    var isTwitter = false
    var isFacebook = false
    
    var interest = ""
    var lastCaption = ""
    
    var placeEventID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.clipsToBounds = true
        
        selectedImage.roundedImage()
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? [String:Any]
            let image_string = value?["image_string"] as? String ?? ""
            
            
            if let url = URL(string: image_string){
                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                    (receivedSize :Int, ExpectedSize :Int) in
                    
                }, completed: {
                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                    
                    if image != nil && finished{
                        self.profileImage.image = crop(image: image!, width: 85, height: 85)
                    }
                })
            }
            
        })
        
        if pinType == "normal"
        {
            cancelButtonOut.isHidden = true
        }else
        {
            cancelButtonOut.isHidden = false
            changeLocationOut.isHidden = true
            locationLabel.text = locationName
        }
        
        imageArray.append(#imageLiteral(resourceName: "pin_camera"))
        
        
        gallery.delegate = self
        
        
        chosseFocusOut.layer.cornerRadius = 6
        chosseFocusOut.clipsToBounds = true
        chosseFocusOut.layer.borderColor =  UIColor.white.cgColor
        chosseFocusOut.layer.borderWidth = 1
        
        
        addImageButton.layer.cornerRadius = 6
        addImageButton.clipsToBounds = true
        addImageButton.layer.borderColor =  UIColor.white.cgColor
        addImageButton.layer.borderWidth = 1
        
        pinOut.layer.cornerRadius = 6
        pinOut.clipsToBounds = true
        
        changeLocationOut.layer.cornerRadius = 6
        changeLocationOut.clipsToBounds = true
        changeLocationOut.layer.borderColor = UIColor.white.cgColor
        changeLocationOut.layer.borderWidth = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardDidHide, object: nil)
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(keyboardDone))
        done.tintColor = UIColor(red: 112/255, green: 201/255, blue: 1/255, alpha: 1)
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        pinTextView.inputAccessoryView = doneToolbar
        pinTextView.delegate = self
        
        if self.pinType != "place" || self.pinType != "event"{
            self.coordinates = CLLocationCoordinate2D(latitude: AuthApi.getLocation()!.coordinate.latitude, longitude: AuthApi.getLocation()!.coordinate.longitude)
            getPlaceName(location: AuthApi.getLocation()!, completion: {address in
                self.formmatedAddress = address
                self.locationLabel.text = address
            })
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showUserProfile(sender:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tap)
        
        let focusTap = UITapGestureRecognizer(target: self, action: #selector(self.showFocus(sender:)))
        focusLabel.isUserInteractionEnabled = true
        
        self.focusLabel.addGestureRecognizer(focusTap)

        
        let colorAnimation = CABasicAnimation(keyPath: "borderColor")
        colorAnimation.fromValue = UIColor.clear.cgColor
        colorAnimation.toValue = Constants.color.green.cgColor
        
        let widthAnimation = CABasicAnimation(keyPath: "borderWidth")
        widthAnimation.fromValue = 1
        widthAnimation.toValue = 2
        widthAnimation.duration = 1.0
        self.pinTextView.layer.borderWidth = 2
        
        let bothAnimations = CAAnimationGroup()
        bothAnimations.duration = 2.5
        bothAnimations.animations = [colorAnimation, widthAnimation]
        bothAnimations.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
//        self.pinTextView.layer.add(bothAnimations, forKey: "color and width")
        self.animateBorderWidth(view: self.pinTextView, from: 0.0, to: 1.0, duration: 2.0)
        
        Config.showsVideoTab = false
    }
    
    func animateBorderWidth(view: UIView, from: CGFloat, to: CGFloat, duration: Double) {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        view.layer.add(animation, forKey: "Width")
        view.allCornersRounded(radius: 5.0)
        view.layer.cornerRadius = 8.0
        view.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1.0/255.0, alpha: 1.0).cgColor
//        view.layer.borderWidth = to
    }
    
    func showFocus(sender: UITapGestureRecognizer){
        lastCaption = pinTextView.text
        let focusWindow = InterestsViewController(nibName:"InterestsViewController", bundle:nil)
        focusWindow.pinInterest = true
        self.present(focusWindow, animated: true, completion:{
            focusWindow.saveButton.isEnabled = false
            focusWindow.saveButton.title = ""
            focusWindow.needsReturn = true
            focusWindow.parentReturnVC = self
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Answers.logCustomEvent(withName: "Screen",
                               customAttributes: [
                                "Name": "Create Pin"
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func showUserProfile(sender: UITapGestureRecognizer)
    {
        let VC:UIViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UserProfileViewController
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(VC, animated:true, completion:nil)
    }
    
    @IBAction func changeLocation(_ sender: Any) {
        let autoCompleteController = self.createGMSViewController()
        
        present(autoCompleteController, animated: true, completion: nil)
    }
    
    func createGMSViewController() -> GMSAutocompleteViewController{
        let autoCompleteController = GMSAutocompleteViewController()
        
        let filter = GMSAutocompleteFilter()
        filter.country = "US"
        
        autoCompleteController.autocompleteFilter = filter
        
        
        autoCompleteController.delegate = self
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        //        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 17)!
        ]
        
        let placeholderTextAttributes: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = placeholderAttributes
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = placeholderTextAttributes
        
        autoCompleteController.primaryTextColor = UIColor.white
        autoCompleteController.primaryTextHighlightColor = Constants.color.green
        autoCompleteController.secondaryTextColor = UIColor.white
        autoCompleteController.tableCellBackgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
        autoCompleteController.tableCellSeparatorColor = UIColor.white
        
        return autoCompleteController
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        pinTextView.text = "What are you up to? Type here."
        pinTextView.font = UIFont(name: "Avenir Book", size: 15)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pin(_ sender: Any) {
        for cell in cellArray
        {
            if cell.selectedIs == true
            {
                galleryPicArray.append(cell.imageView.image!)
            }
        }
        
        if pinTextView.text == "What are you up to? Type here."{
            SCLAlertView().showCustom("Oops!", subTitle: "Please enter your caption", color: UIColor.orange, icon: #imageLiteral(resourceName: "placeholder_people"))
            return
        }
        if self.interest.characters.count == 0{
            SCLAlertView().showCustom("Oops!", subTitle: "Please enter your FOCUS", color: UIColor.orange, icon: #imageLiteral(resourceName: "placeholder_people"))
            return
        }
        
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).removeValue()
        
        let time = NSDate().timeIntervalSince1970
        if pinTextView.text != nil && pinTextView.text != ""
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
                Constants.DB.pins.child(AuthApi.getFirebaseUid()!).updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"formattedAddress":formmatedAddress, "lat": Double(coordinates.latitude), "lng": Double(coordinates.longitude), "images": imagePaths, "public": isPublic, "focus": focusLabel.text ?? ""] )
                
                Constants.DB.pin_locations!.setLocation(CLLocation(latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude)), forKey: AuthApi.getFirebaseUid()!) { (error) in
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
                
                if pinType == "place"{
                    Constants.DB.places.child("\(placeEventID)/pins").updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"formattedAddress":formmatedAddress, "lat": Double(coordinates.latitude), "lng": Double(coordinates.longitude), "images": imagePaths, "public": isPublic, "focus": focusLabel.text ?? ""] )
                    
                }
                else if pinType == "event"{
                    Constants.DB.event.child("\(placeEventID)/pins").updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"formattedAddress":formmatedAddress, "lat": Double(coordinates.latitude), "lng": Double(coordinates.longitude), "images": imagePaths, "public": isPublic, "focus": focusLabel.text ?? ""] )
                }
                Answers.logCustomEvent(withName: "Pin",
                                       customAttributes: [
                                        "user": AuthApi.getFirebaseUid()!,
                                        "interest": focusLabel.text,
                                        "address": formmatedAddress,
                                        "imageSelected": galleryPicArray.count > 0,
                                        "public": isPublic
                                        
                                        ])
                
            }
            if isTwitter == true
            {
                Share.postToTwitter(withStatus: pinTextView.text!)
            }
            if isFacebook == true
            {
                try! Share.facebookShare(with: URL(string: "http://mapofyourworld.com")!, description: pinTextView.text!)
            }
        }
        pinTextView.text = "What are you up to? Type here."
        pinTextView.font = UIFont(name: "Avenir Book", size: 15)
        
        imageArray.removeAll()
        galleryPicArray.removeAll()
        pinTextView.resignFirstResponder()
        
        isPublic = false
        isTwitter = false
        isFacebook = false
        
        
        publicOut.setImage(UIImage(named: "LockGray"), for: UIControlState.normal)
        facebookOut.setImage(UIImage(named: "facebookGray"), for: UIControlState.normal)
        twitterOut.setImage(UIImage(named: "TwitterGray"), for: UIControlState.normal)
        
        for cell in cellArray
        {
            cell.imageView.layer.borderWidth = 0
        }
        
        if pinType != "normal"
        {
            dismiss(animated: true, completion: nil)
        }
        else{
//            let vc = self.tabBarController?.viewControllers![0] as! MapViewController
//            vc.showPin = true
//            vc.currentLocation = CLLocation(latitude: Double(coordinates.longitude), longitude: Double(coordinates.longitude))
//            
//            self.tabBarController?.selectedIndex = 0
            
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
            vc.showPin = true
            vc.location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            vc.selectedIndex = 0
            self.present(vc, animated: true, completion: nil)
        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellArray.removeAll()
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PinImageCollectionViewCell
        cell.imageView.image = imageArray[indexPath.row]
        cell.imageView.contentMode = .scaleAspectFill
        cellArray.append(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            present(gallery, animated: true, completion: nil)
        }else
        {
            let cell = cellArray[indexPath.row]
            if cell.selectedIs == false
            {
                cell.imageView.layer.borderColor = UIColor(red: 122/255, green: 201/255, blue: 1/255, alpha: 1).cgColor
                cell.imageView.layer.borderWidth = 5
                cell.selectedIs = true
                
                
                selectedImage.image = crop(image: cell.imageView.image!, width: 50, height: 50)
            }else
            {
                
                cell.imageView.layer.borderWidth = 0
                cell.selectedIs = false
            }
        }
    }
    
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        gallery.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
        galleryPicArray = images
        gallery.dismiss(animated: true, completion: nil)
        
        if galleryPicArray.count > 0{
            selectedImage.image = crop(image: galleryPicArray[0], width: 50, height: 50)
        }
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            pinTextView.text = ""
            pinTextView.font = UIFont(name: "Avenir Book", size: 15)
        
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            pinTextView.text = lastCaption
            if pinTextView.text == ""
            {
                pinTextView.text = "What are you up to? Type here."
                pinTextView.font = UIFont(name: "Avenir Book", size: 15)        
            }
            
        }
    }
    
    func keyboardDone()
    {
       pinTextView.resignFirstResponder()
    }
    
    
    
    func uploadImage(image:UIImage, path: StorageReference)
    {
        
        let localFile = UIImageJPEGRepresentation(image, 1)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let userID = AuthApi.getFirebaseUid()
        let uploadTask = path.putData(localFile!, metadata: metadata)
    
        
        uploadTask.observe(.pause) { snapshot in
            
        }
        
        uploadTask.observe(.resume) { snapshot in
            
        }
        
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                print(percentComplete)
            }
        }
        
        uploadTask.observe(.success) { snapshot in
           
        }
        
        uploadTask.observe(.failure) { snapshot in
            print(snapshot.error!)
        }

    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func publicButton(_ sender: Any) {
        if isPublic == false
        {
            isPublic = true
            publicOut.setImage(UIImage(named: "LockGreen"), for: UIControlState.normal)
            
        }else
        {
            isPublic = false
            publicOut.setImage(UIImage(named: "LockGray"), for: UIControlState.normal)
        }
    }
    
    @IBAction func facebookButton(_ sender: Any) {
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
                                        self.facebookOut.setImage(UIImage(named: "facebookGreen"), for: UIControlState.normal)
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
                self.facebookOut.setImage(UIImage(named: "facebookGreen"), for: UIControlState.normal)
            }
            
        }else
        {
            isFacebook = false
            facebookOut.setImage(UIImage(named: "facebookGray"), for: UIControlState.normal)
        }
    }
    
    @IBAction func twitterButton(_ sender: Any) {
        if isTwitter == false
        {
            if AuthApi.getTwitterToken() == nil{
                Share.loginTwitter()
            }
            isTwitter = true
            twitterOut.setImage(UIImage(named: "TwitterGreen"), for: UIControlState.normal)
        }else
        {
            isTwitter = false
            twitterOut.setImage(UIImage(named: "TwitterGray"), for: UIControlState.normal)
        }
    }
    
    
    @IBAction func chooseFOCUS(_ sender: Any) {
        
        lastCaption = pinTextView.text
        let focusWindow = InterestsViewController(nibName:"InterestsViewController", bundle:nil)
        focusWindow.pinInterest = true
        self.present(focusWindow, animated: true, completion:{
            focusWindow.saveButton.isEnabled = false
            focusWindow.saveButton.title = ""
            focusWindow.needsReturn = true
            focusWindow.parentReturnVC = self
        })
        
        
    }
    
    @IBAction func addImage(_ sender: Any) {
        present(gallery, animated: true, completion: nil)
    }
    
    func showLoginFailedAlert(loginType: String) {
        let alert = UIAlertController(title: "Login error", message: "There has been an error logging in with \(loginType). Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = UIColor.primaryGreen()
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        lastCaption = textView.text
    }
}

extension PinScreenViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.place = place
        //self.changeLocationOut.setTitle(place.formattedAddress, for: UIControlState.normal)
        coordinates = self.place.coordinate
        
        var first = [String]()
        var second = [String]()
        
        var isPlace = true
        //locality;admin area level 1; postal code
        for a in place.addressComponents!{
            if a.type == "street_number"{
                first.append(a.name)
                isPlace = false
            }
            if a.type == "route"{
                first.append(a.name)
                isPlace = false
            }
            
            if a.type == "locality"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "administrative_area_level_1"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "postal_code"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "premise"{
                first.append(a.name)
                break
            }
        }
        
        if isPlace{
            second = first
            self.locationLabel.text = place.name
            
            formmatedAddress = "\(place.name);;\(second.joined(separator: ", "))"
        }
        else{
            self.locationLabel.text = first.joined(separator: " ")
            formmatedAddress = "\(first.joined(separator: " "));;\(second.joined(separator: " "))"
        }
        
        
        self.navigationController?.navigationBar.barTintColor = Constants.color.navy
        UINavigationBar.appearance().barTintColor = Constants.color.navy
        UINavigationBar.appearance().tintColor = UIColor.white
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // to do: handle error
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        viewController.autocompleteFilter?.country = "US"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        viewController.autocompleteFilter?.country = "US"
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
