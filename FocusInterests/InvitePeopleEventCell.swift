//
//  InvitePeopleEventCell.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InvitePeopleEventCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var inviteOut: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inviteOut.layer.cornerRadius = 6
        inviteOut.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
