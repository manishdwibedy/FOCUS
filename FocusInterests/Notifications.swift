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
    case Comment = "commented on your pin - "
    case Pin = "pinned"
    case Going = "is going to"
    case Created = "create an event "
}

import Foundation

class FocusNotification: Hashable, Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: FocusNotification, rhs: FocusNotification) -> Bool {
        return lhs.time == rhs.time && lhs.type == rhs.type && lhs.item?.id == rhs.item?.id
    }

    
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
    
    var hashValue : Int {
        get {
            return "\(self.time)".hashValue
        }
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
