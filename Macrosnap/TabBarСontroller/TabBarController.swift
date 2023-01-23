//
//  TabBarController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 12.11.22.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = self.tabBar.items?.firstIndex(of: item)
        let subView = tabBar.subviews[index!+1].subviews.first as! UIImageView
        self.performSpringAnimation(imgView: subView)
    }
    
    private func configureTabBar() {
        guard let curentUID = Auth.auth().currentUser?.uid else { return }
        
        let mainVC = MainController(nibName: "MainController", bundle: nil)
        let searchVC = SearchController(nibName: "SearchController", bundle: nil)
        let searchNavVC = UINavigationController(rootViewController: searchVC)
        let addPostVC = AddNewPostController(nibName: "AddNewPostController", bundle: nil)
        let navAddPostVC = UINavigationController(rootViewController: addPostVC)
        //        3.notif
        let profileVC = ProfileController(nibName: "ProfileController", bundle: nil)
        
        FirebaseSingolton.shared.getUserWithUID(uid: curentUID) { user in
            profileVC.user = user
        }
        let navProfVC = UINavigationController(rootViewController: profileVC)
        
        self.viewControllers = [mainVC,
                                searchNavVC,
                                navAddPostVC,
                                navProfVC]
        
        mainVC.tabBarItem = UITabBarItem(title: "Main", image: UIImage(systemName: "house"), tag: 0)
        searchNavVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        addPostVC.tabBarItem = UITabBarItem(title: "Add", image: UIImage(systemName: "plus.app"), tag: 2)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)

        self.tabBar.barTintColor = UIColor(red: 62/255, green: 64/255, blue: 77/255, alpha: 1)
        self.tabBar.tintColor = .white
    }
    
    func performSpringAnimation(imgView: UIImageView) {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            
            imgView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)
            
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in

        }
    }

}
