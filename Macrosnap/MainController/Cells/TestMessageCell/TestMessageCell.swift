//
//  TestMessageCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 16.02.23.
//

import UIKit
import FirebaseAuth

class TestMessageCell: UITableViewCell {

    let messageView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 54/255, green: 45/255, blue: 136/255, alpha: 1.0)
        textView.textAlignment = .natural
        textView.font = UIFont(name: "Charter", size: 16 )
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 8
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    var message: Message?
    var rightMessageAnchor: NSLayoutConstraint?
    var leftMessageAnchor: NSLayoutConstraint?
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        layoutMessageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(message: Message) {
        self.message = message
        self.messageView.text = message.content

        if message.senderUID == Auth.auth().currentUser?.uid {
            self.rightMessageAnchor?.isActive = true
            self.leftMessageAnchor?.isActive = false
        } else {
            self.rightMessageAnchor?.isActive = false
            self.leftMessageAnchor?.isActive = true
        }
    }

    
    private func layoutMessageView() {
        contentView.addSubview(messageView)
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            messageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        rightMessageAnchor = messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        rightMessageAnchor?.isActive = true
        leftMessageAnchor = messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        leftMessageAnchor?.isActive = true
    }
    
}
