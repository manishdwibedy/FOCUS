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
        self.backgroundView?.backgroundColor = UIColor.white
    }
    
    func configure(interest: Interest) {
        imageView.backgroundColor = UIColor.randomColorGenerator()
        label.text = interest.name!
    }

}
