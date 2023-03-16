//
//  PostsCollectionController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 17.11.22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PostsCollectionController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPostsView: UIView!
        
    private var posts = [Post]()
    var user: User?
    private var postType: PostType = .digitalPost
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        collectionViewRefresher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllPosts()
    }

    func set(typePost: PostType) {
        self.postType = typePost
    }
    
    private func collectionViewRefresher() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(handleRefresh),
            for: .valueChanged
        )
        collectionView?.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        getAllPosts()
    }
    
    private func getAllPosts() {
        guard let user else { return }

        posts.removeAll()
        switch postType {
            case .favouritePost:
                FirebaseSingolton.shared.getfavouritePostsWithUser(user: user) { [weak self] allPosts in
                    guard let self else { return }
                    allPosts.forEach { post in
                        FirebaseSingolton.shared.getPostByUID(post: post) { post in
                            self.posts.append(post)
                            self.collectionView.reloadData()
                            self.collectionView.refreshControl?.endRefreshing()
                        }
                    }
                }
                
            default:
                FirebaseSingolton.shared.getPostsByTypeWithUserUID(user: user, postType: self.postType) { [weak self] allPosts in
                    guard let self else { return }
                    self.posts = allPosts
                    self.collectionView.reloadData()
                    self.collectionView.refreshControl?.endRefreshing()
                }
        }
    }

}

// MARK: -
// MARK: - Configure

fileprivate extension PostsCollectionController {
    private func configure() {
        configureCollection()
        registrationCell()
    }
    
    private func configureCollection() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func registrationCell() {
        let nibPost = UINib(nibName: PostCollectionCell.id, bundle: nil)
        collectionView.register(nibPost, forCellWithReuseIdentifier: PostCollectionCell.id)
    }
}

// MARK: -
// MARK: - UICollectionViewDataSource

extension PostsCollectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts.count != 0 {
            noPostsView.isHidden = true
            return posts.count
        } else {
            noPostsView.isHidden = false
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionCell.id, for: indexPath)
        guard let postCell = cell as? PostCollectionCell else { return cell}
        
        if !posts.isEmpty {
            postCell.post = posts[indexPath.item]
        }
        return postCell
    }
}

// MARK: -
// MARK: - UICollectionViewDataSource
extension PostsCollectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let nib = String(describing: UserPostsCollectionController.self)
        let userPostsCollection = UserPostsCollectionController(nibName: nib, bundle: nil)
        userPostsCollection.set(
            posts: posts,
            index: indexPath.row,
            typePost: postType
        )
        navigationController?.pushViewController(userPostsCollection, animated: true)
    }
    
}

extension PostsCollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = 0.0
        guard let screen = view.window?.windowScene?.screen else { return .zero }
        
        let width = (screen.bounds.width - (inset * (6))) / 3
        return CGSize(width: width, height: width)
    }
}
