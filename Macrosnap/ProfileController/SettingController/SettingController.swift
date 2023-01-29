//
//  SettingController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 28.11.22.
//

import UIKit

class SettingController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var settingView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingView.layer.cornerRadius = 12
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    @IBAction func changeAvatrImageDidTap(_ sender: Any) {
        
    }
    
    @IBAction func saveAvatarDidTap(_ sender: Any) {
        
    }
    
    
    @IBAction func saveUserNameDidTap(_ sender: Any) {
    }
    
}

