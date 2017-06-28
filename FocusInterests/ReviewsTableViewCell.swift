//
//  ReviewsTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class ReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var starReviewOne: UIImageView!
    @IBOutlet weak var starReviewTwo: UIImageView!
    @IBOutlet weak var starReviewThree: UIImageView!
    @IBOutlet weak var starReviewFour: UIImageView!
    @IBOutlet weak var starReviewFive: UIImageView!
    
    var stars = [UIImageView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(){
        
        stars = [starReviewOne,starReviewTwo,starReviewThree,starReviewFour,starReviewFive]
        
        self.userProfileImage.layer.borderWidth = 2
        self.userProfileImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userProfileImage.roundedImage()
        self.setupBottomBorderForReadMoreButton()
        self.checkAmountOfCharactersLabelHas()
    }
    
    func checkAmountOfCharactersLabelHas(){
        
        self.readMoreButton.isHidden = true
        
        if commentsLabel.text!.characters.count > 160 {
            var tempCommentsLabel = commentsLabel.text?[commentsLabel.text!.startIndex..<commentsLabel.text!.index(commentsLabel.text!.startIndex, offsetBy: 159)]
            print(tempCommentsLabel)
            self.commentsLabel.text = tempCommentsLabel
            self.readMoreButton.isHidden = false
        }
    }
    
    func setupBottomBorderForReadMoreButton(){
        let bottomBorder: CALayer = CALayer()
        bottomBorder.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRect(x: 0, y: self.readMoreButton.frame.height, width: self.readMoreButton.frame.width, height: 1)
        self.readMoreButton.layer.addSublayer(bottomBorder)
    }
    
    
    func getUsernae(UID: String)
    {
        Constants.DB.user.child(UID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                self.userNameLabel.text = value["username"] as! String
            }
        })
    }
    
    func showStarts(num: Int)
    {
        for i in 0..<num
        {
            stars[i].image = UIImage(named: "Star")
        }
        
    }
    
    
}
