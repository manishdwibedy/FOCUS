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
    @IBOutlet weak var userNameLabel: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userNameLabel.textContainer.maximumNumberOfLines = 0
        self.setupCell()
        self.userNameLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadInfo(UID:String, text: String){
        Constants.DB.user.child(UID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                let username = value?["username"] as! String
                let content = "\(username)  \(text)"
                
                var finalText = NSMutableAttributedString()
                finalText = NSMutableAttributedString(string:content)
                
                finalText.addAttributes([NSForegroundColorAttributeName: UIColor.white ,NSFontAttributeName : UIFont(name: "Avenir-Black", size: 15.0)!], range: NSRange(location:0,length:(username.characters.count)))
                
                finalText.addAttributes([NSForegroundColorAttributeName: UIColor.white ,NSFontAttributeName : UIFont(name: "Avenir Book", size: 15.0)!], range: NSRange(location:username.characters.count + 2,length:(text.characters.count)))

                if let image = value?["image_string"] as? String{
                    if let url = URL(string: image){
                        self.userProfileImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                    }
                }
                
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
