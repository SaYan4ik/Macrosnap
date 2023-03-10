//
//  ProfileController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 13.11.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage


class ProfileController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var unfollowButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var postsCount: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    private var controllers = [UIViewController]()
    private var selectedIndex = 0
    var user: User?
    private var followingUsers = [User]()
    private var digitalPosts: Int = 0
    private var filmPosts: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        configureUser()
        configureController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton()
        setupFollowCount()
        setupFollowsCount()
        getPostsCountForUser()
    }
    
    
    @IBAction func logOutButtonDidTap(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            Environment.sceneDelegare?.setLoginAsInitial()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            self.showAlert(title: "Error LogOut", message: "\(signOutError)")
        }
    }
    
    @IBAction func segmentDidchange(_ sender: Any) {
        guard segment.selectedSegmentIndex < 3 else { return }
        self.selectedIndex = segment.selectedSegmentIndex
        insertController()
    }
    
    @IBAction func followeButtonDidTap(_ sender: Any) {
        guard let user else { return }
        FirebaseSingolton.shared.followDidTap(user: user)
        setupButton()
    }
    
    @IBAction func unfollowButtonDidTap(_ sender: Any) {
        guard let user else { return }
        FirebaseSingolton.shared.unfollowDidTap(user: user)
        setupButton()
    }
    
    @IBAction func settingButtonDidTap(_ sender: Any) {
        let settingNib = String(describing: SettingController.self)
        let settingVC = SettingController(nibName: settingNib, bundle: nil)
        settingVC.user = user
        settingVC.updateAvatarBlock = { newImage in
            self.profileimage.image = newImage
            print(newImage)
        }
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @IBAction func followUserDidTap(_ sender: Any) {
        let followNib = String(describing: FollowersController.self)
        let followVC = FollowersController(nibName: followNib , bundle: nil)        
        navigationController?.pushViewController(followVC, animated: true)
    }
    
     func setupNavBar() {
        let button = UIButton()
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private  func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: -
// MARK: - SetStyle
extension ProfileController {
    private func setStyle() {
        topView.layer.cornerRadius = 12
        profileView.layer.cornerRadius = 12
        profileimage.layer.cornerRadius = profileimage.frame.height / 2
    }
}

// MARK: -
// MARK: - Segment
extension ProfileController {
    func configureController() {
        guard let user = user else { return }
        let postCollectionVC = PostsCollectionController(nibName: String(describing: PostsCollectionController.self), bundle: nil)
        postCollectionVC.user = user
        postCollectionVC.set(typePost: .digitalPosts)
        
        let filmPostsVC = PostsCollectionController(nibName: String(describing: PostsCollectionController.self), bundle: nil)
        filmPostsVC.user = user
        filmPostsVC.set(typePost: .filmPosts)
        
        let favouriteVC = PostsCollectionController(nibName: String(describing: PostsCollectionController.self), bundle: nil)
        favouriteVC.user = user
        favouriteVC.set(typePost: .favouritePosts)
        
        controllers.append(postCollectionVC)
        controllers.append(filmPostsVC)
        controllers.append(favouriteVC)
        insertController()
    }

    func insertController() {
        guard let controller = controllers[safe: selectedIndex] else { return }
        self.addChild(controller)
        controller.view.frame = self.contentView.bounds
        self.contentView.addSubview(controller.view)
        self.didMove(toParent: controller)
    }
}

// MARK: -
// MARK: - UserSettings

extension ProfileController {
    private func configureUser() {
        guard let user = user else { return }
        
        self.userNameLabel.text = user.username
        let avatarUrl = user.avatarURL
        guard let url = URL(string: avatarUrl) else { return }
        profileimage.sd_setImage(with: url)
    }
    
    
    private func setupButton() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let userUID = user?.uid else { return }
        
        if currentUserUID == userUID {
            self.settingsButton.isHidden = false
            self.followButton.isHidden = true
            self.unfollowButton.isHidden = true
        } else {
            guard let user else { return }
            FirebaseSingolton.shared.checkFollowUser(user: user) { result in
                if result {
                    self.followButton.isHidden = true
                    self.unfollowButton.isHidden = false
                    self.settingsButton.isHidden = true
                } else {
                    self.followButton.isHidden = false
                    self.unfollowButton.isHidden = true
                    self.settingsButton.isHidden = true
                }
            }
        }
    }
    
    private func existFollowUser() {
        guard let user else { return }
        FirebaseSingolton.shared.checkFollowUser(user: user) { result in
            if result {
                self.unfollowButton.isHidden = false
                self.followButton.isHidden = true
            } else {
                self.unfollowButton.isHidden = true
                self.followButton.isHidden = false
            }
        }
    }
    
    private func getPostsCountForUser() {
        guard let user else { return }
        FirebaseSingolton.shared.getAllPostsCount(user: user) { count in
            self.postsCount.text = "\(count)"
        }
    }
    
    private func setupFollowCount() {
        followersCountLabel.text = "\(0)"
        
        FirebaseSingolton.shared.getFollowingUsers { followingUsers in
            self.followingUsers = followingUsers
            self.followCountLabel.text = "\(followingUsers.count)"
        }
    }
    
    private func setupFollowsCount() {
        guard let user else { return }
        followersCountLabel.text = "\(0)"
        
        FirebaseSingolton.shared.getAllFollowsUsersUID(user: user) { allUsersList in
            self.followersCountLabel.text = "\(allUsersList.count)"
        }
    }

}
