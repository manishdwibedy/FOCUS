//
//  commentCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase
class commentCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UITextView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var likeOut: UIButton!
    
    var data: commentCellData!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtton(_ sender: Any) {
        
        let newLike = data.likeCount + 1
        data.commentFirePath.child("like").updateChildValues(["num":newLike])
        data.commentFirePath.child("like").child("likedBy").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
        likeCount.text = String(newLike)
        self.likeOut.setTitleColor(UIColor.red, for: UIControlState.normal)
    }
    
    func checkForLike()
    {
        data.commentFirePath.child("like").child("likedBy").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.likeOut.setTitleColor(UIColor.red, for: UIControlState.normal)
                self.likeOut.isEnabled = false
            }
            
        })
        
    }
    
    
}

class commentCellData
{
    var from = String()
    var comment = String()
    var commentFirePath: FIRDatabaseReference!
    var likeCount = Int()
    
    init(from:String,comment:String,commentFirePath: FIRDatabaseReference, likeCount: Int) {
        self.from = from
        self.comment = comment
        self.commentFirePath = commentFirePath
        self.likeCount = likeCount
    }
}
