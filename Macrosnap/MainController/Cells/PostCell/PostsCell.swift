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
    @IBOutlet weak var container: UIStackView!
    
    weak var buttonDelegate: ButtonDelegate?
    private var type: PostType = .digitalPost
    
    var post: Post? {
        didSet {
            
            self.userNameLabel.text = post?.user.username
            
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: 200 * scale, height: 150 * scale)
            
            guard let userUrl = post?.user.avatarURL else { return }
            guard let userUrlRef = URL(string: userUrl) else { return }
            
            userProfileimage.sd_setImage(
                with: userUrlRef,
                placeholderImage: nil,
                options: [.progressiveLoad, .continueInBackground, .preloadAllFrames, .waitStoreCache, .scaleDownLargeImages],
                context: [ .imageThumbnailPixelSize: thumbnailSize, .imageScaleFactor : 3]
            )
            
            guard let postUrl = post?.postId else { return }
            guard let postURLRef = URL(string: postUrl) else { return }
            
            userPostImage.sd_setImage(
                with: postURLRef,
                placeholderImage: nil,
                options: [.progressiveLoad, .continueInBackground, .preloadAllFrames, .waitStoreCache, .scaleDownLargeImages],
                context: [ .imageThumbnailPixelSize: thumbnailSize, .imageScaleFactor : 3]
            )
            
        }
    }

    static var id = String(describing: PostsCell.self)
    private var didLike: Bool?
    private var didFav: Bool?
    
    private var likeButtonImage: UIImage? {
        let imageLikeName = didLike ?? false ? "heart.fill" : "heart"
        return UIImage(systemName: imageLikeName)
    }
    
    private var likesLabelText: String {
        guard let post else { return "ERROR: Reload page" }
        return "\(post.like)"
    }

    
    private var favouriteButtonImage: UIImage? {
        let imageFavouriteName = didFav ?? false ? "star.fill" : "star"
        return UIImage(systemName: imageFavouriteName)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.likeButton.setImage(likeButtonImage, for: .normal)
        self.likeCountLabel.text = likesLabelText
        self.favouriteButton.setImage(favouriteButtonImage, for: .normal)

    }
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        likeButtonAction()
        animateShapeButton(button: sender)
        print("Like did tap")
    }
    
    @IBAction func commentsbuttonDidTap(_ sender: Any) {
        let commentNib = String(describing: CommentsController.id)
        let commentVC = CommentsController(nibName: commentNib, bundle: nil)
        commentVC.post = post
        buttonDelegate?.present(vc: commentVC)
        print("Comment did tap")
    }
    
    
    @IBAction func favoriteButtonDidTap(_ sender: UIButton) {
        favouriteButtonAction()
        animateShapeButton(button: sender)
    }
    
    private func animateShapeButton(button: UIButton) {
        UIView.animate(withDuration: 0.5,
                       animations: {
            button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.5) {
                button.transform = CGAffineTransform.identity
            }
        })
    }
    
    private func likeButtonAction() {
        guard let post else { return }
        post.likeByCurrenUser.toggle()
        FirebaseSingolton.shared.checkLikeByUser(post: post) { (didLike) in
            if didLike {
                FirebaseSingolton.shared.disLikePost(post: post)
                self.didLike = false
                self.likeButton.setImage(self.likeButtonImage, for: .normal)
                post.like = post.like - 1
                self.likeCountLabel.text = "\(post.like)"
                
            } else {
                
                FirebaseSingolton.shared.likePost(post: post)
                self.didLike = true
                self.likeButton.setImage(self.likeButtonImage, for: .normal)
                post.like = post.like + 1
                self.likeCountLabel.text = "\(post.like)"
            }
        }
    }
    
    private func favouriteButtonAction() {
        guard let post else { return }
        post.favouriteByCurenUser.toggle()
        FirebaseSingolton.shared.checkFavByUser(post: post) { (didFav) in
            if didFav {
                FirebaseSingolton.shared.removeFavPost(post: post)
                self.didFav = false
                self.favouriteButton.setImage(self.favouriteButtonImage, for: .normal)
            } else {
                FirebaseSingolton.shared.favouritePost(post: post)
                self.didFav = true
                self.favouriteButton.setImage(self.favouriteButtonImage, for: .normal)
            }
        }
    }
}

// MARK: -
// MARK: - PostsConfigure

extension PostsCell {
    func set(delegate: ButtonDelegate?, post: Post, likeButtonIsSelected: Bool, favButtonIsSelected: Bool, type: PostType) {
        self.post = post
        self.buttonDelegate = delegate
        self.didLike = likeButtonIsSelected
        self.didFav = favButtonIsSelected
        self.likeCountLabel.text = "\(post.like)"
        self.type = type
        setStyle()
    }
    
    private func setStyle() {
        userProfileimage.layer.cornerRadius = userProfileimage.frame.height / 2
        self.container.layer.cornerRadius = 12
        self.userPostImage.layer.cornerRadius = 12
        self.likeButton.setImage(likeButtonImage, for: .normal)
        self.favouriteButton.setImage(favouriteButtonImage, for: .normal)
    }

}
