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

class ChatsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noChatsView: UIView!
    
    var chats = [Chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getChats()
        configureTableView()
        setupNavBar()
    }
    
    private func setupNavBar() {
        let backButton = UIButton()
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let addNewChatButton = UIButton()
        addNewChatButton.addTarget(self, action: #selector(addUserForChat), for: .touchUpInside)
        addNewChatButton.setImage(UIImage(systemName: "bubble.left.and.bubble.right.fill"), for: .normal)
        addNewChatButton.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addNewChatButton)
    }
    
    @objc private func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addUserForChat() {
        let nib = String(describing: FollowersController.self)
        let newUserChat = FollowersController(nibName: nib, bundle: nil)
        newUserChat.set(type: .openChat)
        navigationController?.pushViewController(newUserChat, animated: true)
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
    
    private func getChats() {
        let db = Firestore.firestore().collection("chats").whereField("currentUserUID", arrayContains: Auth.auth().currentUser?.uid ?? "Not found user 1")
        db.getDocuments { (chatSnapshot, error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            } else {
                var allChats = [Chat]()
                guard let chatSnapshot else { return }
                chatSnapshot.documents.forEach { document in
                    let data = document.data()
                    guard let users = data["users"] as? [String] else { return }
                    let chat = Chat(users: users)
                    allChats.append(chat)
                }
                self.chats = allChats
            }
        }
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
        chatsCell.chat = chats[indexPath.row]
        
        
        return chatsCell
    }
}

extension ChatsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nib = String(describing: ChatWithUserController.self)
        let chatVC = ChatWithUserController(nibName: nib, bundle: nil)
        chatVC.chat = chats[indexPath.row]
        chatVC.chatUserUID = chats[indexPath.row].users[1]
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
