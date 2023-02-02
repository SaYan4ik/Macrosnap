//
//  ChatsCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import UIKit
import SDWebImage

class ChatsCell: UITableViewCell {
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    static var id = String(describing: ChatsCell.self)
    
    var user: User? {
        didSet {
            self.userNameLabel.text = user?.username
            
            guard let userUrl = user?.avatarURL else { return }
            guard let userUrlRef = URL(string: userUrl) else { return }
            userAvatarImage.sd_setImage(with: userUrlRef, completed: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setStyle() {
        self.container.layer.cornerRadius = 12
    }
    
}
