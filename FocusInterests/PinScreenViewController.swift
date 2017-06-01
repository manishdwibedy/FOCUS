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

class PinScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GalleryControllerDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var changeLocationOut: UIButton!
    @IBOutlet weak var pinTextView: UITextView!
    @IBOutlet weak var cancelOut: UIButton!
    @IBOutlet weak var pinOut: UIButton!
    
    var imageArray = [UIImage]()
    var cellArray = [PinImageCollectionViewCell]()
    let gallery = GalleryController()
    var galleryPicArray = [UIImage]()
    
    let locationManager = CLLocationManager()
    var place: GMSPlace!
    var coordinates = CLLocationCoordinate2D()
    var formmatedAddress = ""
    
    let sidePadding: CGFloat = 0.0
    let numberOfItemsPerRow: CGFloat = 4.0
    let hieghtAdjustment: CGFloat = 0.0
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 500
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        Constants.DB.pins.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                for (key,_) in (value)!
                {
                    let storyboard = UIStoryboard(name: "Pin", bundle: nil)
                    let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
                    let data = pinData(UID: (value?[key] as! NSDictionary)["fromUID"] as! String, dateTS: (value?[key] as! NSDictionary)["time"] as! Double, pin: (value?[key] as! NSDictionary)["pin"] as! String, location: (value?[key] as! NSDictionary)["place"] as! String, lat: (value?[key] as! NSDictionary)["lat"] as! Double, lng: (value?[key] as! NSDictionary)["lng"] as! Double, path: Constants.DB.pins.child(key as! String))
                    ivc.data = data
                    self.present(ivc, animated: true, completion: { _ in })
                    
                    break
                }
            }
        })
        
        
        
        imageArray.append(UIImage(named:"Icon-Small-50x50@1x")!)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        gallery.delegate = self
        
        let width = ((collectionView.frame.width) - sidePadding)/numberOfItemsPerRow
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width + hieghtAdjustment)
        
        cancelOut.layer.cornerRadius = 6
        cancelOut.clipsToBounds = true
        
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
        print("GOT LOCATION###################################################")
        print(coordinates)
        locationManager.stopUpdatingLocation()
        
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func changeLocation(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
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
            if galleryPicArray.count != 0
            {
                let imagePaths = NSMutableDictionary()
                for image in galleryPicArray
                {
                    let random = Int(time) + Int(arc4random_uniform(10000000))
                    let path = AuthApi.getFirebaseUid()!+"/"+String(random)
                    imagePaths.addEntries(from: [String(random):["imagePath": path]])
                    uploadImage(image: image, path: Constants.storage.pins.child(path))
                }
                Constants.DB.pins.childByAutoId().updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"place":formmatedAddress, "lat": Double(coordinates.latitude), "lng": Double(coordinates.longitude), "images": imagePaths])
            }else
            {
                Constants.DB.pins.childByAutoId().updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "pin": pinTextView.text!,"place":formmatedAddress,"lat": Double(coordinates.latitude), "lng": Double(coordinates.longitude), "images":"nil"])
            }
        }
        pinTextView.text = "What are you up to?"
        pinTextView.font = UIFont(name: "HelveticaNeue", size: 30)
        imageArray.removeAll()
        galleryPicArray.removeAll()
        
        for cell in cellArray
        {
            cell.imageView.layer.borderWidth = 0
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
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
        
    }
    
    
    
    
    
    func getPhotos()
    {
        let imgageManager = PHImageManager()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .opportunistic
        
        let fetch = PHFetchOptions()
        fetch.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetch)
        
        if fetchResult.count > 0
        {
            for i in 0..<fetchResult.count
            {
                imgageManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                image, error in
                    
                    print("got image")
                    self.imageArray.append(image!)
                    
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

 
}

extension PinScreenViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.place = place
        self.locationLabel.text = place.formattedAddress!
        self.changeLocationOut.setTitle(place.formattedAddress, for: UIControlState.normal)
        coordinates = self.place.coordinate
        formmatedAddress = self.place.formattedAddress!
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // to do: handle error
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
