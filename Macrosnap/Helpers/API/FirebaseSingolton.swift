//
//  FirebaseSingolton.swift
//  Macrosnap
//
//  Created by Александр Янчик on 16.11.22.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseSingolton {
    
    static let shared = FirebaseSingolton()

    // MARK: -
    // MARK: - DigitalPosts
    func getPostsWithUserUID(user: User, complition: @escaping ([Post]) -> Void) {
        Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                var allPosts = [Post]()
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
                    allPosts.append(post)
                }
                complition(allPosts)
            }
        }
    }
    
    func getPostByUID(post: Post, complition: @escaping((Post) -> Void)) {
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("posts").document(post.userId).collection("userPosts").document(postNameURL).getDocument { (snapshot, error ) in
            if let error = error {
                print("Error get post by uid \(error.localizedDescription)")
            } else {
                guard let snapshot else { return }
                guard let data = snapshot.data() else { return }
                guard let postId = data["postId"] as? String,
                      let userId = data["userId"] as? String,
                      let lense = data["lense"] as? String,
                      let camera = data["camera"] as? String,
                      let description = data["description"] as? String,
                      let like = data["like"] as? Int
                else { return }
                let post = Post(user: post.user, postId: postId, userId: userId, lense: lense, camera: camera, description: description, like: like)
                print("Post was upload")
                complition(post)
            }

        }
    }

    
    func deletePost(post: Post, comlition: @escaping ((Bool) -> Void)) {
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("posts").document(post.user.uid).collection("userPosts").document(postNameURL).delete()
        
        Storage.storage().reference().child("posts").child(postNameURL).delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        comlition(true)
    }

    func likePost(post: Post) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name

        Firestore.firestore().collection("posts").document(post.user.uid).collection("userPosts").document(postNameURL).updateData(["like": post.like + 1])
        
        Firestore.firestore().collection("users").document(userUID).collection("usersLike").document(postNameURL).setData([
            "postId": post.postId,
            "userId": post.user.uid
        ])
    }
    
    func disLikePost(post: Post) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("posts").document(post.user.uid).collection("userPosts").document(postNameURL).updateData(["like" : post.like - 1])
        Firestore.firestore().collection("users").document(userUID).collection("usersLike").document("\(postNameURL)").delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkLikeByUser(post: Post, complition: @escaping((Bool) -> Void)) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("users").document(userUID).collection("usersLike").document(postNameURL).getDocument { (snapshot, error) in
            if let error = error {
                print("User like check error \(userUID), \(error.localizedDescription)")
            } else {
                guard let snapshot = snapshot?.exists else { return }
                complition(snapshot)
            }
        }
    }
    
    func favouritePost(post: Post) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("users").document(userUID).collection("favouritePosts").document(postNameURL).setData([
            "postId": post.postId,
            "userId": post.user.uid,
            "lense": post.lense,
            "camera": post.camera,
            "description": post.description,
            "like": post.like
        ])
    }
    
    func removeFavPost(post: Post) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("users").document(userUID).collection("favouritePosts").document("\(postNameURL)").delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkFavByUser(post: Post, complition: @escaping((Bool) -> Void)) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("users").document(userUID).collection("favouritePosts").document(postNameURL).getDocument { (snapshot, error) in
            if let error = error {
                print("User like check error \(userUID), \(error.localizedDescription)")
            } else {
                guard let snapshot = snapshot?.exists else { return }
                complition(snapshot)
            }
        }
    }
    
    func getfavouritePostsWithUser(user: User, complition: @escaping ([Post]) -> Void) {
        Firestore.firestore().collection("users").document(user.uid).collection("favouritePosts").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                var allPosts = [Post]()
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
                    allPosts.append(post)
                }
                complition(allPosts)
            }
        }
    }

    func addCommentForPost(post: Post, commentText: String) {
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("comments").document(postNameURL).collection("postComments").addDocument(data: [
            "commentText": commentText,
            "postId": postNameURL,
            "date": Timestamp(date: Date.now)
        ])
    }
    
    func getCommentForPost(post: Post, comlition: @escaping ([Comment]) -> Void) {
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("comments").document(postNameURL).collection("postComments").order(by: "date").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                var allComments = [Comment]()
                for document in snapshot.documents {
                    let data = document.data()
                    guard let commentText = data["commentText"] as? String,
                          let dateOfCreation = data["date"] as? Timestamp
                    else { return }
                    
                    let comment = Comment(commentText: commentText, post: post, date: dateOfCreation)
                    allComments.append(comment)
                }
                comlition(allComments)
            }
        }
    }
    
    func getAllPostsCount(user: User, completion: @escaping (Int) -> ()) {
        var count: Int = 0
        getPostsWithUserUID(user: user) { posts in
            count += posts.count
            self.getFilmPostsWithUserUID(user: user) { posts in
                count += posts.count
                completion(count)
            }
        }


    }
    
