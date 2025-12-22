//
//  DatabaseService.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

class DatabaseService {
    
    static let shared = DatabaseService()
    
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - User Endpoints
    
    func fetchUser(authId: String) async throws -> User {
        return try await networkManager.get(endpoint: "/users/\(authId)")
    }
    
    func createUser(_ user: User) async throws -> User {
        return try await networkManager.post(endpoint: "/users", body: user)
    }
    
    func updateUser(authId: String, user: User) async throws -> User {
        return try await networkManager.put(endpoint: "/users/\(authId)", body: user)
    }
    
    func deleteUser(authId: String) async throws {
        try await networkManager.delete(endpoint: "/users/\(authId)")
    }
    
    // MARK: - Fitness Metrics Endpoints
    
    func createFitnessMetrics(_ metrics: ActivityMetrics) async throws -> ActivityMetrics {
        return try await networkManager.post(endpoint: "/fitness-metrics", body: metrics)
    }
    
    func fetchFitnessMetrics(userId: String, days: Int = 7) async throws -> [ActivityMetrics] {
        struct Response: Codable {
            let data: [ActivityMetrics]
            let count: Int
        }
        
        let response: Response = try await networkManager.get(endpoint: "/fitness-metrics/\(userId)?days=\(days)")
        return response.data
    }
    
    // MARK: - Workout Endpoints
    
    func createWorkout(_ workout: WorkoutData) async throws -> WorkoutData {
        return try await networkManager.post(endpoint: "/workouts", body: workout)
    }
    
    func fetchWorkouts(userId: String, limit: Int = 20) async throws -> [WorkoutData] {
        struct Response: Codable {
            let data: [WorkoutData]
            let count: Int
        }
        
        let response: Response = try await networkManager.get(endpoint: "/workouts/\(userId)?limit=\(limit)")
        return response.data
    }
    
    func deleteWorkout(workoutId: String) async throws {
        try await networkManager.delete(endpoint: "/workouts/\(workoutId)")
    }
    
    // MARK: - Notification Preferences
    
    func updateNotificationPreferences(authId: String, preferences: NotificationPreferences) async throws -> NotificationPreferences {
        return try await networkManager.put(endpoint: "/users/\(authId)/notification-preferences", body: preferences)
    }
}

