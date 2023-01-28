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
    
    @IBOutlet weak var favouriteButton: UIButton!
    
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
            userPostImage.sd_setImage(with: postUrlRef, placeholderImage: UIImage(systemName: "HoneyBee"), options: [.progressiveLoad, .continueInBackground, .refreshCached], context: [ .imageThumbnailPixelSize: thumbnailSize])
            
            self.likeCountLabel.text = "\(post?.like ?? 0)"
            chekLike()
            chekFavourite()
            
        }
    }

    static var id = String(describing: PostsCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func likeButtonDidTap(_ sender: Any) {
        guard let post else { return }
        buttonDelegate?.likeButtonDidTap(post: post, button: likeButton)
        animateLike()
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
        guard let post else { return }
        buttonDelegate?.favoriteButtonDidTap(post: post, button: favouriteButton)
        animateFavButton()
        print("Favorite did tap")
        
    }
    
    private func animateLike() {
        UIView.animate(withDuration: 0.5,
            animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self.likeButton.transform = CGAffineTransform.identity
                }
            })
    }
    
    private func animateFavButton() {
        UIView.animate(withDuration: 0.5,
            animations: {
            self.favouriteButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6) {
                    self.favouriteButton.transform = CGAffineTransform.identity
                }
            })
    }
    
}

// MARK: -
// MARK: - PostsConfigure

extension PostsCell {
    
    func set(delegate: ButtonDelegate?, typePost: PostType) {
        self.buttonDelegate = delegate
        self.type = typePost
        setStyle()

    }
    
    private func setStyle() {
        userProfileimage.layer.cornerRadius = userProfileimage.frame.height / 2
        self.contentView.layer.cornerRadius = 12
    }
    
    private func chekLike() {
        guard let post else { return }
        
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
    
    private func chekFavourite() {
        guard let post else { return }
        
        FirebaseSingolton.shared.checkFavByUser(post: post) { postExist in
            if postExist == true {
                self.favouriteButton.isSelected = true
                self.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            } else {
                self.favouriteButton.isSelected = false
                self.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
    
}
