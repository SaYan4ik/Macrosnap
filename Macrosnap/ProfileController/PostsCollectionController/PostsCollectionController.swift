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
    private var lastDocumentSnapshot: DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        collectionViewRefresher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllPosts()
    }

    func set(typePost: ProfilePostType) {
        self.postsType = typePost
    }
    
    private func collectionViewRefresher() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        posts.removeAll()
        getAllPosts()
    }
    
    private func getAllPosts() {
        guard let user else { return }
        pagination(user: user)
        
//        switch postsType {
//            case .digitalPosts:
//                getAllPostsWithUID(uid: userUID)
//
//            case .filmPosts:
//                getAllFilmPosts(uid: userUID)
//            case .favouritePosts:
//                getAllFavouritePosts(uid: userUID)
//        }
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
    
    private func pagination(user: User) {
        var query: Query
        switch postsType {
            case .digitalPosts:
                if posts.isEmpty {
                    query = Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").limit(to: 2)
                } else {
                    guard let lastDocumentSnapshot else { return }
                    query = Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
                }
                
            case .filmPosts:
                if posts.isEmpty {
                    query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").limit(to: 2)
                } else {
                    guard let lastDocumentSnapshot else { return }
                    query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
                }
                
            case .favouritePosts:
                if posts.isEmpty {
                    query = Firestore.firestore().collection("users").document(user.uid).collection("favouritePosts").limit(to: 2)
                } else {
                    guard let lastDocumentSnapshot else { return }
                    query = Firestore.firestore().collection("users").document(user.uid).collection("favouritePosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
            }
        }

        query.getDocuments { snapshot, error in
            guard let snapshot else { return }
            if let error = error {
                print("\(error.localizedDescription)")
                return
            } else if snapshot.isEmpty {
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
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
                self.lastDocumentSnapshot = snapshot.documents.last
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == posts.count - 1) {
            guard let user else {return}
            pagination(user: user)
        }
    }
}

// MARK: -
// MARK: - UICollectionViewDataSource
extension PostsCollectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let nib = String(describing: UserPostController.self)
//        let userPostVC = UserPostController(nibName: nib, bundle: nil)
//
//        userPostVC.getPostByUID(post: posts[indexPath.item])
//        userPostVC.modalPresentationStyle = .fullScreen
//        userPostVC.modalTransitionStyle = .crossDissolve
//
//        present(userPostVC, animated: true)
        
        let nib = String(describing: UserPostsCollectionController.self)
        let userPostsCollection = UserPostsCollectionController(nibName: nib, bundle: nil)
        userPostsCollection.set(posts: posts, index: indexPath.row)
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
