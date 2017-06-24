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

class PinScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GalleryControllerDelegate, CLLocationManagerDelegate{

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
        
        
        getPhotos()
        

        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        coordinates = location.coordinate
        getAddress(loc: location, completion: {(address)in
            self.locationLabel.text = address
            self.formmatedAddress = address
        })
        locationManager.stopUpdatingLocation()
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        pinTextView.text = "What are you up to?"
        pinTextView.font = UIFont(name: "HelveticaNeue", size: 30)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pin(_ sender: Any) {
        
        if pinTextView.text == "What are you up to?"{
            SCLAlertView().showError("Error", subTitle: "Please enter your caption")
            return
        }
        if self.interest.characters.count == 0{
            SCLAlertView().showError("Error", subTitle: "Please choose a FOCUS")
            return
        }
        
        Constants.DB.pins.child(AuthApi.getFirebaseUid()!).removeValue()
        for cell in cellArray
        {
            if cell.selectedIs == true
            {
                galleryPicArray.append(cell.imageView.image!)
            }
        }
        
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
                Constants.DB.pins.child(AuthApi.getFirebaseUid()!).updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"formattedAddress":formmatedAddress, "lat": Double(coordinates.latitude), "lng": Double(coordinates.longitude), "images": imagePaths, "public": isPublic, "focus": focusLabel.text] )

            
            if isTwitter == true
            {
                Share.postToTwitter(withStatus: pinTextView.text!)
            }
            if isFacebook == true
            {
                try! Share.facebookShare(with: URL(string: "www.google.com")!, description: pinTextView.text!)
            }
        }
        pinTextView.text = "What are you up to?"
        pinTextView.font = UIFont(name: "HelveticaNeue", size: 30)
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
                        self.imageArray.append(image)
                    }
                })
            }
            
        }
        
        collectionView.reloadData()
        
       
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            pinTextView.text = ""
            pinTextView.font = UIFont(name: "HelveticaNeue", size: 20)
        
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if pinTextView.text == ""
            {
                pinTextView.text = "What are you up to?"
                pinTextView.font = UIFont(name: "HelveticaNeue", size: 30)
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
            isTwitter = true
            twitterOut.setImage(UIImage(named: "TwitterGreen"), for: UIControlState.normal)
        }else
        {
            isTwitter = false
            twitterOut.setImage(UIImage(named: "TwitterGray"), for: UIControlState.normal)
        }
    }
    
    
    @IBAction func chooseFOCUS(_ sender: Any) {
        
        let focusWindow = InterestsViewController(nibName:"InterestsViewController", bundle:nil)
        self.present(focusWindow, animated: true, completion:{
            focusWindow.saveButton.isEnabled = false
            focusWindow.saveButton.title = ""
            focusWindow.needsReturn = true
            focusWindow.parentReturnVC = self
        })
        
        
    }
    
    
    func getAddress(loc:CLLocation, completion: @escaping (String) -> Void){
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
               
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0] as! CLPlacemark
                
                completion(pm.locality!)
            }
            else {
                
            }
        })
        
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
