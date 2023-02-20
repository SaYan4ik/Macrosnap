//
//  UserModel.swift
//  Macrosnap
//
//  Created by Александр Янчик on 15.11.22.
//

import Foundation
import FirebaseFirestore

class User {
    var uid: String
    var username: String
    var fullName: String
    var avatarURL: String
    
    init(uid: String, username: String, fullName: String, profileURL: String) {
        self.uid = uid
        self.username = username
        self.fullName = fullName
        self.avatarURL = profileURL
    }
}
