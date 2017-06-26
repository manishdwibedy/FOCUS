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

class PinScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GalleryControllerDelegate, CLLocationManagerDelegate, UITextViewDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var changeLocationOut: UIButton!
    @IBOutlet weak var pinTextView: UITextView!
    @IBOutlet weak var cancelOut: UIButton!
    @IBOutlet weak var pinOut: UIButton!
    @IBOutlet weak var cancelButtonOut: UIButton!
    @IBOutlet weak var publicOut: UIButton!
    @IBOutlet weak var facebookOut: UIButton!
    @IBOutlet weak var twitterOut: UIButton!
    @IBOutlet weak var chosseFocusOut: UIButton!
    @IBOutlet weak var focusLabel: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    
    
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
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.clipsToBounds = true
        
        selectedImage.layer.cornerRadius = selectedImage.frame.width/2
        selectedImage.clipsToBounds = true
        
        
//        Constants.DB.pins.observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            if value != nil
//            {
//                for (key,_) in (value)!
//                {
//                    let storyboard = UIStoryboard(name: "Pin", bundle: nil)
//                    let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
//                    let data = pinData(UID: (value?[key] as! NSDictionary)["fromUID"] as! String, dateTS: (value?[key] as! NSDictionary)["time"] as! Double, pin: (value?[key] as! NSDictionary)["pin"] as! String, location: (value?[key] as! NSDictionary)["formattedAddress"] as! String, lat: (value?[key] as! NSDictionary)["lat"] as! Double, lng: (value?[key] as! NSDictionary)["lng"] as! Double, path: Constants.DB.pins.child(key as! String))
//                    ivc.data = data
//                    self.present(ivc, animated: true, completion: { _ in })
//                    
//                    break
//                }
//            }
//        })
        
        
        if pinType == "normal"
        {
            cancelButtonOut.isHidden = true
        }else
        {
            cancelButtonOut.isHidden = false
            changeLocationOut.isHidden = true
            locationLabel.text = locationName
        }
        
        imageArray.append(UIImage(named:"Image")!)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        gallery.delegate = self
        
        let width = (((collectionView.frame.width))/numberOfItemsPerRow)-7
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        chosseFocusOut.layer.cornerRadius = 6
        chosseFocusOut.clipsToBounds = true
        chosseFocusOut.layer.borderColor =  UIColor(red: 122/255, green: 201/255, blue: 1/255, alpha: 1).cgColor
        chosseFocusOut.layer.borderWidth = 1
        
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
        getPhotos()
        
        getPlaceName(location: AuthApi.getLocation()!, completion: {address in
            self.locationLabel.text = address
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showUserProfile(sender:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tap)
        
        let focusTap = UITapGestureRecognizer(target: self, action: #selector(self.showFocus(sender:)))
        focusLabel.isUserInteractionEnabled = true
        self.focusLabel.addGestureRecognizer(focusTap)
        
    }
    
    
    func showFocus(sender: UITapGestureRecognizer)
    {
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
        let autoCompleteController = GMSAutocompleteViewController()
        
        let filter = GMSAutocompleteFilter()
        filter.country = "US"
        
        autoCompleteController.autocompleteFilter = filter

        autoCompleteController.delegate = self
        present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    @IBAction func camera(_ sender: Any) {
        present(gallery, animated: true, completion: nil)
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
            SCLAlertView().showError("Error", subTitle: "Please enter your caption")
            return
        }
        if self.interest.characters.count == 0{
            SCLAlertView().showError("Error", subTitle: "Please choose a FOCUS")
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
                Constants.DB.pins.child(AuthApi.getFirebaseUid()!).updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"formattedAddress":formmatedAddress, "lat": Double(coordinates.latitude), "lng": Double(coordinates.longitude), "images": imagePaths, "public": isPublic, "focus": focusLabel.text] )
                
                Constants.DB.pin_locations!.setLocation(CLLocation(latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude)), forKey: AuthApi.getFirebaseUid()!) { (error) in
                    if (error != nil) {
                        debugPrint("An error occured: \(error)")
                    } else {
                        print("Saved location successfully!")
                    }
                }
            }
            else{
                Constants.DB.pins.child(AuthApi.getFirebaseUid()!).updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"formattedAddress":locationLabel.text, "lat": AuthApi.getLocation()?.coordinate.latitude, "lng": AuthApi.getLocation()?.coordinate.longitude, "images": imagePaths, "public": isPublic, "focus": focusLabel.text] )
                
                Constants.DB.pin_locations!.setLocation(CLLocation(latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude)), forKey: AuthApi.getFirebaseUid()!) { (error) in
                    if (error != nil) {
                        debugPrint("An error occured: \(error)")
                    } else {
                        print("Saved location successfully!")
                    }
                }
            }
                
            if isTwitter == true
            {
                Share.postToTwitter(withStatus: pinTextView.text!)
            }
            if isFacebook == true
            {
                try! Share.facebookShare(with: URL(string: "www.google.com")!, description: pinTextView.text!)
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
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "home") as! UITabBarController
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
                
                selectedImage.image = cell.imageView.image
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
        selectedImage.image = galleryPicArray[0]
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
        
    }
    
    
    
    
    
    func getPhotos()
    {
        let imgageManager = PHImageManager()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic
        
        let fetch = PHFetchOptions()
        fetch.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetch)
        
        self.imageArray.removeAll()
        imageArray.append(#imageLiteral(resourceName: "pin_camera"))
        
        if fetchResult.count > 0
        {
            for i in 0..<fetchResult.count
            {
                imgageManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                image, error in
                    if let image = image{
                        print("got image")
                        
                        if let data = UIImageJPEGRepresentation(image, 0.5) as NSData?{
                            self.imageArray.append(image)
                        }
                        
                    }
                })
            }
            
        }
        
        collectionView.reloadData()
        
       
        
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
        
        let localFile = UIImageJPEGRepresentation(image, 0.5)
        
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
            isFacebook = true
            if AuthApi.getFacebookToken() == nil{
                
                loginView.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
                    if error != nil {
                        print(error?.localizedDescription)
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
            facebookOut.setImage(UIImage(named: "facebookGreen"), for: UIControlState.normal)
        }else
        {
            isFacebook = false
            facebookOut.setImage(UIImage(named: "facebookGray"), for: UIControlState.normal)
        }
    }
    
    @IBAction func twitterButton(_ sender: Any) {
        if isTwitter == false
        {
            if AuthApi.getTwitterToken() != nil{
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
            self.locationLabel.text = first.joined(separator: ", ")
            formmatedAddress = "\(first.joined(separator: ", "));;\(second.joined(separator: ", "))"
        }
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
//        UINavigationBar.appearance().translates
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().tintColor = UIColor.black
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
