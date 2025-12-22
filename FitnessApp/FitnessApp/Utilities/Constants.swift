//
//  Constants.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct Constants {
    
    // MARK: - API Configuration
    
    #if DEBUG
    static let apiBaseURL = "http://157.245.238.156/v1"
    static let enableLogging = true
    #else
    static let apiBaseURL = "http://157.245.238.156/v1"  // TODO: Change to HTTPS with domain
    static let enableLogging = false
    #endif
    
    // MARK: - App Configuration
    
    static let appName = "FitnessApp"
    static let appVersion = "1.0.0"
    static let minimumIOSVersion = "16.0"
    
    // MARK: - MongoDB Collections
    
    struct Collections {
        static let users = "users"
        static let fitnessMetrics = "fitness_metrics"
        static let workouts = "workouts"
    }
    
    // MARK: - HealthKit Identifiers
    
    struct HealthKit {
        static let steps = "HKQuantityTypeIdentifierStepCount"
        static let activeEnergy = "HKQuantityTypeIdentifierActiveEnergyBurned"
        static let heartRate = "HKQuantityTypeIdentifierHeartRate"
        static let workouts = "HKWorkoutTypeIdentifier"
    }
    
    // MARK: - UserDefaults Keys
    
    struct UserDefaultsKeys {
        static let lastSync = "lastSyncTimestamp"
        static let cachedMetrics = "cachedFitnessMetrics"
        static let onboardingCompleted = "onboardingCompleted"
        static let hasSeenWelcome = "hasSeenWelcome"
    }
    
    // MARK: - Keychain Keys
    
    struct KeychainKeys {
        static let firebaseToken = "firebaseIDToken"
        static let firebaseUID = "firebaseUID"
    }
    
    // MARK: - Notification Keys
    
    struct NotificationKeys {
        static let authStateChanged = "authStateChanged"
        static let dataDidSync = "dataDidSync"
        static let healthKitDataUpdated = "healthKitDataUpdated"
    }
    
    // MARK: - Validation Ranges
    
    struct ValidationRanges {
        static let ageMin = 13
        static let ageMax = 120
        static let weightMin = 20.0 // kg
        static let weightMax = 300.0 // kg
        static let heightMin = 100.0 // cm
        static let heightMax = 250.0 // cm
        static let passwordMinLength = 8
    }
}

