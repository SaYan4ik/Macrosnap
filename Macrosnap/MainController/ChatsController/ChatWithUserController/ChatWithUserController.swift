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
    @IBOutlet weak var mesageField: UITextField!
    
    var chatUserUID: String = ""
    var chat: Chat?
    var user: User?
    private var docReference: DocumentReference?
    private var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadChat()
        self.getUser()
        setupNavBar()
        self.setupCollection()

    }
    
    private func setupCollection() {
        self.collectionView.dataSource = self
        self.registerCell()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: MessageCell.id, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: MessageCell.id)
    }
    
    private func setupNavBar() {
        let button = UIButton()
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func sendMessageButtonDidTap(_ sender: Any) {
        guard let user else { return }
        saveMessage(user: user)
    }
    
// create chat
    private func createChat() {
        guard let  curentUserUID = Auth.auth().currentUser?.uid else { return }
        let users = [curentUserUID, chatUserUID]
        let chatUID = UUID().uuidString
        
        Firestore.firestore().collection("chats").document(chatUID).setData([
            "users": users,
            "chatUID": chatUID
        ]) { error in
            if error != nil {
                print("Unable create chat \(String(describing: error?.localizedDescription))")
            }
            self.loadChat()
        }
    }
    
    
//     get user for chat
    private func getUser() {
        guard let  curentUserUID = Auth.auth().currentUser?.uid else { return }
        FirebaseSingolton.shared.getUserWithUID(uid: curentUserUID) { user in
            self.user = user
        }
    }
// save message for user who send
    private func saveMessage(user: User) {
        let messageUID = UUID()
        guard let message = self.mesageField.text,
              let chat
        else { return }
        
        Firestore.firestore().collection("chats").document(chat.chatUID).collection("messages").addDocument(data: [
            "id": "\(messageUID)",
            "content": message,
            "created": Date.now,
            "senderUID": user.uid,
            "senderName": user.username
        ]) { error in
            if let error = error {
                print("Error send mesage: \(error)")
                return
            }
            self.collectionView.reloadData()
//            self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count, section: 0), at: [], animated: false)
        }
    }
// load chat for user
    private func loadChatForUser(chat: Chat) {
        guard let user else { return }
        let db = Firestore.firestore().collection("chats").whereField("users", arrayContains: user.uid)
        db.getDocuments { (chatSnapshot, error )in
            print(error?.localizedDescription ?? "No Error while load chat")
            guard let countSnapshot = chatSnapshot?.documents.count,
                  let chatSnapshot else { return }
            
            if countSnapshot == 0 {
                self.createChat()
            } else {
                chatSnapshot.documents.forEach { document in
                    if chat.users.contains(self.chatUserUID) {
                        self.docReference = document.reference
                        document.reference.collection("mesages").order(by: "created", descending: false).addSnapshotListener(includeMetadataChanges: true) { (messagesSnapshot, error) in
                            print(error?.localizedDescription ?? "No error while load messages")
                            guard let messagesSnapshot else { return }
                            self.messages.removeAll()
                            messagesSnapshot.documents.forEach { message in
                                let data = message.data()
                                guard let id = data["id"] as? String,
                                      let content = data["content"] as? String,
                                      let created = data["created"] as? Timestamp,
                                      let senderUID = data["senderUID"] as? String,
                                      let senderName = data["senderName"] as? String
                                else { return }
                                
                                let message = Message(id: id, content: content, created: created, senderUID: senderUID, senderName: senderName)
                                self.messages.append(message)

                            }
                            self.collectionView.reloadData()
                        }
                    }
                    self.createChat()
                }
            }
        }
    }
    
    
    private func loadChat() {
        let db = Firestore.firestore().collection("chats").whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not found user 1")
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

                    for document in chatSnapshot.documents {
                        let data = document.data()
                        guard let users = data["users"] as? [String],
                              let chatUID = data["chatUID"] as? String
                        else { return }

                        let chat = Chat(users: users, chatUID: chatUID)
                        self.chat = chat
                        
                        if chat.users.contains(self.chatUserUID) {
                            self.docReference = document.reference
                            document.reference.collection("messages").order(by: "created", descending: false).addSnapshotListener(includeMetadataChanges: true, listener: { (messageSnapshot, error )in
                                if let error = error {
                                    print("Error \(error.localizedDescription)")
                                    return
                                } else {
                                    self.messages.removeAll()
                                    var allMSG = [Message]()
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
//                                        self.messages.append(msg)
                                        allMSG.append(msg)
                   
                                    }
                                    self.messages = allMSG
                                    self.collectionView.reloadData()
//                                    self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count, section: 0), at: [], animated: false)
                                }
                            })
                            return
                        }
                        self.createChat()
                    }
                }
            }
        }
    }

    
}


extension ChatWithUserController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.id, for: indexPath)
        guard let messageCell = cell as? MessageCell else { return cell }
        messageCell.message = messages[indexPath.row]
        return messageCell
    }
}



//private func getMessagesForChat(chat: Chat) {
//    if chat.users.contains(self.chatUserUID) {
//        Firestore.firestore().collection("Chats").document(Auth.auth().currentUser?.uid ?? "Not found user 1").collection("Messages").order(by: "created", descending: false).addSnapshotListener(includeMetadataChanges: true) { ( messageSnapshot, error ) in
//
//            if let error = error {
//                print("Error \(error.localizedDescription)")
//                return
//            } else {
//                self.messages.removeAll()
//                guard let messageSnapshot else { return }
//                for message in messageSnapshot.documents {
//                    let data = message.data()
//                    guard let id = data["id"] as? String,
//                          let content = data["content"] as? String,
//                          let created = data["created"] as? Timestamp,
//                          let senderUID = data["senderUID"] as? String,
//                          let senderName = data["senderName"] as? String
//                    else { return }
//
//                    let msg = Message(id: id, content: content, created: created, senderUID: senderUID, senderName: senderName)
//                    self.messages.append(msg)
//                }
//                self.collectionView.reloadData()
//                self.collectionView.scrollToItem(at: IndexPath(row: self.messages.count, section: 0), at: .bottom, animated: false)
//            }
//        }
//        return
//    }
//    self.createChat()
//}
//
//private func setupChat() {
//    guard let chat else { return }
//    getMessagesForChat(chat: chat)
//}
