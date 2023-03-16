//
//  PostCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 17.11.22.
//

import UIKit
import SDWebImage

class PostCollectionCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
    
    static var id = String(describing: PostCollectionCell.self)
    
    var post: Post? {
            didSet {
                
                guard let postURL = post?.postId else { return }
                guard let postURLRef = URL(string: postURL) else { return }

                let scale = UIScreen.main.scale
                let thumbnailSize = CGSize(width: 400 * scale, height: 300 * scale)

                postImage.sd_setImage(
                    with: postURLRef,
                    placeholderImage: nil,
                    options: [
                        .progressiveLoad,
                        .continueInBackground,
                        .preloadAllFrames,
                        .waitStoreCache,
                        .scaleDownLargeImages
                    ],
                    context: [
                        .imageThumbnailPixelSize: thumbnailSize,
                        .imageScaleFactor : 3
                    ]
                )
            }
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
