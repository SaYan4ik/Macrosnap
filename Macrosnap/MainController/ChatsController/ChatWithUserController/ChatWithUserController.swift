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
//        self.loadChat()
        self.loadChatData()
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
            self.loadChatData()
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
    private func loadChatForUser(chat: Chat) {
        let db = Firestore.firestore().collection("chats").whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not found user 1")
        db.getDocuments { (chatSnapshot, error ) in
            
            if let error = error {
                print("Failed to load chat \(error.localizedDescription)")
                return
            }
            
            guard let countSnapshot = chatSnapshot?.documents.count,
                  let chatSnapshot else { return }
            
            if countSnapshot == 0 {
                self.createChat()
            } else if countSnapshot >= 1{
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
                        return
                    }
                    self.createChat()
                }
            }
        }
    }
    
    private func loadChatData() {
        guard let chat else { return }
        loadChatForUser(chat: chat)
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

