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
    private var posts = [Post]() {
        didSet {
            chekLike()
            checkFav()
        }
    }
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        tableViewRefresher()
        getAllPosts()
        chekLike()
        checkFav()
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
    
    private func checkSinglePost(post: Post) {
        FirebaseSingolton.shared.checkLikeByUser(post: post) { didLike in
            if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                self.posts[index].likeByCurrenUser = didLike
            }
        }
    }
    
    private func chekLike() {
        posts.forEach { post in
            FirebaseSingolton.shared.checkLikeByUser(post: post) { didLike in
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    let indexPath = IndexPath(row: index, section:0)
                    if didLike {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                        self.posts[index].likeByCurrenUser = didLike
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
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                        self.posts[index].favouriteByCurenUser = didFavourite
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
            postCell.set(delegate: self, post: posts[indexPath.row], likeButtonIsSelected: posts[indexPath.row].likeByCurrenUser, favButtonIsSelected: posts[indexPath.row].favouriteByCurenUser)
        }
        
        return postCell
    }
    
}

// MARK: -
// MARK: - UITableViewDelegate
extension PostsTableController: ButtonDelegate {
    func likeButtonDidTap(_ likeButton: UIButton, likeCount: UILabel, on cell: PostsCell) {
        print("Like did tap")
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.row]
        
        switch type {
            case .digitalPhoto :
                FirebaseSingolton.shared.checkLikeByUser(post: post) { (didLike) in
                    if didLike {
                        FirebaseSingolton.shared.disLikePost(post: post)
                        likeButton.isSelected = false
                        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                        self.posts[indexPath.row].like = post.like - 1
                        likeCount.text = "\(post.like)"
                        
                    } else {
                        
                        FirebaseSingolton.shared.likePost(post: post)
                        likeButton.isSelected = true
                        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        self.posts[indexPath.row].like = post.like + 1
                        likeCount.text = "\(post.like)"
                    }
                }
                
            case .filmPhoto:
                FirebaseSingolton.shared.checkLikeByUser(post: post) { (didLike) in
                    if didLike {
                        FirebaseSingolton.shared.disLikeFilmPost(post: post)
                        likeButton.isSelected = false
                        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                        self.posts[indexPath.row].like = post.like - 1
                        likeCount.text = "\(post.like)"
                        
                    } else {
                        
                        FirebaseSingolton.shared.likeFilmPost(post: post)
                        likeButton.isSelected = true
                        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        self.posts[indexPath.row].like = post.like + 1
                        likeCount.text = "\(post.like)"
                    }
                }
        }
    }
    
    func favoriteButtonDidTap(_ favouriteButton: UIButton, on cell: PostsCell) {
        print("Favourite did tap")
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.row]
        
        FirebaseSingolton.shared.checkFavByUser(post: post) { (didFav) in
            if didFav {
                FirebaseSingolton.shared.removeFavPost(post: post)
                favouriteButton.isSelected = false
                favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            } else {
                FirebaseSingolton.shared.favouritePost(post: post)
                favouriteButton.isSelected = true
                favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
        }
    }
    
    func present(vc: UIViewController) {
        self.present(vc, animated: true)
    }
    
    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

