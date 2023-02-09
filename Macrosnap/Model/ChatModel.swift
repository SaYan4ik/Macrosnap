//
//  ChatModel.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import Foundation

class Chat {
    var users: [String] = [String]()
    var chatUID: String = ""
    
    init(users: [String], chatUID: String) {
        self.users = users
        self.chatUID = chatUID
        
    }
}
