//
//  NotificationFeedCellTableViewCell.swift
//  FocusInterests
//
//  Created by Nicolas on 01/06/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class NotificationFeedCellTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notifImgView: UIImageView!
    @IBOutlet weak var notifContent: UILabel!
    @IBOutlet weak var userProfilePic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(notif: FocusNotification) {
//        self.userProfilePic.image = notif.sender?.username
        let content = (notif.sender?.username)! + " " + (notif.type?.rawValue)! + " " + (notif.item?.itemName!)!
        self.notifContent.text = content
//        self.notifImgView.image = notif.item?.imageURL
        self.timeLabel.text = "2h"
    }
    
}
