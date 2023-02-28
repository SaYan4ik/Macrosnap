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
    
    var post: Post? {
        didSet {
            
            self.userNameLabel.text = post?.user.username
            
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: 400 * scale, height: 300 * scale)
            
            guard let userUrl = post?.user.avatarURL else { return }
            guard let userUrlRef = URL(string: userUrl) else { return }
            
            userProfileimage.sd_setImage(
                with: userUrlRef,
                placeholderImage: nil,
                options: [.progressiveLoad, .continueInBackground, .refreshCached, .preloadAllFrames, .waitStoreCache, .scaleDownLargeImages],
                context: [ .imageThumbnailPixelSize: thumbnailSize, .imageScaleFactor : 3]
            )
            
            guard let postUrl = post?.postId else { return }
            guard let postUrlRef = URL(string: postUrl) else { return }
            
            userPostImage.sd_setImage(
                with: postUrlRef,
                placeholderImage: nil,
                options: [.progressiveLoad, .continueInBackground, .refreshCached, .preloadAllFrames, .waitStoreCache, .scaleDownLargeImages],
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
        buttonDelegate?.likeButtonDidTap(sender, likeCount: likeCountLabel, on: self)
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
        buttonDelegate?.favoriteButtonDidTap(sender, on: self)
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
}

// MARK: -
// MARK: - PostsConfigure

extension PostsCell {
    func set(delegate: ButtonDelegate?, post: Post, likeButtonIsSelected: Bool, favButtonIsSelected: Bool) {
        self.post = post
        self.buttonDelegate = delegate
        self.didLike = likeButtonIsSelected
        self.didFav = favButtonIsSelected
//        print("TEST TEST TEST Like \(likeButtonIsSelected)")
//        print("TEST TEST TEST Fav \(favButtonIsSelected)")
        self.likeButton.setImage(likeButtonImage, for: .normal)
        self.favouriteButton.setImage(favouriteButtonImage, for: .normal)
        self.likeCountLabel.text = "\(post.like)"
        setStyle()
    }
    
    private func setStyle() {
        userProfileimage.layer.cornerRadius = userProfileimage.frame.height / 2
        self.container.layer.cornerRadius = 12
        self.userPostImage.layer.cornerRadius = 12
    }
    
}
