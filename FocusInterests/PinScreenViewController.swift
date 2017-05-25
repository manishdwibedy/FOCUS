//
//  PinScreenViewController.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/25/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Photos

class PinScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var changeLocationOut: UIButton!
    
    var imageArray = [UIImage]()
    
    let sidePadding: CGFloat = 0.0
    let numberOfItemsPerRow: CGFloat = 4.0
    let hieghtAdjustment: CGFloat = 0.0
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let width = ((collectionView.frame.width) - sidePadding)/numberOfItemsPerRow
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width + hieghtAdjustment)
        
        getPhotos()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func changeLocation(_ sender: Any) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PinImageCollectionViewCell
        cell.imageView.image = imageArray[indexPath.row]
        
        return cell
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
    
    
    


    

}
