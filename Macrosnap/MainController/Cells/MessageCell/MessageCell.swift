//
//  MessageCell.swift
//  Macrosnap
//
//  Created by Александр Янчик on 5.02.23.
//

import UIKit

class MessageCell: UICollectionViewCell {
    @IBOutlet weak var textMessage: UILabel!
    
    static var id = String(describing: MessageCell.self)
    var message: Message? {
        didSet {
            self.textMessage.text = message?.content
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
