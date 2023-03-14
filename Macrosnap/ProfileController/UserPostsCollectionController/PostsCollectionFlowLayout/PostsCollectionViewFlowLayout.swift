//
//  PostsCollectionViewFlowLayout.swift
//  Macrosnap
//
//  Created by Александр Янчик on 25.02.23.
//

import UIKit

class PostsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private let itemHeight = 425
    private let itemWidth = 300
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        scrollDirection = .horizontal
        itemSize = CGSize(
            width: itemWidth,
            height: itemHeight
        )
        
        let peekingItemWidth = itemSize.width / 10
        let horizontalInsets = (collectionView.frame.size.width - itemSize.width) / 2
        
        collectionView.contentInset = UIEdgeInsets(
            top: 12,
            left: horizontalInsets,
            bottom: 12,
            right: horizontalInsets
        )
        
        minimumLineSpacing = horizontalInsets - peekingItemWidth
    }
}
