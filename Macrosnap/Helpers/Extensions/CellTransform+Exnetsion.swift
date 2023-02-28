//
//  CellTransform+Exnetsion.swift
//  Macrosnap
//
//  Created by Александр Янчик on 28.02.23.
//

import UIKit


extension UICollectionViewCell {
    func transformToLarge() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    
    func transformToStandard() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
        }
    }
}
