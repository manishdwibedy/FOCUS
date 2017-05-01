//
//  UserPhotoCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class UserPhotoCell: UITableViewCell, EditDelegate, CellImageDelegate, UserProfileCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var uploadPhoto: UILabel!
    
    override func awakeFromNib() {
        actStatic()
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryGreen()
        let im = UIImage(named: "userPlHolder")
        userImage.image = im!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func actEditable(currentString: String) {
        if currentString == "" {
            self.userImage.image = nil
        } 
        self.isUserInteractionEnabled = true
        self.uploadPhoto.isHidden = false
    }
    
    func actStatic() {
        self.isUserInteractionEnabled = false
        self.uploadPhoto.isHidden = true
    }
    
    func set(image: UIImage) {
        self.userImage.image = nil
        self.userImage.backgroundColor = UIColor.primaryGreen()
        self.userImage.image = image
    }
    
    func configureFor(user: FocusUser) {
        
    }
    
    // delegate methods
    func makeEditable(currentString: String) {
        actEditable(currentString: currentString)
    }
    
    func makeStatic() {
        actStatic()
    }
    
    
}
