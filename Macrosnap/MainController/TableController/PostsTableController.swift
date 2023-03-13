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
    
    private var postType: PostType = .digitalPost
    private var posts = [Post]() {
        didSet {
            chekLike()
            checkFav()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        tableViewRefresher()
        getAllPosts()
        chekLike()
        checkFav()
    }
    
    func set(postType: PostType) {
        self.postType = postType
    }
    
    private func tableViewRefresher() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        self.posts.removeAll()
        getAllPosts()
    }
    
    private func getAllPosts() {
        getAllPostsForUser()
        getAllFollowUserPosts()
    }
    
    private func getAllPostsForUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        tableView.refreshControl?.beginRefreshing()
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            FirebaseSingolton.shared.getPostsByTypeWithUserUID(
                user: user,
                postType: self.postType
            ) { allPosts in
                self.posts.append(contentsOf: allPosts)
                
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        
    }
    
    private func getAllFollowUserPosts() {
        tableView.refreshControl?.beginRefreshing()

        FirebaseSingolton.shared.getFollowingUsers { followUsers in
            followUsers.forEach { user in
                FirebaseSingolton.shared.getPostsByTypeWithUserUID(
                    user: user,
                    postType: self.postType
                ) { allPosts in
                    self.posts.append(contentsOf: allPosts)

                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    private func getAllPostsForFollowUsers() {
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "com.bestkora.mySerial", attributes: .concurrent)
        var followUsers = [User]()
        
        let followUsersWorkItem = DispatchWorkItem {
            FirebaseSingolton.shared.getFollowingUsers { users in
                followUsers = users
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        dispatchQueue.async(execute: followUsersWorkItem)
        
        dispatchGroup.notify(queue: .main) {
            self.tableView.refreshControl?.beginRefreshing()
            followUsers.forEach { user in
                FirebaseSingolton.shared.getPostsByTypeWithUserUID(user: user, postType: self.postType) { allPosts in
                    self.posts.append(contentsOf: allPosts)
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    private func chekLike() {
        posts.forEach { post in
            FirebaseSingolton.shared.checkLikeByUser(post: post) { didLike in
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    let indexPath = IndexPath(row: index, section:0)
                    if didLike {
                        self.posts[index].likeByCurrenUser = didLike
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
    }
    
    private func checkFav() {
        posts.forEach { post in
            FirebaseSingolton.shared.checkFavByUser(post: post) { didFavourite in
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    let indexPath = IndexPath(row: index, section:0)
                    if didFavourite {
                        self.posts[index].favouriteByCurenUser = didFavourite
                        self.tableView.reloadRows(at: [indexPath], with: .none)
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
            postCell.set(
                delegate: self,
                post: posts[indexPath.row],
                likeButtonIsSelected: posts[indexPath.row].likeByCurrenUser,
                favButtonIsSelected: posts[indexPath.row].favouriteByCurenUser,
                type: postType
            )
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
}

