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
    var readMessages: Bool
    let messageID: String
    var lastMessageDate: Date
    
    init(id: String, name: String, messageID: String, readMessages: Bool, lastMessageDate: Date){
        self.id = id
        self.name = name
        self.messageID = messageID
        self.readMessages = readMessages
        self.lastMessageDate = lastMessageDate
    }
}
