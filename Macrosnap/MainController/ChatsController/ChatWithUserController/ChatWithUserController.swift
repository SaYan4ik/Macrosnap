//
//  ChatWithUserController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class ChatWithUserController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var mesageField: UITextField!
    
    private var messages = [Message]()
    var chatUserUID: String = ""
    private var docReference: DocumentReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    private func setupNavBar() {
        let button = UIButton()
        button.addTarget(self, action: #selector(backAction), for: .allEvents)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private func createChat() {
        guard let  curentUserUID = Auth.auth().currentUser?.uid else { return }
        let chat = Chat(users: [curentUserUID, chatUserUID])
        
        Firestore.firestore().collection("Chats").document(curentUserUID).setData([
            "users": chat
        ]) { error in
            if error != nil {
                print("Unable create chat \(String(describing: error?.localizedDescription))")
            }
            print("Succses create chat")
        }
    }
    
    private func getChat(complition: @escaping (Chat) -> Void) {
        let db = Firestore.firestore().collection("Chats").whereField("currentUserUID", arrayContains: Auth.auth().currentUser?.uid ?? "Not found user 1")
        db.getDocuments { (chatSnapshot, error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            } else {
                guard let queryCount = chatSnapshot?.documents.count else { return }
                
                if queryCount == 0 {
                    self.createChat()
                } else if queryCount >= 1 {
                    guard let chatSnapshot else { return }
                    chatSnapshot.documents.forEach { document in
                        let data = document.data()
                        guard let users = data["users"] as? [String] else { return }
                        let chat = Chat(users: users)
                        complition(chat)
                    }
                }
            }
        }
    }
    
    private func getMessagesForChat(chat: Chat) {
        if chat.users.contains(self.chatUserUID) {
            Firestore.firestore().collection("Chats").document(Auth.auth().currentUser?.uid ?? "Not found user 1").collection("Messages").order(by: "created", descending: false).addSnapshotListener(includeMetadataChanges: true) { ( messageSnapshot, error ) in
                
                if let error = error {
                    print("Error \(error.localizedDescription)")
                    return
                } else {
                    self.messages.removeAll()
                    guard let messageSnapshot else { return }
                    for message in messageSnapshot.documents {
                        let data = message.data()
                        guard let id = data["id"] as? String,
                              let content = data["content"] as? String,
                              let created = data["created"] as? Timestamp,
                              let senderUID = data["senderUID"] as? String,
                              let senderName = data["senderName"] as? String
                        else { return }
                        
                        let msg = Message(id: id, content: content, created: created, senderUID: senderUID, senderName: senderName)
                        self.messages.append(msg)
                    }
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count, section: 0), at: .bottom, animated: false)
                }
            }
            return
        }
        self.createChat()
    }
    
    private func setupChat() {
        getChat { chat in
            self.getMessagesForChat(chat: chat)
        }
    }
    
    private func saveMessage() {
        
    }
    
}


extension ChatWithUserController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}

extension ChatWithUserController: UICollectionViewDelegate {
    
}


