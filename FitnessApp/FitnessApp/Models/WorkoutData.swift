//
//  WorkoutData.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct WorkoutData: Codable, Identifiable {
    let id: String // MongoDB _id
    let userId: String
    let workoutId: String // UUID
    var type: WorkoutType
    let startDate: Date
    let endDate: Date
    var duration: TimeInterval // seconds
    var distance: Double? // meters
    var calories: Int
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var notes: String?
    let dataSource: DataSource
    let createdAt: Date
    var updatedAt: Date
    
    enum WorkoutType: String, Codable, CaseIterable {
        case running, cycling, swimming, strength, yoga
        case walking, hiking, elliptical, rowing
        case other
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var icon: String { // SF Symbol name
            switch self {
            case .running: return "figure.run"
            case .cycling: return "bicycle"
            case .swimming: return "figure.pool.swim"
            case .strength: return "dumbbell.fill"
            case .yoga: return "figure.mind.and.body"
            case .walking: return "figure.walk"
            case .hiking: return "figure.hiking"
            case .elliptical: return "figure.elliptical"
            case .rowing: return "figure.rowing"
            case .other: return "figure.mixed.cardio"
            }
        }
    }
    
    enum DataSource: String, Codable {
        case healthkit, manual
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, workoutId, type, startDate, endDate
        case duration, distance, calories
        case averageHeartRate, maxHeartRate, notes
        case dataSource, createdAt, updatedAt
    }
    
    // MARK: - Computed Properties
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var distanceKilometers: Double? {
        guard let distance = distance else { return nil }
        return distance / 1000.0
    }
    
    var formattedDistance: String? {
        guard let km = distanceKilometers else { return nil }
        return String(format: "%.2f km", km)
    }
    
    var caloriesFormatted: String {
        return "\(calories) kcal"
    }
}

