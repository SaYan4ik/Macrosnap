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
    @IBOutlet weak var noCommentsView: UIView!
    
    @IBOutlet weak var textFieldBottomCinstraint: NSLayoutConstraint!
    
    var post: Post?
    private var comments = [Comment]()
    static var id = String(describing: CommentsController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        setDescription()
        tableView.dataSource = self
        registerCell()
        addGesture()
        tableView.layer.cornerRadius = 12
        setupKeyBoardWhenEditing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getComment()
    }

    @IBAction func enterCommentButtonDidTap(_ sender: Any) {
        guard let post else { return }
        guard let comment = enterCommentField.text else { return }
        FirebaseSingolton.shared.addCommentForPost(post: post, commentText: comment)
        getComment()
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
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyBoardWhenEditing() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    private func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0)
            let bottomConstant: CGFloat = 20
            viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
        } else {
            viewBottomConstraint.constant = 20
        }
        
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if enterCommentField.isEditing {
            moveViewWithKeyboard(
                notification: notification,
                viewBottomConstraint: self.textFieldBottomCinstraint,
                keyboardWillShow: true
            )
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(
            notification: notification,
            viewBottomConstraint: self.textFieldBottomCinstraint,
            keyboardWillShow: false
        )
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
        if comments.count != 0 {
            noCommentsView.isHidden = true
            return comments.count
        } else {
            noCommentsView.isHidden = false
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.id, for: indexPath)
        guard let commentCell = cell as? CommentCell else { return cell }
        
        commentCell.comment = comments[indexPath.row]
        return commentCell
    }
}

