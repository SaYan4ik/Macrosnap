//
//  ChatsController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 2.02.23.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import MessageKit

class ChatsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chats = [Chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func configureTableView() {
        tableView.dataSource = self
    }
    

}

extension ChatsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
