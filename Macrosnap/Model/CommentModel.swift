//
//  CommentModel.swift
//  Macrosnap
//
//  Created by Александр Янчик on 15.12.22.
//

import Foundation
import Firebase

class Comment {
    var senderName: String = ""
    var senderUID: String = ""
    var senderAvatarURL: String = ""
    var commentText: String = ""
    var post: Post
    var date = Timestamp()
    
    init(senderName: String, senderUID: String, senderAvatarURL: String, commentText: String, post: Post, date: Timestamp ) {
        self.senderName = senderName
        self.senderUID = senderUID
        self.senderAvatarURL = senderAvatarURL
        self.commentText = commentText
        self.post = post
        self.date = date
    }
}

