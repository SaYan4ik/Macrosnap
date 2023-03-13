//
//  SettingController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 28.11.22.
//

import UIKit
import FirebaseStorage
import SDWebImage

class SettingController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var saveInfoButton: UIButton!
    
    var user: User?
    var updateAvatarBlock: ((UIImage) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        addTapGesture()
        setupNavBar()
    }
    
    @IBAction func saveAvatarDidTap(_ sender: Any) {
        updateUserInfo()
        guard let newAvatar = avatarImageView.image else { return }
        self.updateAvatarBlock?(newAvatar)
    }
    
    
    @IBAction func saveUserNameDidTap(_ sender: Any) {
        guard let newUserName = userNameField.text else { return }
        
        if user?.username != newUserName {
            FirebaseSingolton.shared.updateUserName(newUserName: newUserName)
        } else {
            self.showAlert(title: "Error", message: "You need to change your name")
        }

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
    
    private func setData() {
        self.userNameField.text = user?.username
        
        guard let avatarUrl = user?.avatarURL else { return }
        guard let url = URL(string: avatarUrl) else { return }
        avatarImageView.sd_setImage(with: url)
        
        settingView.layer.cornerRadius = 12
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapImage(tapGestureRecognizer:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc private func tapImage(tapGestureRecognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    
    
    private func upload(photo: UIImage?, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("avatars").child(NSUUID().uuidString)
        guard let imageData = avatarImageView.image?.jpegData(compressionQuality: 0.6) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) {(metadata, error) in
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
    
    private func updateUserInfo() {
        guard let newAvatar = avatarImageView.image else { return }
        
        upload(photo: newAvatar) { (result) in
            switch result {
                case .success(let url):
                    FirebaseSingolton.shared.updateAvatar(avatarURL: url.absoluteString)
                    print(url.absoluteString)
                    
                case .failure(let error):
                    print("\(String(describing: error.localizedDescription))")
            }
        }
        
        
    }
    
}


extension SettingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        avatarImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
