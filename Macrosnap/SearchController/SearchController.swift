//
//  SearchController.swift
//  Macrosnap
//
//  Created by Александр Янчик on 29.11.22.
//

import UIKit

class SearchController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private lazy var searchBar: UISearchBar = UISearchBar()
    private var users = [User]()
    private var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getAllUsers()
        setupSearchBar()
        setupRefreshController()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        registerCell()
    }
    
    private func setupRefreshController() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        getAllUsers()
    }
    
    private func setupSearchBar() {
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "Search user"
        searchBar.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .white
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func registerCell() {
        let nib = UINib(nibName: String(describing: SearchUserCell.id), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SearchUserCell.id)
    }
    
    private func getAllUsers() {
        tableView.refreshControl?.beginRefreshing()
        
        FirebaseSingolton.shared.getAllUsers { [weak self] users in
            guard let self else { return }
            
            self.users = users
            self.filteredUsers = users
            self.searchBar.text = ""
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
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



extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profVC = ProfileController(nibName: String(describing: ProfileController.self), bundle: nil)
        profVC.user = filteredUsers[indexPath.row]
        profVC.setupNavBar()
        navigationController?.pushViewController(profVC, animated: true)
        
    }
}

extension SearchController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchUserCell.id, for: indexPath)
        guard let searcCell = cell as? SearchUserCell else { return cell }
        searcCell.user = filteredUsers[indexPath.row]
        return cell
    }
    
    
}

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
