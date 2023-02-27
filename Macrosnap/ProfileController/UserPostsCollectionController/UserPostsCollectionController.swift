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
    
    func set(posts: [Post]) {
        self.posts = posts
    }
    
}

extension UserPostsCollectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserPostCollectionCell.id, for: indexPath)
        guard let postCell = cell as? UserPostCollectionCell else { return cell }
        postCell.set(post: posts[indexPath.row])
        return postCell
    }
    
    
}

extension UserPostsCollectionController: UICollectionViewDelegate {
    
}
