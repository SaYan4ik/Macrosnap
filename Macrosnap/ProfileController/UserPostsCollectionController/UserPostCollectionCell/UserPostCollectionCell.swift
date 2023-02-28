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
            let thumbnailSize = CGSize(width: 400 * scale, height: 300 * scale)
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
    
    private var likeButtonImage: UIImage? {
        let imageLikeName = didLike ?? false ? "heart.fill" : "heart"
        return UIImage(systemName: imageLikeName)
    }
    
    private var likesLabelText: String {
        guard let post else { return "ERROR: Reload page" }
        if post.like != 1 {
            return "\(post.like) likes"
        }else {
            return "\(post.like) like"
        }
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
    
    func set(post: Post, buttonDelegate: UserPostCollectionButtonDelegate, likeButtonIsSelected: Bool, favButtonIsSelected: Bool) {
        self.post = post
        self.buttonDelegate = buttonDelegate
        setStyleCell()
        self.didLike = likeButtonIsSelected
        self.didFav = favButtonIsSelected
        self.likeButton.setImage(likeButtonImage, for: .normal)
        self.favouriteButton.setImage(favouriteButtonImage, for: .normal)
        self.likeCountLabel.text = "\(post.like)"
    }
    
    private func setStyleCell() {
        self.containerView.layer.cornerRadius = 12
        self.userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.height / 2
        self.postImageView.layer.cornerRadius = 12
    }
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        buttonDelegate?.likeButtonDidTap(sender, likeCount: likeCountLabel, on: self)
    }
    
    @IBAction func commentButtonDidTap(_ sender: UIButton) {
        
    }
    
    @IBAction func favouriteButtonDidTap(_ sender: UIButton) {
        buttonDelegate?.favoriteButtonDidTap(sender, on: self)
    }

    func chekLike(result: Bool) {
        if result {
            likeButton.isSelected = result
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        } else {
            likeButton.isSelected = result
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}

extension UICollectionViewCell {
    func transformToLarge() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    
    func transformToStandard() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
        }
    }
}
