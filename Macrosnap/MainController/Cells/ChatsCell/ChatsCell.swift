//
//  ChatsCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import UIKit
import SDWebImage
import FirebaseAuth

class ChatsCell: UITableViewCell {
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var chatWithUserLabe: UILabel!
    
    
    @IBOutlet weak var container: UIView!
    
    static var id = String(describing: ChatsCell.self)
    
    var chat: Chat?
    var user: User? {
        didSet {            
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
        self.setStyle()
        getChatUserInfo(chat: chat)
        getLastMessage()
        
    }
    
    private func getLastMessage() {
        guard let chat else { return }
        
        FirebaseSingolton.shared.getLastMessage(chat: chat) { message in
            self.lastMessageLabel.text = "Last message \(message.senderName): \(message.content)"
            
        }
    }

    
    private func setStyle() {
        self.container.layer.cornerRadius = 12
        self.userAvatarImage.layer.cornerRadius = self.userAvatarImage.frame.height / 2
    }
    
    private func getChatUserInfo(chat: Chat) {
        if chat.users.first != Auth.auth().currentUser?.uid {
            FirebaseSingolton.shared.getUserWithUID(uid: chat.users[0]) { user in
                self.chatWithUserLabe.text = "Chat with: \(user.username) "
                self.user = user
            }
        } else {
            FirebaseSingolton.shared.getUserWithUID(uid: chat.users[1]) { user in
                self.chatWithUserLabe.text = "Chat with: \(user.username)"
                self.user = user
            }
        }
    }
    
}
