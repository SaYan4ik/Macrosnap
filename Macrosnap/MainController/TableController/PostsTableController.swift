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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var type: PostType = .digitalPhoto
    private var posts = [Post]()
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        tableViewRefresher()
        getAllPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func set(type: PostType) {
        self.type = type
    }
    
    private func tableViewRefresher() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        posts.removeAll()
        getAllPosts()
    }
    
    private func getAllPosts() {
        getAllPostsForUser()
        getAllPostsForFollowUsers()
    }
    
    private func getAllPostsForUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        tableView.refreshControl?.beginRefreshing()
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            
            switch self.type {
                case .digitalPhoto:
                    
                    FirebaseSingolton.shared.getPostsWithUserUID(user: user) { allPosts in
                        self.posts.append(contentsOf: allPosts)
                        
                        self.tableView.reloadData()
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    
                case .filmPhoto:
                    
                    FirebaseSingolton.shared.getFilmPostsWithUserUID(user: user) { allPosts in
                        self.posts.append(contentsOf: allPosts)
                        
                        self.tableView.reloadData()
                        self.tableView.refreshControl?.endRefreshing()
                    }
            }
        }
    }
    
    private func getAllPostsForFollowUsers() {
        FirebaseSingolton.shared.getFollowingUsers { followUsers in
            followUsers.forEach { user in
                switch self.type {
                        
                    case .digitalPhoto:
                        FirebaseSingolton.shared.getPostsWithUserUID(user: user) { followUserPosts in
                            self.posts.append(contentsOf: followUserPosts)
                            
                            self.tableView.reloadData()
                            self.tableView.refreshControl?.endRefreshing()
                        }
                        
                    case .filmPhoto:
                        
                        FirebaseSingolton.shared.getFilmPostsWithUserUID(user: user) { allPosts in
                            self.posts.append(contentsOf: allPosts)
                            
                            self.tableView.reloadData()
                            self.tableView.refreshControl?.endRefreshing()
                        }
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
        self.tableView.layer.cornerRadius = 12
    }
    
    private func registrationCell() {
        let nibPhoto = UINib(nibName: PostsCell.id, bundle: nil)
        tableView.register(nibPhoto, forCellReuseIdentifier: PostsCell.id)
    }

}

extension PostsTableController: UITableViewDelegate {
    
}

// MARK: -
// MARK: - UITableViewDataSource

extension PostsTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostsCell.id, for: indexPath)
        guard let postCell = cell as? PostsCell else { return cell }
        
        if !posts.isEmpty {
            postCell.set(delegate: self, post: posts[indexPath.row])
        }
        
        return postCell
    }
    
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
                    post.like = post.like - 1
                    button.setImage(UIImage(systemName: "heart.fill"), for: .normal)

                } else {
                    FirebaseSingolton.shared.likePost(post: post)
                    post.like = post.like + 1
                    button.setImage(UIImage(systemName: "heart"), for: .normal)
                }

                if let row = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    let indexPath = IndexPath(row: row, section:0)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 , execute: {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    })
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
                        let indexPath = IndexPath(row: row, section: 0)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                            self.tableView.reloadRows(at: [indexPath], with: .none)
                        })
                    }
                }
        }
        
    }
    
    func favoriteButtonDidTap(post: Post, button: UIButton) {
        
        if button.isSelected {
            FirebaseSingolton.shared.removeFavPost(post: post)
        } else {
            FirebaseSingolton.shared.favouritePost(post: post)
        }

        if let rowPost = self.posts.firstIndex(where: { $0.postId == post.postId }) {
            let indexPath = IndexPath(row: rowPost, section: 0)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            })
        }
    }
}

