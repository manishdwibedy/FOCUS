//
//  InviteListTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Contacts

class InviteListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var inviteConfirmationButton: UIButton!
    var delegate: SendInvitationsViewControllerDelegate?
    var cellIndexTag = Int()
    var user: InviteUser? = nil
    
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
        print("render \(self) ")
        
        self.inviteConfirmationButton.layer.borderWidth = 1
        self.inviteConfirmationButton.layer.borderColor = UIColor.white.cgColor
        self.inviteConfirmationButton.roundButton()
        
        self.userProfileImage.layer.borderWidth = 2
        self.userProfileImage.layer.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        self.userProfileImage.roundedImage()
        
        self.inviteConfirmationButton.setImage(#imageLiteral(resourceName: "Interest_blank"), for: .normal)
        self.inviteConfirmationButton.setImage(#imageLiteral(resourceName: "Green.png"), for: .selected)
    }
    
    func setUserNameAndFullNameValues(userName: String, fullName: String){
        self.usernameLabel.text = userName
        self.fullNameLabel.text = fullName
    }
    
    @IBAction func contactSelectedAction(_ sender: Any) {
        
        if self.inviteConfirmationButton.isSelected == false{
            self.isSelected = true
            self.inviteConfirmationButton.isSelected = true
            delegate?.contactHasBeenSelected(contact: user!, index: self.cellIndexTag)
//             delegate?.contactHasBeenSelectedString(contact: self.usernameLabel.text!, index: self.inviteConfirmationButton.tag)
        }else{
            self.isSelected = false
            self.inviteConfirmationButton.isSelected = false
            delegate?.contactHasBeenRemoved(contact: user!, index: self.cellIndexTag)
//            delegate?.contactHasBeenRemovedString(contact: self.usernameLabel.text!, index: self.inviteConfirmationButton.tag)
        }
    }
}
