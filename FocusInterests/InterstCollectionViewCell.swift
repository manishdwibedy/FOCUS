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

//        let longP = UILongPressGestureRecognizer(target: self, action: #selector(longP(sender:)))
//        longP.minimumPressDuration = 0.3
//        self.addGestureRecognizer(longP)
    }
    
    func tap(sender: UITapGestureRecognizer)
    {
        if parentVC.needsReturn == false && parentVC.shouldOnlyReturn == false{
            self.view.layer.borderWidth = 0
            let interest = parentVC.focus[indexPath.row]
            
            if liked == false
            {
                liked = true
                loved = false
            }
            
            changeStatus(focus: interest)
        } else if parentVC.shouldOnlyReturn == true {
            self.view.layer.borderWidth = 0
            let interest = parentVC.focus[indexPath.row]
            
            if liked == false
            {
                liked = true
                loved = false
            }
            
            changeStatus(focus: interest)
            parentVC.returnToCreateEvent(FOCUS: label.text!)
            
        }
        else{
                parentVC.returnValue(FOCUS:label.text!)
        }

    }
    
    func changeStatus(focus: Interest){
        focus.status.toggle()
        
        switch(focus.status){
        case .normal:
            self.backgroundColor = UIColor(red: 22/255, green: 44/255, blue: 69/255, alpha: 0.5)
            self.label.textColor = UIColor.white
            let imageName = "\(focus.name!) Blue"
            self.image.image = UIImage(named: imageName)
            
            self.view.layer.borderColor = UIColor(red: 22/255, green: 44/255, blue: 69/255, alpha: 1.0).cgColor
            self.view.layer.borderWidth = 5
            
            
        case .like:
            self.backgroundColor = UIColor(red: 22/255, green: 44/255, blue: 69/255, alpha: 1)
            self.label.textColor = UIColor.white
            
            let imageName = "\(focus.name!) Green"
            self.image.image = UIImage(named: imageName)
            
        case .love:
            self.backgroundColor = UIColor.white
            self.label.textColor = UIColor.black
            let imageName = "\(focus.name!) Green"
            self.image.image = UIImage(named: imageName)
            
        default:
            break
        }
    }
//    func tapDouble(sender: UITapGestureRecognizer)
//    {
//        self.view.layer.borderWidth = 0
//        let imageName = "\(parentVC.focus[indexPath.row]) Green"
//        self.image.image = UIImage(named: imageName)
//        self.backgroundColor = UIColor.white
//        self.label.textColor = UIColor.black
//        
//        if loved == false
//        {
//         
//            loved = true
//            liked = false
//         }
//        
//    }
    
//    func longP(sender: UILongPressGestureRecognizer)
//    {
//        if sender.state != .ended {
//            return
//        }
//        parentVC.focus.remove(at: indexPath.row)
//        parentVC.collectionView.deleteItems(at: [indexPath])
//    }

}
