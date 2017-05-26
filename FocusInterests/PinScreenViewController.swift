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

class PinScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GalleryControllerDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var changeLocationOut: UIButton!
    @IBOutlet weak var pinTextView: UITextView!
    @IBOutlet weak var cancelOut: UIButton!
    @IBOutlet weak var pinOut: UIButton!
    
    var imageArray = [UIImage]()
    let gallery = GalleryController()
    
    let sidePadding: CGFloat = 0.0
    let numberOfItemsPerRow: CGFloat = 4.0
    let hieghtAdjustment: CGFloat = 0.0
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func changeLocation(_ sender: Any) {
    }
    
    
    @IBAction func camera(_ sender: Any) {
        present(gallery, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        pinTextView.text = "What are you up to?"
        pinTextView.font = UIFont(name: "HelveticaNeue", size: 30)
    }
    
    @IBAction func pin(_ sender: Any) {
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PinImageCollectionViewCell
        cell.imageView.image = imageArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            present(gallery, animated: true, completion: nil)
        }
    }
    
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        gallery.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
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

    
    
    


    

}
