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
        
    var posts = [Post]()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllPostsWithUID(uid: user?.uid ?? "")
    }

    func getAllPostsWithUID(uid: String) {
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            FirebaseSingolton.shared.getPostsWithUserUID(user: user) { allPosts in
                self.posts = allPosts
                self.collectionView.reloadData()
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
        postCell.post = posts[indexPath.item]
        return postCell
    }
}

// MARK: -
// MARK: - UICollectionViewDataSource
extension PostsCollectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nib = String(describing: UserPostController.self)
        let userPostVC = UserPostController(nibName: nib, bundle: nil)
        
//        userPostVC.post = posts[indexPath.item]
        userPostVC.getPostByUID(post: posts[indexPath.item])
        userPostVC.modalPresentationStyle = .fullScreen
        userPostVC.modalTransitionStyle = .crossDissolve
        
        present(userPostVC, animated: true)
    }
    
}
