//
//  UserPostCollectionCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 25.02.23.
//

import UIKit
import SDWebImage

class UserPostCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentButtn: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var post: Post? {
        didSet {
            self.userNameLabel.text = post?.user.username
            
            guard let userAvatarURL = post?.user.avatarURL else { return }
            guard let userURLRef = URL(string: userAvatarURL) else { return }
            
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: 200 * scale, height: 150 * scale)
            userAvatarImageView.sd_setImage(
                with: userURLRef,
                placeholderImage: nil,
                options: [.progressiveLoad, .continueInBackground, .refreshCached, .preloadAllFrames, .waitStoreCache, .scaleDownLargeImages],
                context: [ .imageThumbnailPixelSize: thumbnailSize, .imageScaleFactor : 3]
            )
            
            guard let postURL = post?.postId else { return }
            guard let postURLRef = URL(string: postURL) else { return }
            
            postImageView.sd_setImage(
                with: postURLRef,
                placeholderImage: nil,
                options: [.progressiveLoad, .continueInBackground, .refreshCached, .preloadAllFrames, .waitStoreCache, .scaleDownLargeImages],
                context: [ .imageThumbnailPixelSize: thumbnailSize, .imageScaleFactor : 3]
            )
            
        }
    }
    
    static var id = String(describing: UserPostCollectionCell.self)
    weak var buttonDelegate: UserPostCollectionButtonDelegate?
    private var didLike: Bool?
    private var didFav: Bool?
    private var postsType: ProfilePostType = .digitalPosts
    
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

    private func setStyleCell() {
        self.containerView.layer.cornerRadius = 12
        self.userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.height / 2
        self.postImageView.layer.cornerRadius = 12
        self.likeButton.setImage(likeButtonImage, for: .normal)
        self.favouriteButton.setImage(favouriteButtonImage, for: .normal)
    }
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        likeButtonAction()
        animateShapeButton(button: sender)
    }
    
    @IBAction func commentButtonDidTap(_ sender: UIButton) {
        let commentNib = String(describing: CommentsController.id)
        let commentVC = CommentsController(nibName: commentNib, bundle: nil)
        commentVC.post = post
        buttonDelegate?.present(vc: commentVC)
        print("Comment did tap")
    }
    
    @IBAction func favouriteButtonDidTap(_ sender: UIButton) {
        favouriteActionButton()
        animateShapeButton(button: sender)
    }
    
    func set(post: Post, buttonDelegate: UserPostCollectionButtonDelegate, likeButtonIsSelected: Bool, favButtonIsSelected: Bool, postsType: ProfilePostType) {
        self.post = post
        self.buttonDelegate = buttonDelegate
        self.didLike = likeButtonIsSelected
        self.didFav = favButtonIsSelected
        self.likeCountLabel.text = "\(post.like)"
        self.postsType = postsType
        setStyleCell()
        setupFavouriteButton()
    }
    
    private func setupFavouriteButton() {
        guard let post else { return }
        if postsType == .favouritePosts {
            self.likeButton.isHidden = true
            self.likeCountLabel.text = {
                if post.like != 1 {
                    return "\(post.like) likes"
                }else {
                    return "\(post.like) like"
                }
            }()
        }
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
        
        switch postsType {
            case .digitalPosts :
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
                
            case .filmPosts:
                FirebaseSingolton.shared.checkLikeByUser(post: post) { (didLike) in
                    if didLike {
                        FirebaseSingolton.shared.disLikeFilmPost(post: post)
                        self.didLike = false
                        self.likeButton.setImage(self.likeButtonImage, for: .normal)
                        post.like = post.like - 1
                        self.likeCountLabel.text = "\(post.like)"
                        
                    } else {
                        
                        FirebaseSingolton.shared.likeFilmPost(post: post)
                        self.didLike = false
                        self.likeButton.setImage(self.likeButtonImage, for: .normal)
                        post.like = post.like + 1
                        self.likeCountLabel.text = "\(post.like)"
                    }
                }
                
            case .favouritePosts:
                break
        }
    }
    
    private func favouriteActionButton() {
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

