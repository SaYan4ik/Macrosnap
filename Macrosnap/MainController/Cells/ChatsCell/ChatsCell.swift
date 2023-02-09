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
    
    var chat: Chat?
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
    
    func set(chat: Chat) {
        self.chat = chat
        FirebaseSingolton.shared.getUserWithUID(uid: chat.users[1]) { user in
            self.user = user
        }
        self.setStyle()
    }
    
    
    private func setStyle() {
        self.container.layer.cornerRadius = 12
        self.userAvatarImage.layer.cornerRadius = self.userAvatarImage.frame.height / 2
    }
    
    private func getChatUserInfo() {
        guard let chat else { return }
        FirebaseSingolton.shared.getUserWithUID(uid: chat.users[1]) { user in
            self.user = user
        }
    }
    
}
