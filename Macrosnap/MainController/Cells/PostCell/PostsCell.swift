//
//  PostsCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import UIKit
import SDWebImage

class PostsCell: UITableViewCell {

    @IBOutlet weak var userProfileimage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPostImage: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var buttonDelegate: ButtonDelegate?
    private var type: PostType = .digitalPhoto
    
    var post: Post? {
        didSet {
            
            self.userNameLabel.text = post?.user.username
            
            guard let userUrl = post?.user.avatarURL else { return }
            guard let userUrlRef = URL(string: userUrl) else { return }
            userProfileimage.sd_setImage(with: userUrlRef, completed: nil)
            
            guard let postUrl = post?.postId else { return }
            guard let postUrlRef = URL(string: postUrl) else { return }
            
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: 200 * scale, height: 200 * scale)
            userPostImage.sd_setImage(with: postUrlRef, placeholderImage: UIImage(named: "HoneyBee"), options: [.progressiveLoad, .continueInBackground, .refreshCached], context: [ .imageThumbnailPixelSize: thumbnailSize])
            
            self.likeCountLabel.text = "\(post?.like ?? 0)"
            setStyle()
            chekLike()
            
        }
    }

    static var id = String(describing: PostsCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    @IBAction func likeButtonDidTap(_ sender: Any) {
        guard let post else { return }
        buttonDelegate?.likeButtonDidTap(post: post, button: likeButton)
        animate()
        print("Like did tap")
    }
    
    @IBAction func commentsbuttonDidTap(_ sender: Any) {
        let commentNib = String(describing: CommentsController.id)
        let commentVC = CommentsController(nibName: commentNib, bundle: nil)
        commentVC.post = post
        buttonDelegate?.present(vc: commentVC)
        print("Comment did tap")
    }
    
    
    @IBAction func favoriteButtonDidTap(_ sender: Any) {
        buttonDelegate?.favoriteButtonDidTap()
        print("Favorite did tap")
        
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.3,
            animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6) {
                    self.likeButton.transform = CGAffineTransform.identity
                }
            })
    }
}

// MARK: -
// MARK: - PostsConfigure

extension PostsCell {
    
    func set(delegate: ButtonDelegate?) {
        self.buttonDelegate = delegate
    }
    
    private func setStyle() {
        userProfileimage.layer.cornerRadius = userProfileimage.frame.height / 2
    }
    
    private func chekLike() {
        guard let post = post else { return }
        
        FirebaseSingolton.shared.checkLikeByUser(post: post) { postExist in
            if postExist == true {
                self.likeButton.isSelected = true
                self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
            } else {
                self.likeButton.isSelected = false
                self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
        
    }
    
}
