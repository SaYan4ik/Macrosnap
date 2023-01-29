//
//  LoginController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginView: UIView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        addGesture()
    }
    
    @IBAction func loginButtonDidTap(_ sender: Any) {
        guard let email = emailField.text,
              let password = passwordField.text
        else { return }
        
        login(email: email, password: password) { success in
            if (success) {
                Environment.sceneDelegare?.setTabBarAsInitial()
            } else {
                self.showAlert(title: "Error", message: "That was an error.")
            }
        }
        
    }
    
    @IBAction func registrationButtonDidTap(_ sender: Any) {
        let regVC = RegistrationController(nibName: String(describing: RegistrationController.self), bundle: nil)
        navigationController?.pushViewController(regVC, animated: true)
    }
    
    
    @IBAction func rememberPasswordButtonDidTap(_ sender: Any) {
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
extension LoginController {
    func setStyle() {
        loginView.layer.cornerRadius = 12
    }
}

// MARK: -
// MARK: - login
extension LoginController {
    func login(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completionBlock(false)
            } else {
                completionBlock(true)
            }
        }
    }
}



