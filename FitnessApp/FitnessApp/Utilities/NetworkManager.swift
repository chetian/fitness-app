//
//  NetworkManager.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkFailure(String)
    case unauthorized
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to decode server response"
        case .networkFailure(let message):
            return "Network error: \(message)"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        }
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let baseURL: String
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        self.baseURL = Constants.apiBaseURL
    }
    
    // MARK: - Public Methods
    
    func get<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainManager.shared.getToken(forKey: Constants.KeychainKeys.firebaseToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return try await performRequest(request)
    }
    
    func post<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainManager.shared.getToken(forKey: Constants.KeychainKeys.firebaseToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(body)
        
        return try await performRequest(request)
    }
    
    func put<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainManager.shared.getToken(forKey: Constants.KeychainKeys.firebaseToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(body)
        
        return try await performRequest(request)
    }
    
    func delete(endpoint: String) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainManager.shared.getToken(forKey: Constants.KeychainKeys.firebaseToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkFailure("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        } else if httpResponse.statusCode >= 400 {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Private Methods
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkFailure("Invalid response")
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        } else if httpResponse.statusCode >= 400 {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            if Constants.enableLogging {
                print("Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                }
            }
            throw NetworkError.decodingError
        }
    }
}