// MARK: -
// MARK: - FilmPosts
    
    func getFilmPostsWithUserUID(user: User, complition: @escaping ([Post]) -> Void) {
        Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                var allPosts = [Post]()
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
                    allPosts.append(post)
                }
                complition(allPosts)
            }
        }
    }
    
    func getFilmPostByUID(post: Post, complition: @escaping((Post) -> Void)) {
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("filmPosts").document(post.user.uid).collection("userFilmPosts").document(postNameURL).getDocument { (snapshot, error ) in
            if let error = error {
                print("Error get post by uid \(error.localizedDescription)")
            } else {
                guard let snapshot else { return }
                guard let data = snapshot.data() else { return }
                guard let postId = data["postId"] as? String,
                      let userId = data["userId"] as? String,
                      let lense = data["lense"] as? String,
                      let camera = data["camera"] as? String,
                      let description = data["description"] as? String,
                      let like = data["like"] as? Int
                else { return }
                let post = Post(user: post.user, postId: postId, userId: userId, lense: lense, camera: camera, description: description, like: like)
                complition(post)
            }

        }
    }
    
    func likeFilmPost(post: Post) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name

        Firestore.firestore().collection("filmPosts").document(post.user.uid).collection("userFilmPosts").document(postNameURL).updateData(["like": post.like + 1])
        
        Firestore.firestore().collection("users").document(userUID).collection("usersLike").document(postNameURL).setData([
            "postId": post.postId,
            "userId": post.user.uid
        ])
    }
    
    func disLikeFilmPost(post: Post) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("filmPosts").document(post.user.uid).collection("userFilmPosts").document(postNameURL).updateData(["like" : post.like - 1])
        Firestore.firestore().collection("users").document(userUID).collection("usersLike").document("\(postNameURL)").delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteFilmPost(post: Post, comlition: @escaping ((Bool) -> Void)) {
        let postNameURL = Storage.storage().reference(forURL: post.postId).name
        
        Firestore.firestore().collection("filmPosts").document(post.user.uid).collection("userPosts").document(postNameURL).delete()
        
        Storage.storage().reference().child("posts").child(postNameURL).delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        comlition(true)
    }
    
    
//MARK: -
//MARK: - User / Users

    func getUserWithUID(uid: String, completion: @escaping (User) -> Void ) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            if let error = error {
                print("Error geting documents: \(error.localizedDescription)")
            } else {
                let data = snapshot.data()
                guard let avatarURL = data?["avatarURL"] as? String,
                      let fullName = data?["fullName"] as? String,
                      let uid = data?["uid"] as? String,
                      let userName = data?["userName"] as? String
                else { return }
                
                let user = User(uid: uid, username: userName, fullName: fullName, profileURL: avatarURL)
                
                completion(user)
            }
        }
    }
    
    func getAllUsers(completion: @escaping ([User]) -> ()) {
        Firestore.firestore().collection("users").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            if let error = error {
                print("Error of geting all users \(error.localizedDescription)")
            } else {
                var usersArray = [User]()
                for document in snapshot.documents {
                    let data = document.data()
                    guard let avatarURL = data["avatarURL"] as? String,
                          let fullName = data["fullName"] as? String,
                          let uid = data["uid"] as? String,
                          let userName = data["userName"] as? String
                    else { return }
                    
                    let user = User(uid: uid, username: userName, fullName: fullName, profileURL: avatarURL)
                    usersArray.append(user)
                }
                completion(usersArray)
            }
        }
    }
    
    
    func updateAvatar(avatarURL: String?) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let avatarURL
        else { return }
        Firestore.firestore().collection("users").document(currentUID).updateData(["avatarURL": avatarURL])
        
        Storage.storage().reference().child("posts").child(currentUID).delete { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUserName(newUserName: String?) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let newUserName
        else { return }
        
        Firestore.firestore().collection("users").document(currentUID).updateData(["userName": newUserName]) 
    }

    

