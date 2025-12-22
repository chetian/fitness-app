//
//  ActivityMetrics.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct ActivityMetrics: Codable, Identifiable {
    let id: String // MongoDB _id
    let userId: String
    let date: Date
    var steps: Int
    var activeEnergy: Int // kcal
    var activeMinutes: Int
    var restingHeartRate: Int?
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var distance: Double? // meters
    var floorsClimbed: Int?
    let dataSource: DataSource
    let createdAt: Date
    var updatedAt: Date
    
    enum DataSource: String, Codable {
        case healthkit
        case manual
        case appleWatch = "apple_watch"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, date, steps, activeEnergy, activeMinutes
        case restingHeartRate, averageHeartRate, maxHeartRate
        case distance, floorsClimbed, dataSource, createdAt, updatedAt
    }
    
    // MARK: - Computed Properties
    
    var distanceKilometers: Double? {
        guard let distance = distance else { return nil }
        return distance / 1000.0
    }
    
    var formattedDistance: String? {
        guard let km = distanceKilometers else { return nil }
        return String(format: "%.2f km", km)
    }
    
    var stepsFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }
    
    var caloriesFormatted: String {
        return "\(activeEnergy) kcal"
    }
    
    var activeMinutesFormatted: String {
        let hours = activeMinutes / 60
        let minutes = activeMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

