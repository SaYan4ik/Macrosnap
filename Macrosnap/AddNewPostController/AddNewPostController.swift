//
//  AddNewPostController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 13.11.22.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth


class AddNewPostController: UIViewController {
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var ImageForAdd: UIImageView!
    @IBOutlet weak var cameraField: UITextField!
    @IBOutlet weak var lenseField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var digitalPhotoTypeButton: UIButton!
    @IBOutlet weak var filmPhotoTypeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
    }

    @IBAction func addRawButtonDidTap(_ sender: Any) {
        print("addRawDidTap")
    }
    
    @IBAction func addArticleDidTap(_ sender: Any) {
        print("addArticleDidTap")
    }
    
    @IBAction func addImageDidTap(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
        print("addImageDidTap")
    }
    
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
//        guard let camera = cameraField.text,
//              let lense = lenseField.text,
//              let description = descriptionField.text
//        else { return }
//
//
//        addNewPostDocement(camera: camera, lense: lense, description: description) { [weak self] (success) in
//            guard let self else { return }
//            if (success) {
//                self.navigationController?.popToRootViewController(animated: true)
//            } else {
//                self.showAlert(title: "Error", message: "There was an error.")
//            }
//        }
//        print("saveButtotDidTap")
        let nib = String(describing: DescriptionController.self)
        let descriptionPostVC = DescriptionController(nibName: nib, bundle: nil)
        descriptionPostVC.imageForAdd = ImageForAdd.image
        navigationController?.pushViewController(descriptionPostVC, animated: true)
    }
    
    private func savePost(button: UIButton) {
        guard let camera = cameraField.text,
              let lense = lenseField.text,
              let description = descriptionField.text
        else { return }
        
        if digitalPhotoTypeButton.isSelected {
            addNewPostDocement(camera: camera, lense: lense, description: description) { [weak self] success in
                guard let self else { return }
                if (success) {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.showAlert(title: "Error", message: "Post did't upload.")
                }
            }
        }
        
        if filmPhotoTypeButton.isSelected {
            addNewPostDocement(camera: camera, lense: lense, description: description) { [weak self] success in
                guard let self else { return }
                if (success) {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.showAlert(title: "Error", message: "Post did't upload.")
                }
            }
        }
    }
    
}

// MARK: -
// MARK: - SetStyle
extension AddNewPostController {
    
    private func setStyle() {
        titleView.layer.cornerRadius = 12
        buttonView.layer.cornerRadius = 12
        imageView.layer.cornerRadius = 12
        descriptionView.layer.cornerRadius = 12
    }
}

// MARK: -
// MARK: - uploadPost
extension AddNewPostController {
    
    private func uploadPost(photo: UIImage?, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let ref = Storage.storage().reference().child("posts").child(NSUUID().uuidString)
        guard let imageData = ImageForAdd.image?.jpegData(compressionQuality: 0.6) else { return }
        
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
    
        self.uploadPost(photo: self.ImageForAdd.image) { (myResult) in
            switch myResult {
                    
                case .success(let url):
                    let postNameURL = Storage.storage().reference(forURL: url.absoluteString).name
                    Firestore.firestore().collection("posts").document(user.uid).collection("userPosts").document("\(postNameURL)").setData([
                        "postId": url.absoluteString,
                        "userId": user.uid,
                        "lense": lense,
                        "camera": camera,
                        "description": description,
                        "like": 0
                    ])
                case .failure(let error):
                    print("\(String(describing: error.localizedDescription))")
                    completionBlock(false)
            }
        }
    }
    
    private func addNewFilmPhoto(camera: String, lense: String, description: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completionBlock(false)
            return
        }
        
        self.uploadPost(photo: self.ImageForAdd.image) { (myResult) in
            switch myResult {
                    
                case .success(let url):
                    let postNameURL = Storage.storage().reference(forURL: url.absoluteString).name
                    Firestore.firestore().collection("filmPosts").document(user.uid).collection("userFilmPosts").document("\(postNameURL)").setData([
                        "postId": url.absoluteString,
                        "userId": user.uid,
                        "lense": lense,
                        "camera": camera,
                        "description": description,
                        "like": 0
                    ])
                case .failure(let error):
                    print("\(String(describing: error.localizedDescription))")
                    completionBlock(false)
            }
        }
    }
    
    private func setSelectionButton(button: UIButton) {
        switch button {
            case digitalPhotoTypeButton:
                digitalPhotoTypeButton.isSelected = true
                filmPhotoTypeButton.isSelected = false
                
            case filmPhotoTypeButton:
                digitalPhotoTypeButton.isSelected = false
                filmPhotoTypeButton.isSelected = true
                
            default:
                break
        }
    }
}

// MARK: -
// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension AddNewPostController: UINavigationControllerDelegate {
    
}

extension AddNewPostController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        ImageForAdd.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

