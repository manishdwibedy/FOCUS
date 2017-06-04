//
//  Notifications.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

enum NotificationType: String {
    case Like = "liked"
    case Invite = "invited you to"
    case Tag = "tagged you in"
    case Comment = "commented on"
    case Pin = "pinned"
    case Going = "is going to"
}

import Foundation

class FocusNotification {
    
    var type: NotificationType?
    var sender: NotificationUser?
    var item: ItemOfInterest?
    var time: Date?
    
    init(type: NotificationType?, sender: NotificationUser?, item: ItemOfInterest?, time: Date) {
        self.type = type
        self.sender = sender
        self.item = item
        self.time = time
    }
}


class NotificationUser {
    
    var username: String?
    var uuid: String?
    var imageURL: String?
    
    init(username: String?, uuid: String?, imageURL: String?) {
        self.username =  username
        self.uuid = uuid
        self.imageURL = imageURL
    }
}
