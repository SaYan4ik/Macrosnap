//
//  Protocols.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import Foundation
import UIKit


// MARK: -
// MARK: - PostCellProtocol
protocol ButtonDelegate: AnyObject {
    func present(vc: UIViewController)
    func push(vc: UIViewController)
}

// MARK: -
// MARK: - UserPostCollectionButtonDelegate
protocol UserPostCollectionButtonDelegate: AnyObject {
    func present(vc: UIViewController)
    func push(vc: UIViewController)
}
