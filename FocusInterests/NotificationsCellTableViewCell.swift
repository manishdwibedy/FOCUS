//
//  NotificationsCellTableViewCell.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class NotificationsCellTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellActionLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(notification: Notification) {
        self.cellImage.image = notification.sender?.userImage
        self.cellImage.roundedImage()
        self.cellTitleLabel.text = notification.sender?.username!
        self.cellActionLabel.text = notification.type?.rawValue
        self.eventLabel.text = notification.item?.itemName!
    }
    
}
