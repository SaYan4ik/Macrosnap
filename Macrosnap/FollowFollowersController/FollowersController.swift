//
//  FollowersController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 26.11.22.
//

import UIKit

class FollowersController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var typeController: FollowersType = .openProfile
    var followingUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        registrationCell()
        setupNavBar()
        tableView.layer.cornerRadius = 12
    }

    private func registrationCell() {
        let cellNib = UINib(nibName: FollowCell.id, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: FollowCell.id)
    }
    
//    private func getFollowUsers() {
//        FirebaseSingolton.shared.getFollowingUsers { users in
//            self.followingUsers = users
//        }
//    }
    
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

extension FollowersController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.id, for: indexPath)
        guard let followCell = cell as? FollowCell else { return cell }
        followCell.user = followingUsers[indexPath.row]
        return followCell
    }
    
    
}

extension FollowersController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch typeController {
            case .openProfile:
                let nib = String(describing: ProfileController.self)
                let profVC = ProfileController(nibName: nib, bundle: nil)
                
                profVC.user = followingUsers[indexPath.row]
                profVC.setupNavBar()
                navigationController?.pushViewController(profVC, animated: true)
                
            case .openChat:
                break
                
                
        }
    }
}
