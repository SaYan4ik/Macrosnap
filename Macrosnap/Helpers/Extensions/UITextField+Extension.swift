//
//  UITextField+Extension.swift
//  Macrosnap
//
//  Created by Александр Янчик on 4.03.23.
//

import UIKit

extension UITextField {
    
//    Return "true" if text in Field is validate or "false" if invalidate
    func isValid(type: ValidationType) -> Bool {
            let result = validate(string: self.text, pattern: type)
            result ? setValidState() : setInvalidState()
            return result
    }
    
//    Setup UITextField for RegEx
    func setupTextField() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.8
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        self.leftViewMode = .always
        self.textColor = .lightGray
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
    }
    
//    Validate UITextField
    func validateRegEx(type: ValidationType) {
        var timer: Timer?
        timer?.invalidate()
        timer = nil
        
        guard let text = self.text, !text.isEmpty else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] _ in
            guard let self else { return }
            if self.validate(string: self.text, pattern: type) {
                self.setValidState()
            } else {
                self.setInvalidState()
            }
        })
    }
    
    private func setInvalidState() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.layer.borderColor = UIColor.red.cgColor
        } completion: { [weak self] isFinish in
            guard let self else { return }
            self.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    private func setValidState() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    private func validate(string: String?, pattern: ValidationType) -> Bool {
        if pattern == .none {
            return true
        }
        guard let string else { return false }
        let passPred = NSPredicate(format: "SELF MATCHES %@", pattern.rawValue)
        return passPred.evaluate(with: string)
    }
    
    func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry){
            button.setImage(UIImage(named: "eye-72"), for: .normal)
        }else{
            button.setImage(UIImage(named: "closed-eye-72"), for: .normal)

        }
    }

    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}

enum ValidationType: String {
    case phone = "(\\+375|375)(29|25|44|33)(\\d{3})(\\d{2})(\\d{2})"
    case email = "[A-z0-9_.+-]+@[A-z0-9-]+(\\.[A-z0-9-]{2,})"
    case name = "[\\S]{2,16}"
    case password = "[\\S]{6,25}"
    case none = "[\\S]"
    case address = "[A-z 0-9]+, [A-z 0-9]+, (кв|квартира) +[0-9]"
}
