//
//  CommentsTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadInfo(UID:String, text: String)
    {
        Constants.DB.user.child(UID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                let username = value?["username"] as! String
                let content = "\(username)  \(text)"
                
                var finalText = NSMutableAttributedString()
                finalText = NSMutableAttributedString(string:content)
                
                finalText.setAttributes([NSFontAttributeName : UIFont(name: "Avenir Book", size: 15.0)!], range: NSRange(location:username.characters.count + 2,length:(text.characters.count)))

                //finalText.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir Black", size: 15.0)!, range:)
                self.userNameLabel.attributedText = finalText
            }
        })
    }
    
    func setupCell(){
        self.userProfileImage.layer.borderWidth = 2
        self.userProfileImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userProfileImage.roundedImage()
    }
}
