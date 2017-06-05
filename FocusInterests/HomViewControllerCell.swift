//
//  HomViewControllerCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class HomViewControllerCell: UITableViewCell {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemActivities: UILabel!
    @IBOutlet weak var itemDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(itemOfInterest: ItemOfInterest) {
        //self.mainImage.image = itemOfInterest.mainImage
        self.mainImage.roundedImage()
        self.itemName.text = itemOfInterest.itemName!
//        self.itemActivities.text = featuresToString(features: itemOfInterest.features!)
//        self.itemDistance.text = itemOfInterest.distance!
        self.imageButton.image = UIImage(named: "addUser")
        imageButton.roundedImage()
    }
    
}
