//
//  CellCollectionCellCollectionViewCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/26/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CellCollectionCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(interest: Interest) {
        imageView.backgroundColor = UIColor.lightGray
        if let pic = interest.image {
            imageView.image = pic
        }
        label.text = interest.name!
    }

}
