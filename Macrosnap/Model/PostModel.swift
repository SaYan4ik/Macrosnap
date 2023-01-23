//
//  PostModel.swift
//  Macrosnap
//
//  Created by Александр Янчик on 15.11.22.
//

import Foundation

class Post {
    var user: User
    var postId: String = ""
    var userId: String = ""
    var lense: String = ""
    var camera: String = ""
    var description: String = ""

    var like: Int = 0
    var likeCurrentUser: Bool = false
    
    init(user: User, postId: String, userId: String, lense: String, camera: String, description: String, like: Int) {
        self.user = user
        self.postId = postId
        self.userId = userId
        self.lense = lense
        self.camera = camera
        self.description = description
        self.like = like

    }
}
