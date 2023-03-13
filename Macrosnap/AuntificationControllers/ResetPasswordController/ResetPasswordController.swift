//
//  ResetPasswordController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 13.03.23.
//

import UIKit
import FirebaseAuth

class ResetPasswordController: UIViewController {
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        addGesture()
        resetButton.isEnabled = false
    }
    
    private func setupTextField() {
        eMailTextField.backgroundColor = .white
        eMailTextField.setupTextField()
        eMailTextField.validateRegEx(type: .email)
    }
    
    private func isValidTextField() {
        if eMailTextField.isValid(type: .email) {
            resetButton.isEnabled = true
        } else {
            resetButton.isEnabled = false
        }
    }
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func textFieldFifChange(_ sender: UITextField) {
        switch sender.tag {
            case 1001:
                sender.validateRegEx(type: .email)
                isValidTextField()
            default: break
        }
    }
    
    @IBAction func resetButtonDidTap(_ sender: Any) {
        guard let email = eMailTextField.text else { return }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert(
                    title: "Error reset password",
                    message: error.localizedDescription
                )
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
}