// MARK: -
// MARK: - Follow / Followers

    func followDidTap(user: User) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("following").document(userUID).collection("usersFollowing").document("\(user.uid)").setData([
            "userName": user.username,
            "fullName": user.fullName,
            "userUID": user.uid,
            "avatarURL": user.avatarURL,
        ])
        
        Firestore.firestore().collection("followers").document("\(user.uid)").collection("usersFollowsYou").document(userUID).setData([
            "userUID": userUID
        ])
    }
    
    func unfollowDidTap(user: User) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("following").document(userUID).collection("usersFollowing").document("\(user.uid)").delete { error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
        
        Firestore.firestore().collection("followers").document("\(user.uid)").collection("usersFollowsYou").document(userUID).delete { error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func checkFollowUser(user: User, complition: @escaping((Bool) -> Void)) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("following").document(userUID).collection("usersFollowing").document("\(user.uid)").getDocument { (snapshot, error )in
            if let error = error {
                print("Error check follow users, \(error.localizedDescription)")
            } else {
                guard let snapshot = snapshot?.exists else { return }
                complition(snapshot)
            }
        }
    }
    
    func getFollowingUsers(complition: @escaping ([User]) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("following").document(userUID).collection("usersFollowing").getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                var followUsers = [User]()
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    let data = document.data()
                    guard let username = data["userName"] as? String,
                          let fullName = data["fullName"] as? String,
                          let userUID = data["userUID"] as? String,
                          let avatarURL = data["avatarURL"] as? String
                    else { return }
                    
                    let folowUser = User(uid: userUID, username: username, fullName: fullName, profileURL: avatarURL)
                    
                    followUsers.append(folowUser)
                }
                complition(followUsers)
            }
        }
    }
    
    func getFolowUserByUID(user: User, comlition: @escaping ((User) -> Void) ) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("followers").document(userUID).collection("usersFollowing").document(user.uid).getDocument { ( docSnapshot, error) in
            if let error = error {
                print("Error get follow user \(error.localizedDescription)")
            } else {
                guard let docSnapshot else { return }
                guard let data = docSnapshot.data() else { return }
                
                guard let username = data["username"] as? String,
                      let fullName = data["fullName"] as? String,
                      let userUID = data["userUID"] as? String,
                      let avatarURL = data["avatarURL"] as? String
                else { return }
                
                let followUser = User(uid: userUID, username: username, fullName: fullName, profileURL: avatarURL)
                comlition(followUser)
            }
        }
    }
    
    func getAllFollowsUsersUID(user: User, complition: @escaping ([String]) -> Void ) {
        Firestore.firestore().collection("followers").document(user.uid).collection("usersFollowsYou").getDocuments { (snapshot, error)  in
            if let error = error {
                print("Error for get all follows you users: \(error.localizedDescription)")
            } else {
                var followsYouUsersUID = [String]()
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    let data = document.data()
                    guard let followUserUID = data["userUID"] as? String else { return }
                    
                    followsYouUsersUID.append(followUserUID)
                    
                }
                complition(followsYouUsersUID)
            }
        }
    }
    
    
//MARK: -
//MARK: - Chat
    
    func getLastMessage(chat: Chat, complition: @escaping ((Message) -> Void) ) {
        
        Firestore.firestore().collection("chats").document(chat.chatUID).collection("messages").order(by: "created", descending: true).limit(to: 1).getDocuments { ( messageSnapshot, error )  in
            
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            }
            
            guard let messageSnapshot else { return }
            
            messageSnapshot.documents.forEach { message in
                let data = message.data()
                
                guard let id = data["id"] as? String,
                      let content = data["content"] as? String,
                      let created = data["created"] as? Timestamp,
                      let senderUID = data["senderUID"] as? String,
                      let senderName = data["senderName"] as? String
                else { return }
                
                let msg = Message(id: id, content: content, created: created, senderUID: senderUID, senderName: senderName)
                
                complition(msg)
            }
        }
    }
    
// MARK: -
// MARK: - Pagination
    func pagination(user: User, posts: [Post], type: PostType, complition: @escaping (([Post]) -> Void)) {
        var query: Query
        var lastDocumentSnapshot: DocumentSnapshot?
        
        switch type {
            case .digitalPhoto:
                if posts.isEmpty {
                    query = Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").limit(to: 2)
                } else {
                    guard let lastDocumentSnapshot else { return }
                    query = Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
                }
                
            case .filmPhoto:
                if posts.isEmpty {
                    query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").limit(to: 2)
                } else {
                    guard let lastDocumentSnapshot else { return }
                    query = Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").start(afterDocument: lastDocumentSnapshot).limit(to: 2)
                }
        }

        query.getDocuments { snapshot, error in
            guard let snapshot else { return }
            if let error = error {
                print("\(error.localizedDescription)")
            } else if snapshot.isEmpty {
                return
            } else {
                var allPosts = [Post]()
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
                    allPosts.append(post)
                }
                complition(allPosts)
                lastDocumentSnapshot = snapshot.documents.last
            }
        }
    }
}
