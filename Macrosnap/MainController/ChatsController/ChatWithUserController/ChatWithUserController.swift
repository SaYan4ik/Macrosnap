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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mesageField: UITextField!
    @IBOutlet weak var bottomTextFieldConstrain: NSLayoutConstraint!
        
    var chatUserUID: String = ""
    var chat: Chat?
    var user: User?
    private var docReference: DocumentReference?
    private var messages = [Message]()
    private var messagesIndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadChatTest()
        self.getUser()
        self.setupNavBar()
        self.setupTableView()
        self.addGesture()
        self.setupKeyBoardWhenEditing()
    }
    
    private func setupTableView() {
        self.tableView.dataSource = self
        self.registerCell()
    }
    
    private func scrollToBottom(){
        DispatchQueue.main.async {
            if self.messages.count != 0 {
                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func setupKeyBoardWhenEditing() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    

    private func registerCell() {
        tableView.register(MessageCell.self, forCellReuseIdentifier: String(describing: MessageCell.self))
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
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let tabBarHeight = self.tabBarController?.tabBar.frame.size.height else { return }
        let keyboardHeight = keyboardSize.height - tabBarHeight + 5.0
        guard let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0) else { return }
        
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
            let bottomConstant: CGFloat = 16
            viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = 16
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            guard let self else { return }
            self.view.layoutIfNeeded()
            self.scrollToBottom()
            
        }
        
        animator.startAnimation()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if mesageField.isEditing {
            moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.bottomTextFieldConstrain, keyboardWillShow: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, viewBottomConstraint: self.bottomTextFieldConstrain, keyboardWillShow: false)
    }
    
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
                self.showAlert(title: "Error", message: "Unable create chat \(String(describing: error?.localizedDescription))")
            } else {
                self.loadChatTest()
            }
        }
    }
    
    private func getUser() {
        guard let  curentUserUID = Auth.auth().currentUser?.uid else { return }
        FirebaseSingolton.shared.getUserWithUID(uid: curentUserUID) { user in
            self.user = user
        }
    }

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
                self.showAlert(title: "Error send mesage", message: "\(error.localizedDescription)")
                return
            }
            self.tableView.reloadData()
            self.mesageField.text = ""
        }
    }
    
    func loadChatTest() {
        //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("chats").whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not found user 1")
        
        db.getDocuments { (chatQuerySnap, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                
                if queryCount == 0 {
                    //If documents count is zero that means there is no chat available and we need to create a new instance
                    self.createChat()
                }
                else if queryCount >= 1 {
                    //Chat(s) found for currentUser
                    guard let chatQuerySnap else { return }
                    for doc in chatQuerySnap.documents {
                        guard let users = doc["users"] as? [String],
                              let chatUID = doc["chatUID"] as? String
                        else { return }
                        
                        let chat = Chat(
                            users: users,
                            chatUID: chatUID
                        )
                        //Get the chat which has chatUserUID
                        if chat.users.contains(self.chatUserUID) {
                            
                            self.docReference = doc.reference
                            //fetch it's thread collection
                            doc.reference.collection("messages")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (messageSnapshot, error) in
                                    if let error = error {
                                        print("Error: \(error)")
                                        return
                                    } else {
                                        self.messages.removeAll()
                                        var allMessages = [Message]()
                                        guard let messageSnapshot else { return }
                                        for message in messageSnapshot.documents {
                                            let data = message.data()
                                            guard let id = data["id"] as? String,
                                                  let content = data["content"] as? String,
                                                  let created = data["created"] as? Timestamp,
                                                  let senderUID = data["senderUID"] as? String,
                                                  let senderName = data["senderName"] as? String
                                            else { return }
                                            
                                            let msg = Message(
                                                id: id,
                                                content: content,
                                                created: created,
                                                senderUID: senderUID,
                                                senderName: senderName
                                            )
                                            allMessages.append(msg)
                                            print("Data: \(msg.content)")
                                        }
                                        self.messages = allMessages
                                        self.tableView.reloadData()
                                        self.scrollToBottom()
                                    }
                                })
                            return
                        } //end of if
                    } //end of for
                    self.createChat()
                } else {
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
    
}

extension ChatWithUserController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessageCell.self), for: indexPath)
        guard let messageCell = cell as? MessageCell else { return cell }
        messageCell.setContent(message: messages[indexPath.row])
        
        return messageCell
    }
}
