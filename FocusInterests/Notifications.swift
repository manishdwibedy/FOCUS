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
    case Following = "is following you"
}


import Foundation

class FocusNotification: NSObject, NSCoding{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: FocusNotification, rhs: FocusNotification) -> Bool {
        return lhs.type == rhs.type && lhs.item?.id == rhs.item?.id && lhs.time == rhs.time
        
    }

    enum notif_type{
        case notification
        case invite
    }

    
    var type: NotificationType?
    var sender: NotificationUser?
    var item: ItemOfInterest?
    var time: Date?
    var notif_type: notif_type?
    
    init(type: NotificationType?, sender: NotificationUser?, item: ItemOfInterest?, time: Date) {
        self.type = type
        self.sender = sender
        self.item = item
        self.time = time
    }
    
    override var hashValue : Int {
        get {
            return "\(self.time)".hashValue
        }
    }
    
    required init(coder decoder: NSCoder) {
        self.type = NotificationType(rawValue: (decoder.decodeObject(forKey: "type") as? String)!)
        self.sender = decoder.decodeObject(forKey: "sender") as? NotificationUser
        self.item = decoder.decodeObject(forKey: "item") as? ItemOfInterest
        self.time = decoder.decodeObject(forKey: "time") as? Date
        
        switch(decoder.decodeObject(forKey: "notif_type") as! String){
            case "notifications":
                self.notif_type = .notification
            case "invite":
                self.notif_type = .invite
            default:
                break
        }
        
        
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.type?.rawValue, forKey: "type")
        coder.encode(self.sender, forKey: "sender")
        coder.encode(self.item, forKey: "item")
        coder.encode(self.time, forKey: "time")
        if let type = self.notif_type{
            switch(type){
            case notif_type.notification:
                coder.encode("notifications", forKey: "notif_type")
            case notif_type.invite:
                coder.encode("invite", forKey: "notif_type")
            }
        }
        else{
            coder.encode("", forKey: "notif_type")
        }
        
    }
    
}


class NotificationUser: NSObject, NSCoding{
    
    var username: String?
    var uuid: String?
    var imageURL: String?
    
    init(username: String?, uuid: String?, imageURL: String?) {
        self.username =  username
        self.uuid = uuid
        self.imageURL = imageURL
    }
    
    required init(coder decoder: NSCoder) {
        self.username = decoder.decodeObject(forKey: "username") as? String ?? ""
        self.uuid = decoder.decodeObject(forKey: "uuid") as? String ?? ""
        self.imageURL = decoder.decodeObject(forKey: "imageURL") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.username, forKey: "username")
        coder.encode(self.uuid, forKey: "uuid")
        coder.encode(self.imageURL, forKey: "imageURL")
    }
}
