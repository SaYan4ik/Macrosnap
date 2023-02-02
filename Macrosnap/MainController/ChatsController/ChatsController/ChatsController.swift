//
//  ChatsController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import MessageKit

class ChatsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChatsView: UIView!
    
    var chats = [Chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupNavBar()
    }
    
    private func setupNavBar() {
        let backButton = UIButton()
        backButton.addTarget(self, action: #selector(backAction), for: .allEvents)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let addNewChatButton = UIButton()
        addNewChatButton.addTarget(self, action: #selector(addUserForChat), for: .allEvents)
        addNewChatButton.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill"), for: .normal)
        addNewChatButton.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addNewChatButton)
    }
    
    @objc private func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addUserForChat() {
        
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        registrationCell()
    }
    
    private func registrationCell() {
        let nib = UINib(nibName: ChatsCell.id, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ChatsCell.id)
    }
    
    

}

extension ChatsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chats.count == 0 {
            noChatsView.isHidden = false
            return 0
        } else {
            noChatsView.isHidden = true
            return chats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatsCell.id, for: indexPath)
        guard let chatsCell = cell as? ChatsCell else { return cell }
        
        return chatsCell
    }
}

extension ChatsController: UITableViewDelegate {
    
}
