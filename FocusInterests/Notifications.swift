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
}

import Foundation

class Notification {
    
    var type: NotificationType?
    var sender: User?
    var item: ItemOfInterest?
    
    init(type: NotificationType?, sender: User?, item: ItemOfInterest?) {
        self.type = type
        self.sender = sender
        self.item = item
    }
}
