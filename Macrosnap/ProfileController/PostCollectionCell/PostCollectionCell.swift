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
    
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
