//
//  Environment.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import Foundation
import UIKit

struct Environment {
    static var sceneDelegare: SceneDelegate? {
        let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        return scene
    }
}
