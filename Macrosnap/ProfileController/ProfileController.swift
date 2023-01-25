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

    private var controllers = [UIViewController]()
    private var selectedIndex = 0
    var updateBlock: (() -> Void)?
    var posts = [Post]()
    var user: User?
    var followingUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        configureUser()
        configureController()
        insertController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton()
        getPostsForUser(uid: user?.uid ?? "")
        setupFollowCount()
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
        present(settingVC, animated: true)
    }
    
    @IBAction func followUserDidTap(_ sender: Any) {
        let followNib = String(describing: FollowersController.self)
        let followVC = FollowersController(nibName: followNib , bundle: nil)
        followVC.followingUsers = followingUsers
        
        navigationController?.pushViewController(followVC, animated: true)

    }
    
     func setupNavBar() {
        let button = UIButton()
        button.addTarget(self, action: #selector(backAction), for: .allEvents)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @IBAction func backAction(_ sender: Any) {
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

    }

    func insertController() {
        let controller = controllers[selectedIndex]
        self.addChild(controller)
        controller.view.frame = self.contentView.bounds
        self.contentView.addSubview(controller.view)
        self.didMove(toParent: controller)
    }
    
}

// MARK: -
// MARK: - UserSettings

extension ProfileController {
    private func setUserInfo() {
        self.userNameLabel.text = user?.username
        
        guard let avatarUrl = user?.avatarURL else { return }
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
    
    private func getPostsForUser(uid: String) {
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            FirebaseSingolton.shared.getPostsWithUserUID(user: user) { posts in
                self.posts = posts
                self.postsCount.text = "\(posts.count)"
            }
        }
    }
    
    private func setupFollowCount() {
//        followCountLabel.text = "\(0)"
        followersCountLabel.text = "\(0)"
        
        FirebaseSingolton.shared.getFollowingUsers { followingUsers in
            self.followingUsers = followingUsers
            self.followCountLabel.text = "\(followingUsers.count)"
        }
        
        
    }
    
    private func configureUser() {
        guard let user = user else { return }
        
        self.userNameLabel.text = user.username
        let avatarUrl = user.avatarURL
        guard let url = URL(string: avatarUrl) else { return }
        profileimage.sd_setImage(with: url)
    }

}
