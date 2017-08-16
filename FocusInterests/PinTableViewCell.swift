//
//  PinTableViewCell.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likeAmountLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UITextView!
    //@IBOutlet weak var focus: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var likeOut: UIButton!
    
    var data: pinData?
    var likeCount = 0
    var parentVC: UIViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    func loadLikes()
    {
//        if data != nil
//        {
//            if data["like"] != nil
//            {
//                likeCount = (data["like"] as? NSDictionary)?["num"] as! Int
//                likeAmountLabel.text = String(likeCount)
//            }
//        }
        Constants.DB.pins.child((data?.fromUID)!).child("like").child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.likeOut.isEnabled = false
                self.likeOut.setImage(UIImage(named: "Liked"), for: UIControlState.normal)
                
            }
        })

    }
    
    @IBAction func like(_ sender: Any) {
        likeCount = likeCount + 1
        Constants.DB.pins.child((data?.fromUID)!).child("like").updateChildValues(["num": likeCount])
        Constants.DB.pins.child((data?.fromUID)!).child("like").child("likedBy").childByAutoId().updateChildValues(["UID": AuthApi.getFirebaseUid()!])
        likeOut.isEnabled = false
        likeOut.setImage(UIImage(named: "Liked"), for: UIControlState.normal)
        likeAmountLabel.text = String(likeCount)
        
    }
    @IBAction func comment(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Comments", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "comments") as! CommentsViewController
        ivc.type = "place"
        ivc.data = data
        parentVC.present(ivc, animated: true, completion: { _ in })
    }
}
