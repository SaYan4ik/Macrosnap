//
//  Protocols.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import Foundation
import UIKit


// MARK: -
// MARK: - PostCellProtocol
protocol ButtonDelegate: AnyObject {
    func present(vc: UIViewController)
    func push(vc: UIViewController)
    func likeButtonDidTap(post: Post, button: UIButton)
    func favoriteButtonDidTap(post: Post, button: UIButton)
}

// MARK: -
// MARK: - UserPostCollectionButtonDelegate
protocol UserPostCollectionButtonDelegate: AnyObject {
    func present(vc: UIViewController)
    func push(vc: UIViewController)
    func likeButtonDidTap(_ likeButton: UIButton, on cell: UserPostCollectionCell)
    func favoriteButtonDidTap(_ favouriteButton: UIButton, on cell: UserPostCollectionCell)
}

//MARK: -
//MARK: - CommentCellProtocol
protocol CommentButtonDelegate: AnyObject {
    func likeCommentButtonDidTap(comment: Comment, button: UIButton)
}
