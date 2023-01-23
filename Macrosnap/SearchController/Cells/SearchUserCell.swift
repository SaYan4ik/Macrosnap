//
//  SearchUserCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 29.11.22.
//

import UIKit
import SDWebImage

class SearchUserCell: UITableViewCell {

    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    static var id = String(describing: SearchUserCell.self)
    
    var user: User? {
        didSet {
            self.usernameLabel.text = user?.username
            
            guard let avatarURL = user?.avatarURL else { return }
            guard let url = URL(string: avatarURL) else { return }
            userAvatarImage.sd_setImage(with: url)
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userAvatarImage.layer.cornerRadius = userAvatarImage.frame.height / 2
    }
    
}
