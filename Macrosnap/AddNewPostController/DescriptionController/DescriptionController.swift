//
//  DescriptionController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 14.01.23.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class DescriptionController: UIViewController {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var cameraField: UITextField!
    @IBOutlet weak var lenseField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var stackWithText: UIStackView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var digitalPhotoButton: UIButton!
    @IBOutlet weak var filmPhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    private var postType: PostType = .digitalPost
    var imageForAdd: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        postImageView.image = imageForAdd
        adjustUITextViewHeight(arg: descriptionTextView)
        setStyle()
        setupNavBar()
        addGesture()
    }
    
    private func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = false
        arg.sizeToFit()
        arg.isScrollEnabled = true
        arg.layer.cornerRadius = 12
    }
    
    private func setStyle() {
        stackWithText.layer.cornerRadius = 12
        buttonStack.layer.cornerRadius = 12
        saveButton.layer.cornerRadius = 12
    }
    
    @IBAction func savePostButtonDidTap(_ sender: Any) {
        if digitalPhotoButton.isSelected == false, filmPhotoButton.isSelected == false {
            showAlert(title: "Choose type of photo", message: "Didn't choose style of photo")
        } else {
            savePost()
        }
    }
    
    @IBAction func digitalPhotoDidTap(_ sender: Any) {
        setSelectionButton(button: digitalPhotoButton)
        self.postType = .digitalPost
        print(postType.rawValue)
    }
    
    @IBAction func filmPhotoDidTap(_ sender: Any) {
        setSelectionButton(button: filmPhotoButton)
        self.postType = .filmPost
        print(postType.rawValue)
    }
    
    private func setupNavBar() {
        let button = UIButton()
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension DescriptionController {
    private func savePost() {
        guard let camera = cameraField.text,
              let lense = lenseField.text,
              let description = descriptionTextView.text
        else { return }
        
        addNewPostDocement(camera: camera, lense: lense, description: description) { [weak self] success in
            guard let self else { return }
            if (success) {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showAlert(title: "Error", message: "Post did't upload.")
            }
        }
    }
    
    private func uploadPost(photo: UIImage?, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("posts").child(NSUUID().uuidString)
        guard let imageData = postImageView.image?.jpegData(compressionQuality: 0.3) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                guard let error = error else { return }
                completion(.failure(error))
                return
            }
            ref.downloadURL { (url, error)  in
                guard let url = url else {
                    guard let error = error else { return }
                    completion(.failure(error))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    private func addNewPostDocement(camera: String, lense: String, description: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completionBlock(false)
            return
        }
    
        self.uploadPost(photo: self.postImageView.image) { (myResult) in
            switch myResult {
                    
                case .success(let url):
                    let postNameURL = Storage.storage().reference(forURL: url.absoluteString).name
                    Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").document("\(postNameURL)").setData([
                        "postId": url.absoluteString,
                        "userId": user.uid,
                        "lense": lense,
                        "camera": camera,
                        "description": description,
                        "like": 0,
                        "postType": self.postType.rawValue
                    ])
                case .failure(let error):
                    print("\(String(describing: error.localizedDescription))")
                    completionBlock(false)
            }
        }
    }
    
    private func setSelectionButton(button: UIButton) {
        switch button {
            case digitalPhotoButton:
                digitalPhotoButton.isSelected = true
                filmPhotoButton.isSelected = false
                saveButton.isEnabled = true
                
            case filmPhotoButton:
                digitalPhotoButton.isSelected = false
                filmPhotoButton.isSelected = true
                saveButton.isEnabled = true
            default:
                break
        }
    }
    
}
