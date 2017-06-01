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
    @IBOutlet weak var dateLabel: UILabel!
    
    var data: commentCellData!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
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
        likeOut.isEnabled = false
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
        
        self.dateLabel.text = getTimeSince(date: data.date)
        
    }
    
    
    
    func getTimeSince(date:Date) -> String
    {
        var returnString = ""
        let now = Date()
        let seconds = now.timeIntervalSince(date)
        let minutes = seconds/60
        let hours = minutes/60
        let days = hours/24
        if Int(days) >= 1
        {
            returnString = String(Int(days)) + " days ago"
            
        }else if Int(hours) >= 1
        {
            returnString = String(Int(hours)) + " hours ago"
            
        }else if Int(minutes) >= 1
        {
            returnString = String(Int(minutes)) + " minutes ago"
            
        }else if seconds < 60
        {
            returnString = "seconds ago"
        }
 
        return returnString
    }
    
    
}

class commentCellData
{
    var from = String()
    var comment = String()
    var commentFirePath: DatabaseReference!
    var likeCount = Int()
    var date = Date()
    
    init(from:String,comment:String,commentFirePath: DatabaseReference, likeCount: Int, date:Date) {
        self.from = from
        self.comment = comment
        self.commentFirePath = commentFirePath
        self.likeCount = likeCount
        self.date = date
    }
}
