//
//  UserMessages.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class UserMessages{
    let id: String
    let name: String
    let unreadMessages: Bool
    let messageID: String
    
    init(id: String, name: String, messageID: String, unreadMessages: Bool){
        self.id = id
        self.name = name
        self.messageID = messageID
        self.unreadMessages = unreadMessages
    }
}
