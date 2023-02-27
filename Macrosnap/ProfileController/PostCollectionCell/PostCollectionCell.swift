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
                guard let imageUrl = post?.postId else { return }
                guard let url = URL(string: imageUrl) else { return }

                let scale = UIScreen.main.scale
                let thumbnailSize = CGSize(width: 200 * scale, height: 200 * scale)

                postImage.sd_setImage(with: url, placeholderImage: nil, options: [.progressiveLoad, .continueInBackground, .refreshCached, .scaleDownLargeImages], context: [ .imageThumbnailPixelSize: thumbnailSize])
                
            }
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
}
