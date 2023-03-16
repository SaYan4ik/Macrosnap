//
//  RegistrationController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class RegistrationController: UIViewController {
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var registrationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        addGesture()
        setupTextField()
    }
    
    private func setupTextField() {
        fullNameField.backgroundColor = .white
        userNameField.backgroundColor = .white
        emailField.backgroundColor = .white
        passwordField.backgroundColor = .white
        
        fullNameField.setupTextField()
        userNameField.setupTextField()
        emailField.setupTextField()
        passwordField.setupTextField()
        
        userNameField.validateRegEx(type: .name)
        fullNameField.validateRegEx(type: .name)
        emailField.validateRegEx(type: .email)
        passwordField.validateRegEx(type: .password)
    }
    
    private func isValidTextField() {
        let result = [
            userNameField.isValid(type: .name),
            fullNameField.isValid(type: .name),
            emailField.isValid(type: .email),
            passwordField.isValid(type: .password)
        ]
        
        let positive = result.filter( {$0} ).count == result.count
        
        if positive {
            registrationButton.isEnabled = true
        } else {
            registrationButton.isEnabled = false
        }
    }
    
    @IBAction func addPhotoButtonDidTap(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func registrationButtonDidTap(_ sender: Any) {
        guard let fullName = fullNameField.text,
              let userName = userNameField.text,
              let email = emailField.text,
              let password = passwordField.text
        else { return }
        
        regNewUser(fullName: fullName, userName: userName, email: email, password: password) { [weak self] (success) in
            guard let self = self else { return }
            if (success) {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.showAlert(title: "Error", message: "There was an error.")
            }
        }
    }
    
    @IBAction func fieldDidChanged(_ sender: UITextField) {
        switch sender.tag {
            case 1001:
                sender.validateRegEx(type: .name)
                isValidTextField()
            case 1002:
                sender.validateRegEx(type: .name)
                isValidTextField()
            case 1003:
                sender.validateRegEx(type: .email)
                isValidTextField()
            case 1004:
                sender.validateRegEx(type: .password)
                isValidTextField()
            default: break
        }
    }
    
    
    
    func upload(currentUserID: String , photo: UIImage?, completion: @escaping (Result<URL, Error>) -> Void) {

        let ref = Storage.storage().reference().child("avatars").child(currentUserID)
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.4) else { return }
        
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
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: -
// MARK: - SetStyle
extension RegistrationController {
    
    func setStyle() {
        registrationView.layer.cornerRadius = 12
        imageView.layer.cornerRadius = imageView.frame.height / 2
    }
}


// MARK: -
// MARK: - RegistrationWithImageProfile
extension RegistrationController {
    func regNewUser(fullName: String, userName: String, email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard let user = result?.user else {
                completionBlock(false)
                return
            }
            
            self.upload(currentUserID: user.uid, photo: self.imageView.image) { (myResult) in
                switch myResult {
                        
                    case .success(let url):
                        let db = Firestore.firestore()

                        db.collection("users").document(user.uid).setData([
                            "fullName": fullName,
                            "userName": userName,
                            "avatarURL":url.absoluteString,
                            "uid": user.uid
                        ]) { (error) in
                            if error != nil {
                                completionBlock(false)
                            }
                            completionBlock(true)
                        }

                    case .failure(let error):
                        print("\(String(describing: error.localizedDescription))")
                        completionBlock(false)
                }
            }
        }
    }
}


// MARK: -
// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
