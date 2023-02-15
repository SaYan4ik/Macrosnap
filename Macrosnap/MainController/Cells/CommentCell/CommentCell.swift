//
//  CommentCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 28.12.22.
//

import UIKit
import SDWebImage

class CommentCell: UITableViewCell {
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var dataOfCreateCommentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    weak var buttonDelegate: CommentButtonDelegate?
    static var id = String(describing: CommentCell.self)
    
    var comment: Comment? {
        didSet {
            self.usernameLabel.text = comment?.post.user.username
            
            guard let userUrl = comment?.post.user.avatarURL else { return }
            guard let userUrlRef = URL(string: userUrl) else { return }
            userAvatarImage.sd_setImage(with: userUrlRef, completed: nil)
            
            self.commentTextLabel.text = comment?.commentText
            guard let date = comment?.date.dateValue() else { return }
            self.dataOfCreateCommentLabel.text = date.timeAgoDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setStyle()
    }

}

//MARK: -
//MARK: - CommentCellConfigure

extension CommentCell {
    private func setStyle() {
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.height / 2
        self.contentView.layer.cornerRadius = 12
        self.containerView.layer.cornerRadius = 12
    }
    
    func set(delegate: CommentButtonDelegate?) {
        self.buttonDelegate = delegate
    }

}
