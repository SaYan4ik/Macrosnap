//
//  ChatWithUserController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import UIKit

class ChatWithUserController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }


    private func setupNavBar() {
        let button = UIButton()
        button.addTarget(self, action: #selector(backAction), for: .allEvents)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
