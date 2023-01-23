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
    @IBOutlet weak var likeCommentButton: UIButton!
    
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
    
    @IBAction func likeCommentButtonDidTap(_ sender: Any) {
        guard let comment else { return }
        buttonDelegate?.likeCommentButtonDidTap(comment: comment, button: likeCommentButton)
    }
    
}

//MARK: -
//MARK: - CommentCellConfigure

extension CommentCell {
    private func setStyle() {
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.height / 2
    }
    
    func set(delegate: CommentButtonDelegate?) {
        self.buttonDelegate = delegate
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.3) {
            self.likeCommentButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.6) {
                self.likeCommentButton.transform = CGAffineTransform.identity
            }
        }
    }
}
