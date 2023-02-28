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
    func likeButtonDidTap(_ likeButton: UIButton, likeCount: UILabel, on cell: PostsCell)
    func favoriteButtonDidTap(_ favouriteButton: UIButton, on cell: PostsCell)
}

// MARK: -
// MARK: - UserPostCollectionButtonDelegate
protocol UserPostCollectionButtonDelegate: AnyObject {
    func present(vc: UIViewController)
    func push(vc: UIViewController)
    func likeButtonDidTap(_ likeButton: UIButton, likeCount: UILabel, on cell: UserPostCollectionCell)
    func favoriteButtonDidTap(_ favouriteButton: UIButton, on cell: UserPostCollectionCell)
}

//MARK: -
//MARK: - CommentCellProtocol
protocol CommentButtonDelegate: AnyObject {
    func likeCommentButtonDidTap(comment: Comment, button: UIButton)
}
