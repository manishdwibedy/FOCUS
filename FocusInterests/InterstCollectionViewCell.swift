//
//  InterstCollectionViewCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InterstCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    //@IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var image: UIImageView!
    var parentVC: InterestsViewController!
    var index: Int!
    var indexPath: IndexPath!
    
    var liked = false
    var loved = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.view.layer.borderColor = UIColor(red: 22/255, green: 44/255, blue: 69/255, alpha: 1.0).cgColor
        self.view.layer.borderWidth = 5
        self.view.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        self.addGestureRecognizer(tap)
        
        let tapDouble = UITapGestureRecognizer(target: self, action: #selector(tapDouble(sender:)))
        tapDouble.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapDouble)
        
        let longP = UILongPressGestureRecognizer(target: self, action: #selector(longP(sender:)))
        longP.minimumPressDuration = 0.3
        self.addGestureRecognizer(longP)
        
        
    }
    
    func tap(sender: UITapGestureRecognizer)
    {
        self.view.layer.borderWidth = 0
        self.image.image = UIImage(named: parentVC.imageArrayGreen[index])
        self.backgroundColor = UIColor(red: 22/255, green: 44/255, blue: 69/255, alpha: 1)
        self.label.textColor = UIColor.white
        
        if liked == false
        {
            liked = true
            loved = false
        }

    }
    func tapDouble(sender: UITapGestureRecognizer)
    {
        self.view.layer.borderWidth = 0
        self.image.image = UIImage(named: parentVC.imageArrayGreen[index])
        self.backgroundColor = UIColor.white
        self.label.textColor = UIColor.black
        
        if loved == false
        {
         
            loved = true
            liked = false
         }
        
    }
    
    func longP(sender: UILongPressGestureRecognizer)
    {
        //parentVC.collectionView.deleteItems(at: [indexPath])
    }

}
