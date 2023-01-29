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
    
    @IBAction func addImageDidTap(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        let nib = String(describing: DescriptionController.self)
        let descriptionPostVC = DescriptionController(nibName: nib, bundle: nil)
        descriptionPostVC.imageForAdd = ImageForAdd.image
        navigationController?.pushViewController(descriptionPostVC, animated: true)
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

