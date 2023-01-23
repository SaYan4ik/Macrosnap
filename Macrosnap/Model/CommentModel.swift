//
//  CommentModel.swift
//  Macrosnap
//
//  Created by Александр Янчик on 15.12.22.
//

import Foundation
import Firebase

class Comment {
    var commentText: String = ""
    var post: Post
    var date = Timestamp()
    
    internal init(commentText: String, post: Post, date: Timestamp) {
        self.commentText = commentText
        self.post = post
        self.date = date
    }
}

