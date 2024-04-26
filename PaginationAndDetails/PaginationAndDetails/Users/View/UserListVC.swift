//
//  UserListVC.swift
//  PaginationAndDetails
//
//  Created by Rajat Pandya on 25/04/24.
//

import UIKit

final class UserListVC: UIViewController {
    
    // MARK: - Outlets, variables and life-cycle methods
    
    private struct UserListStrings {
        static let title: String = "Users"
        static let userCell: String = "UserCell"
        static let userDetailsVC: String = "UserDetailsVC"
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: UsersViewModel!
    private var spinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = UsersViewModel(manager: NetworkManager())
        setupUI()
        getUsers()
    }
    
    // MARK: - Private functions
    
    private func getUsers() {
        let startTime = DispatchTime.now()
        viewModel.fetchUsers(page: viewModel.currentPage) { [weak self] users, allPagesLoaded in
            guard let self = self else { return }
            self.updateUI(with: users, allPagesLoaded: allPagesLoaded, startTime: startTime)
        }
    }
    
    private func setupUI() {
        tableView.register(UINib(nibName: UserListStrings.userCell, bundle: nil), forCellReuseIdentifier: UserCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        title = UserListStrings.title
    }
    
    private func updateUI(with users: [User], allPagesLoaded: Bool, startTime: DispatchTime) {
        DispatchQueue.main.async {
            self.tableView.tableFooterView?.isHidden = allPagesLoaded
        }
        
        let newUsers = viewModel.filterNewUsers(users)
        if !newUsers.isEmpty {
            addNewUsersAndDetails(newUsers, startTime: startTime)
        } else {
            viewModel.endTimeLogger(startTime: startTime)
        }
    }

    private func addNewUsersAndDetails(_ users: [User], startTime: DispatchTime) {
        DispatchQueue.main.async {
            let indexPaths = (self.viewModel.users.count..<self.viewModel.users.count + users.count).map { IndexPath(row: $0, section: 0) }
            self.viewModel.users.append(contentsOf: users)
            UIView.performWithoutAnimation {
                self.tableView.insertRows(at: indexPaths, with: .none)
            }
            self.viewModel.updateCachedData(for: users)
            self.viewModel.endTimeLogger(startTime: startTime)
        }
    }
    
    private func loadMoreData() {
        viewModel.currentPage += 1
        getUsers()
        showLoadingSpinner()
    }

    private func showLoadingSpinner() {
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Use optional chaining to create the spinner if it hasn't been created yet
            self.spinner = self.spinner ?? UIActivityIndicatorView(style: .medium)
            self.spinner?.startAnimating()
            self.spinner?.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 44)
            
            // Assign the spinner as the table footer view and make it visible
            self.tableView.tableFooterView = self.spinner
            self.tableView.tableFooterView?.isHidden = false
        }
    }

}

// MARK: EXT: - UITableViewDelegate, UITableViewDataSource

extension UserListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.cellIdentifier,
                                                       for: indexPath) as? UserCell else {
            fatalError("Failed to dequeue UserCell for indexPath: \(indexPath)")
        }
        cell.configure(with: viewModel.users[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.users[indexPath.row]
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: UserListStrings.userDetailsVC) as? UserDetailsVC else {
            return
        }
        detailVC.userId = selectedUser.id
        detailVC.cachedData = viewModel.cachedData
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.users.count - 1 && !viewModel.allPagesLoaded {
            loadMoreData()
        }
    }
    
}
