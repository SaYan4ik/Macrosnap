//
//  PostsTableController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class PostsTableController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var type: PostType = .digitalPhoto
    var posts = [Post]()
    var filmPosts = [Post]()
    var query: Query?
    var lastDocumentSnapshot: DocumentSnapshot?
    var fetchingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPostsFollowingUsers()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        getAllPostWithPaging()
    }
    
    func set(type: PostType) {
        self.type = type
    }
    
    private func getAllPostWithPaging() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            self.pagination(user: user)
        }
    }
    
    private func pagination(user: User) {
        fetchingMore = true
        var query: Query
        
        switch type {
            case .digitalPhoto:
                if posts.isEmpty {
                    query = Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").limit(to: 2)
                    print("First 2 posts loaded")
                } else {
                    guard let lastDocumentSnapshot else { return }
                    query = Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
                    print("Next 2 posts loaded")
                }
                
            case .filmPhoto:
                if posts.isEmpty {
                    query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").limit(to: 2)
                    print("First 2 posts loaded")
                } else {
                    guard let lastDocumentSnapshot else { return }
                    query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
                    print("Next 2 posts loaded")
                }
        }

        query.getDocuments { snapshot, error in
            guard let snapshot else { return }
            if let error = error {
                print("\(error.localizedDescription)")
            } else if snapshot.isEmpty {
                self.fetchingMore = false
                return
            } else {
                for document in snapshot.documents {
                    let data = document.data()

                    guard let postId = data["postId"] as? String,
                          let userId = data["userId"] as? String,
                          let lense = data["lense"] as? String,
                          let camera = data["camera"] as? String,
                          let description = data["description"] as? String,
                          let like = data["like"] as? Int
                    else { return }

                    let post = Post(user: user, postId: postId, userId: userId, lense: lense, camera: camera, description: description, like: like)
                    self.posts.append(post)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.tableView.reloadData()
                    self.fetchingMore = false

                })
                
                self.lastDocumentSnapshot = snapshot.documents.last
            }
        }
    }
    
    private func getPostsFollowingUsers() {
        FirebaseSingolton.shared.getFollowingUsers { folllowingUsers in
            folllowingUsers.forEach { user in
                print(user.username)
                FirebaseSingolton.shared.getPostsWithUserUID(user: user) { allPosts in
                    print(allPosts)
                    self.pagination(user: user)
                }
            }
        }
    }
    
}

// MARK: -
// MARK: - Configure

fileprivate extension PostsTableController {
    
    private func configure() {
        configureTable()
        registrationCell()
    }
    
    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func registrationCell() {
        let nibPhoto = UINib(nibName: PostsCell.id, bundle: nil)
        tableView.register(nibPhoto, forCellReuseIdentifier: PostsCell.id)
    }

}

// MARK: -
// MARK: - UITableViewDataSource

extension PostsTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostsCell.id, for: indexPath)
        guard let postCell = cell as? PostsCell else { return cell}
        
        postCell.set(delegate: self, typePost: type)
        postCell.post = posts[indexPath.row]
        return postCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == posts.count - 1) {
            getAllPostWithPaging()
        }
    }
    
}

// MARK: -
// MARK: - UITableViewDelegate

extension PostsTableController: UITableViewDelegate {
    
}

// MARK: -
// MARK: - UITableViewDelegate
extension PostsTableController: ButtonDelegate {
    
    func present(vc: UIViewController) {
        self.present(vc, animated: true)
    }
    
    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeButtonDidTap(post: Post, button: UIButton) {
        
        switch type {
            case .digitalPhoto:
                if button.isSelected {
                    FirebaseSingolton.shared.disLikePost(post: post)
                } else {
                    FirebaseSingolton.shared.likePost(post: post)
                }
                
                FirebaseSingolton.shared.getPostByUID(post: post) { post in
                    if let row = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                        self.posts[row] = post
                        let indexPath = IndexPath(row: row, section:0)
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }
            case .filmPhoto:
                if button.isSelected {
                    FirebaseSingolton.shared.disLikeFilmPost(post: post)
                } else {
                    FirebaseSingolton.shared.likeFilmPost(post: post)
                }
                
                FirebaseSingolton.shared.getFilmPostByUID(post: post) { post in
                    if let row = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                        self.posts[row] = post
                        let indexPath = IndexPath(row: row, section:0)
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }
        }
        
    }
    
    func favoriteButtonDidTap() {
        print("Favorite button did tap")
    }

}

