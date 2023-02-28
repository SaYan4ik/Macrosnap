//
//  UserPostsCollectionController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 25.02.23.
//

import UIKit

class UserPostsCollectionController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var posts = [Post]()
    private var currentSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        registrationCell()
        collectionViewScrollToItem()
        chekLike()
        checkFav()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = PostsCollectionViewFlowLayout()
    }
    
    private func registrationCell() {
        let nib = UINib(nibName: UserPostCollectionCell.id, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: UserPostCollectionCell.id)
    }
    
    func set(posts: [Post], index: Int) {
        self.posts = posts
        self.currentSelectedIndex = index
    }

    private func collectionViewScrollToItem() {
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: currentSelectedIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private func chekLike() {
        posts.forEach { post in
            FirebaseSingolton.shared.checkLikeByUser(post: post) { didLike in
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    self.collectionView.reloadData()
                    self.posts[index].likeByCurrenUser = didLike
                }
            }
        }
    }
    
    private func checkFav() {
        posts.forEach { post in
            FirebaseSingolton.shared.checkFavByUser(post: post) { didFavourite in
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    self.posts[index].favouriteByCurenUser = didFavourite
                    self.collectionView.reloadData()
                    print(self.posts[index].favouriteByCurenUser )
                }
            }
        }
    }
    
}

extension UserPostsCollectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserPostCollectionCell.id, for: indexPath)
        guard let postCell = cell as? UserPostCollectionCell else { return cell }
        
        if currentSelectedIndex == indexPath.row {
            postCell.transformToLarge()
        }
        
        postCell.set(post: posts[indexPath.row], buttonDelegate: self, likeButtonIsSelected: posts[indexPath.row].likeByCurrenUser, favButtonIsSelected: posts[indexPath.row].favouriteByCurenUser)
//        postCell.likeButton.isSelected = posts[indexPath.row].likeByCurrenUser
        
        return postCell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let currentCell = collectionView.cellForItem(at: IndexPath(row: Int(currentSelectedIndex), section: 0))
        currentCell?.transformToStandard()
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            
        guard scrollView == collectionView else {
            return
        }
        
        targetContentOffset.pointee = scrollView.contentOffset
        print("\(targetContentOffset.pointee)")
        
        let flowLayout = collectionView.collectionViewLayout as! PostsCollectionViewFlowLayout
        let cellWidthIncludingSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
        let offset = targetContentOffset.pointee
        let horizontalVelocity = velocity.x
        
        var selectedIndex = currentSelectedIndex
        
        switch horizontalVelocity {
                
            case _ where horizontalVelocity > 0 :
                selectedIndex = currentSelectedIndex + 1
            case _ where horizontalVelocity < 0:
                selectedIndex = currentSelectedIndex - 1
                
            case _ where horizontalVelocity == 0:
                let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
                let roundedIndex = round(index)
                
                selectedIndex = Int(roundedIndex)
            default:
                print("Incorrect velocity for collection view")
        }
        
        let safeIndex = max(0, min(selectedIndex, posts.count - 1))
        let selectedIndexPath = IndexPath(row: safeIndex, section: 0)
        
        guard let collectionView = flowLayout.collectionView else { return }
        
        collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        
        let previousSelectedIndex = IndexPath(row: Int(currentSelectedIndex), section: 0)
        let previousSelectedCell = collectionView.cellForItem(at: previousSelectedIndex)
        let nextSelectedCell = collectionView.cellForItem(at: selectedIndexPath)
        
        currentSelectedIndex = selectedIndexPath.row
        
        previousSelectedCell?.transformToStandard()
        nextSelectedCell?.transformToLarge()
    }
    
}

extension UserPostsCollectionController: UICollectionViewDelegate {
    
}

extension UserPostsCollectionController: UserPostCollectionButtonDelegate {
    func present(vc: UIViewController) {
        self.present(vc, animated: true)
    }
    
    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeButtonDidTap(_ likeButton: UIButton, likeCount: UILabel, on cell: UserPostCollectionCell) {
        print("Like did tap")
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let post = posts[indexPath.row]
        
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
        
        
    }
    
    func favoriteButtonDidTap(_ favouriteButton: UIButton, on cell: UserPostCollectionCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
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
        
        print("Favourite did tap")
    }
    
    
}
