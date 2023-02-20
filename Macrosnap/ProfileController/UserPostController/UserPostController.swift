//
//  UserPostController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 27.12.22.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class UserPostController: UIViewController {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    
    private var post: Post? {
            didSet {
                guard let imageUrl = post?.postId else { return }
                guard let url = URL(string: imageUrl) else { return }
                let transformer = SDImageResizingTransformer(size: CGSize(width: 600, height: 600), scaleMode: .aspectFill)
                postImageView.sd_setImage(with: url, placeholderImage: nil, options: [.progressiveLoad, .continueInBackground, .refreshCached], context: [.imageTransformer: transformer])
                likesCountLabel.text = "\(post?.like ?? 0)"
                chekFavourite()
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesture()
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc private func viewDidTap() {
        self.dismiss(animated: true)
    }

    func getPostByUID(post: Post) {
        FirebaseSingolton.shared.getPostByUID(post: post) { [weak self ] post in
            self?.post = post
        }
    }
    
    @IBAction func commentButtonDidTap(_ sender: Any) {
        let commentNib = String(describing: CommentsController.id)
        let commentVC = CommentsController(nibName: commentNib, bundle: nil)
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    @IBAction func favouriteButtonDidTap(_ sender: UIButton) {
        guard let post else { return }
        
        if sender.isSelected {
            FirebaseSingolton.shared.removeFavPost(post: post)
        } else {
            FirebaseSingolton.shared.favouritePost(post: post)
        }
        animateFavourite()
    }
    
    private func chekFavourite() {
        guard let post else { return }
        
        FirebaseSingolton.shared.checkFavByUser(post: post) { postExist in
            if postExist == true {
                self.favouriteButton.isSelected = true
                self.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            } else {
                self.favouriteButton.isSelected = false
                self.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
    
    private func animateFavourite() {
        UIView.animate(withDuration: 0.2,
            animations: {
            self.postImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            },
            completion: { _ in
            UIView.animate(withDuration: 0.4) {
                self.postImageView.transform = CGAffineTransform.identity
            }
        })

    }
    
}
