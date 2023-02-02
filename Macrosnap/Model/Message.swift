//
//  Message.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import Foundation
import Firebase

class Message {
    var id: String
    var content: String
    var created: Timestamp
    var senderUID: String
    var senderName: String
    
    init(id: String, content: String, created: Timestamp, senderUID: String, senderName: String) {
        self.id = id
        self.content = content
        self.created = created
        self.senderUID = senderUID
        self.senderName = senderName
    }
}

