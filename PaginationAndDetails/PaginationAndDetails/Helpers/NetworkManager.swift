//
//  NetworkManager.swift
//  PaginationAndDetails
//
//  Created by Rajat Pandya on 25/04/24.
//

import Foundation

// Define custom error types
enum APIError: Error {
    case noData
    case invalidStatusCode(Int)
    case decodingError(Error)
}

// HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol NetworkManageryProtocol {
    func get<T: Decodable>(url: URL, resultType: T.Type, completion: @escaping (_ responseData: T?, _ error: Error?) -> Void)
}

final class NetworkManager: NetworkManageryProtocol {
    
    func get<T: Decodable>(url: URL, resultType: T.Type, completion: @escaping (_ responseData: T?, _ error: Error?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, urlResponse, error in
            
            self.handleResponse(data: data, urlResponse: urlResponse, error: error, resultType: T.self) { responseData, error in
                completion(responseData, error)
            }
            
        }.resume()
    }
    
    private func handleResponse <T: Decodable>(data: Data?, urlResponse: URLResponse?, error: Error?, resultType: T.Type ,completion: @escaping (_ responseData: T?, _ error: Error?) -> Void) {
        guard let data = data else {
            completion(nil, APIError.noData)
            return
        }
        
        do {
            if let urlResponse = urlResponse as? HTTPURLResponse, !(200..<300).contains(urlResponse.statusCode) {
                throw APIError.invalidStatusCode(urlResponse.statusCode)
            }
            
            let responseData = try JSONDecoder().decode(T.self, from: data)
            completion(responseData, nil)
        } catch {
            completion(nil, error)
        }
    }
    
}
