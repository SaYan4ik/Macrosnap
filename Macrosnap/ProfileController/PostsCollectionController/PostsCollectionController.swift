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
    private var postsType: ProfilePostType = .digitalPosts
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPosts()
    }

    func set(typePost: ProfilePostType) {
        self.postsType = typePost
    }
    
    private func setupPosts() {
        guard let userUID = user?.uid else { return }
        
        switch postsType {
            case .digitalPosts:
                getAllPostsWithUID(uid: userUID)
            case .filmPosts:
                getAllFilmPosts(uid: userUID)
            case .favouritePosts:
                getAllFavouritePosts(uid: userUID)
        }
    }
    
    private func getAllPostsWithUID(uid: String) {
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            FirebaseSingolton.shared.getPostsWithUserUID(user: user) { allPosts in
                self.posts = allPosts
                self.collectionView.reloadData()
            }
        }
    }
    
    private func getAllFilmPosts(uid: String) {
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            FirebaseSingolton.shared.getFilmPostsWithUserUID(user: user) { filmPosts in
                self.posts = filmPosts
                self.collectionView.reloadData()
            }
        }
    }
    
    private func getAllFavouritePosts(uid: String) {
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            FirebaseSingolton.shared.getfavouritePostsWithUser(user: user) { favPosts in
                self.posts = favPosts
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

extension PostsCollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = 0.0
        guard let screen = view.window?.windowScene?.screen else { return .zero }
        
        let width = (screen.bounds.width - (inset * (6))) / 3
        return CGSize(width: width, height: width)
    }
}
