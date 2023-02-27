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
    @IBOutlet weak var userNameLAbel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentButtn: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    private var post: Post? {
        didSet {
            guard let userAvatarURL = post?.user.avatarURL else { return }
            guard let userURLRef = URL(string: userAvatarURL) else { return }
            
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: 150 * scale, height: 150 * scale)
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
            
            self.likeCountLabel.text = "\(post?.like ?? 0)"
            
        }
    }
    
    static var id = String(describing: UserPostCollectionCell.self)
    weak var buttonDelegate: ButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func set(post: Post, buttonDelegate: ButtonDelegate) {
        self.post = post
        self.buttonDelegate = buttonDelegate
    }

}
