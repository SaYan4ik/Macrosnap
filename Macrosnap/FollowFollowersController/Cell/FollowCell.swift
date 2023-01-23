//
//  FollowCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 21.12.22.
//

import UIKit

class FollowCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User? {
        didSet {
            self.usernameLabel.text = user?.username
            
            guard let imageUrl = user?.avatarURL else { return }
            guard let url = URL(string: imageUrl) else { return }
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: 200 * scale, height: 200 * scale)
            avatarImageView.sd_setImage(with: url, placeholderImage: nil, options: [.progressiveLoad, .continueInBackground, .refreshCached], context: [ .imageThumbnailPixelSize: thumbnailSize])
            
        }
    }
    static var id = String(describing: FollowCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setStyle()

    }
    
    
    
    
}

//MARK: -
//MARK: - SetStyle
extension FollowCell {
    private func setStyle() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        
    }
}
