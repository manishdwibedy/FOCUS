//
//  SearchPlaceCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SearchPlaceCell: UITableViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var followButtonOut: UIButton!
    @IBOutlet weak var inviteButtonOut: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        followButtonOut.layer.cornerRadius = 6
        followButtonOut.clipsToBounds = true
        inviteButtonOut.layer.cornerRadius = 6
        inviteButtonOut.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followButton(_ sender: Any) {
    }
   
    @IBAction func inviteButton(_ sender: Any) {
    }
    
    
}
