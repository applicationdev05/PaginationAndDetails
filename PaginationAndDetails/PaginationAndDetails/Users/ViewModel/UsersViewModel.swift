//
//  UsersViewModel.swift
//  PaginationAndDetails
//
//  Created by Rajat Pandya on 25/04/24.
//

import Foundation

final class UsersViewModel {
    
    private let manager: NetworkManageryProtocol
    
    var users: [User] = []
    var currentPage = 1
    var cachedData: [Int: String] = [:]
    var allPagesLoaded: Bool = false
    
    init(manager: NetworkManageryProtocol) {
        self.manager = manager
    }
    
    func fetchUsers(page: Int, completion: @escaping (_ users: [User], _ allLoaded: Bool) -> ()) {
        
        guard let url = URL(string: "\(APIEndpoints.postsURL)?_page=\(page)") else {
            return
        }
        
        manager.get(url: url, resultType: [User].self) { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            if let users = users {
                self.allPagesLoaded = users.isEmpty
                completion(users, users.isEmpty)
            }
        }
    }
    
    func filterNewUsers(_ users: [User]) -> [User] {
        return users.filter { cachedData[$0.id] == nil }
    }
    
    func updateCachedData(for users: [User]) {
        for user in users {
            cachedData[user.id] = "Additional details for user \(user.id)"
        }
    }
    
    func endTimeLogger(startTime: DispatchTime) {
        let endTime = DispatchTime.now()
        let timeInterval = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        print("Heavy computation time for page \(currentPage): \(timeInterval) seconds")
    }
    
}
