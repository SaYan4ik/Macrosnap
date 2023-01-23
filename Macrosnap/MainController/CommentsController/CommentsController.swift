//
//  CommentsController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import UIKit

class CommentsController: UIViewController {
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterCommentField: UITextField!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var lenseLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var post: Post?
    var comments = [Comment]()
    static var id = String(describing: CommentsController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        setDescription()
        tableView.dataSource = self
        registerCell()
        tableView.layer.cornerRadius = 12

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getComment()
    }

    @IBAction func enterCommentButtonDidTap(_ sender: Any) {
        guard let post else { return }
        guard let comment = enterCommentField.text else { return }
        FirebaseSingolton.shared.addCommentForPost(post: post, commentText: comment)
    }
    
    private func getComment() {
        guard let post else { return }
        FirebaseSingolton.shared.getCommentForPost(post: post) { comments in
            self.comments = comments
            self.tableView.reloadData()
        }
    }
    
    private func registerCell() {
        let nibComment = UINib(nibName: CommentCell.id, bundle: nil)
        tableView.register(nibComment, forCellReuseIdentifier: CommentCell.id)
    }
    
}

// MARK: -
// MARK: - SetStyle
extension CommentsController {
    func setStyle() {
        descriptionView.layer.cornerRadius = 12
        descriptionTextView.layer.cornerRadius = 12
    }
    
    func setDescription() {
        guard let post = post else { return }
        cameraLabel.text = post.camera
        lenseLabel.text = post.lense
        descriptionTextView.text = post.description
        descriptionTextView.isEditable = false
    }
}

// MARK: -
// MARK: - UITableViewDataSource
extension CommentsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.id, for: indexPath)
        guard let commentCell = cell as? CommentCell else { return cell }
        
        commentCell.set(delegate: self)
        commentCell.comment = comments[indexPath.row]
        return commentCell
    }
}

extension CommentsController: CommentButtonDelegate {
    func likeCommentButtonDidTap(comment: Comment, button: UIButton) {
        print("Like button did tap")
    }
}
