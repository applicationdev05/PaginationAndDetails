//
//  UserDetailsVC.swift
//  PaginationAndDetails
//
//  Created by Rajat Pandya on 25/04/24.
//

import UIKit

final class UserDetailsVC: UIViewController {
    
    // MARK: - Outlets, variables and life-cycle methods
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    var userId: Int?
    var cachedData: [Int: String] = [:] // Reference to cached data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        guard let userId = userId else {
            titleLabel.text = "Invalid User"
            detailsLabel.text = ""
            return
        }
        
        titleLabel.text = "User \(userId)"
        
        if let cachedDetails = cachedData[userId] {
            detailsLabel.text = cachedDetails
        } else {
            detailsLabel.text = "Loading..."
            loadUserDetails(userId: userId)
        }
    }
    
    // MARK: - User Details Loading
    
    private func loadUserDetails(userId: Int) {
        // + 2 seconds for mocking long running task
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let details = "Additional details for user \(userId)"
            self.detailsLabel.text = details
            self.cachedData[userId] = details
        }
    }
    
}
