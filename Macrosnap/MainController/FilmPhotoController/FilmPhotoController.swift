//
//  FilmPhotoController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 9.01.23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FilmPhotoController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var filmPosts = [Post]()
    var query: Query?
    var lastDocumentSnapshot: DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        registrationCell()
    }
    
    private func registrationCell() {
        let nibPhoto = UINib(nibName: PostsCell.id, bundle: nil)
        tableView.register(nibPhoto, forCellReuseIdentifier: PostsCell.id)
    }

    
    
    
}


// MARK: -
// MARK: - UITableViewDataSource

extension FilmPhotoController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filmPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostsCell.id, for: indexPath)
        guard let filmPostCell = cell as? PostsCell else { return cell }
        
        filmPostCell.post = filmPosts[indexPath.row]
        return filmPostCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           // Trigger pagination when scrolled to last cell
           // Feel free to adjust when you want pagination to be triggered
           if (indexPath.row == filmPosts.count - 1) {
               getAllPostWithPaging()
           }
       }
    
}

// MARK: -
// MARK: - UITableViewDelegate

extension FilmPhotoController: ButtonDelegate {
    
    func present(vc: UIViewController) {
        self.present(vc, animated: true)
    }
    
    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeButtonDidTap(post: Post, button: UIButton) {
        if button.isSelected {
            FirebaseSingolton.shared.disLikePost(post: post)
        } else {
            FirebaseSingolton.shared.likePost(post: post)
        }
        
        FirebaseSingolton.shared.getPostByUID(post: post) { post in
            if let row = self.filmPosts.firstIndex(where: { $0.postId == post.postId }) {
                self.filmPosts[row] = post
                let indexPath = IndexPath(row: row, section:0)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }

    }
    
    func favoriteButtonDidTap() {
        print("Favorite button did tap")
    }

}

// MARK: -
// MARK: - Pagination
extension FilmPhotoController {
    private func pagination(user: User) {
        var query: Query
        
        if filmPosts.isEmpty {
            query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").limit(to: 2)
            print("First 2 posts loaded")
        } else {
            guard let lastDocumentSnapshot else { return }
            query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
            print("Next 2 posts loaded")
        }

        query.getDocuments { snapshot, error in
            guard let snapshot else { return }
            if let error = error {
                print("\(error.localizedDescription)")
            } else if snapshot.isEmpty {
                return
            } else {
                for document in snapshot.documents {
                    let data = document.data()

                    guard let postId = data["postId"] as? String,
                          let userId = data["userId"] as? String,
                          let lense = data["lense"] as? String,
                          let camera = data["camera"] as? String,
                          let description = data["description"] as? String,
                          let like = data["like"] as? Int
                    else { return }

                    let post = Post(user: user, postId: postId, userId: userId, lense: lense, camera: camera, description: description, like: like)
                    self.filmPosts.append(post)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.tableView.reloadData()

                })
                
                self.lastDocumentSnapshot = snapshot.documents.last
            }
        }
    }
    
    private func getAllPostWithPaging() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseSingolton.shared.getUserWithUID(uid: uid) { user in
            self.pagination(user: user)
        }
    }
    
}
