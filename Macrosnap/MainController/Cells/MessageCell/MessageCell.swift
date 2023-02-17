//
//  MessageCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 16.02.23.
//

import UIKit
import FirebaseAuth

class MessageCell: UITableViewCell {

    lazy var messageView: UITextView = {
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
    
    lazy var dataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        return label
    }()
    
    private var message: Message?
    private var rightMessageAnchor: NSLayoutConstraint?
    private var leftMessageAnchor: NSLayoutConstraint?
    private var righttDataAnchor: NSLayoutConstraint?
    private var leftDataAnchor: NSLayoutConstraint?
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)

        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(message: Message) {
        self.message = message
        self.messageView.text = message.content
        
        let date = message.created.dateValue()
        self.dataLabel.text = date.timeAgoDisplay()
        
        if message.senderUID == Auth.auth().currentUser?.uid {
            self.rightMessageAnchor?.isActive = true
            self.leftMessageAnchor?.isActive = false
            self.righttDataAnchor?.isActive = true
            self.leftDataAnchor?.isActive = false
        } else {
            self.rightMessageAnchor?.isActive = false
            self.leftMessageAnchor?.isActive = true
            self.righttDataAnchor?.isActive = false
            self.leftDataAnchor?.isActive = true
        }
    }
    
    private func layoutCell() {
        contentView.addSubview(messageView)
        contentView.addSubview(dataLabel)
        
        layoutMessageView()
        layoutDateLabel()
    }
    
    private func layoutMessageView() {

        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            messageView.bottomAnchor.constraint(equalTo: dataLabel.topAnchor, constant: -5),
            messageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        rightMessageAnchor = messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        rightMessageAnchor?.isActive = true
        leftMessageAnchor = messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        leftMessageAnchor?.isActive = false
    }
    
    private func layoutDateLabel() {
        
        NSLayoutConstraint.activate([
            dataLabel.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 5),
            dataLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        righttDataAnchor = dataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        righttDataAnchor?.isActive = true
        leftMessageAnchor = dataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8)
        leftMessageAnchor?.isActive = false
        
    }
    
}

