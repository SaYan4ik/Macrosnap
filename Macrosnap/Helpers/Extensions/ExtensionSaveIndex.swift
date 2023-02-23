//
//  ExtensionSaveIndex.swift
//  Macrosnap
//
//  Created by Александр Янчик on 20.02.23.
//

import Foundation

extension Collection {
    
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
