//
//  HealthKitService.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation
import HealthKit

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case queryFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized. Please grant permission in Settings."
        case .queryFailed(let message):
            return "Failed to query HealthKit: \(message)"
        }
    }
}

class HealthKitService {
    
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    // MARK: - Availability
    
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Authorization
    
    func requestHealthKitPermissions() async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!,
            HKObjectType.workoutType()
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - Query Steps
    
    func querySteps(for date: Date = Date()) async throws -> Int {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType,
                                         quantitySamplePredicate: predicate,
                                         options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
                    return
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Query Active Energy
    
    func queryActiveEnergy(for date: Date = Date()) async throws -> Int {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: energyType,
                                         quantitySamplePredicate: predicate,
                                         options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
                    return
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let calories = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
                continuation.resume(returning: calories)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Query Heart Rate
    
    func queryLatestHeartRate() async throws -> Int? {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType,
                                     predicate: nil,
                                     limit: 1,
                                     sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let heartRate = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
                continuation.resume(returning: heartRate)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Query Distance
    
    func queryDistance(for date: Date = Date()) async throws -> Double {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: distanceType,
                                         quantitySamplePredicate: predicate,
                                         options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
                    return
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let meters = sum.doubleValue(for: HKUnit.meter())
                continuation.resume(returning: meters)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Query Workouts
    
    func queryWorkouts(startDate: Date, endDate: Date) async throws -> [HKWorkout] {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType,
                                     predicate: predicate,
                                     limit: HKObjectQueryNoLimit,
                                     sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
                    return
                }
                
                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Query Weekly Data
    
    func queryWeeklySteps() async throws -> [Date: Int] {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        var dailySteps: [Date: Int] = [:]
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: endDate)!
            let steps = try await querySteps(for: date)
            let startOfDay = calendar.startOfDay(for: date)
            dailySteps[startOfDay] = steps
        }
        
        return dailySteps
    }
    
    // MARK: - Background Observer
    
    func setupBackgroundObserver(for type: HKQuantityTypeIdentifier, handler: @escaping () -> Void) {
        guard isHealthKitAvailable else { return }
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: type)!
        
        let query = HKObserverQuery(sampleType: quantityType, predicate: nil) { _, completionHandler, error in
            if let error = error {
                print("Observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            // Call handler on main thread
            DispatchQueue.main.async {
                handler()
            }
            
            completionHandler()
        }
        
        healthStore.execute(query)
        
        // Enable background delivery
        healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { success, error in
            if let error = error {
                print("Background delivery error: \(error.localizedDescription)")
            } else if success {
                print("Background delivery enabled for \(type.rawValue)")
            }
        }
    }
    
    // MARK: - Calculate Active Minutes
    
    func calculateActiveMinutes(for date: Date = Date()) async throws -> Int {
        // Simplified: Use workouts as proxy for active minutes
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let workouts = try await queryWorkouts(startDate: startOfDay, endDate: endOfDay)
        
        let totalMinutes = workouts.reduce(0) { total, workout in
            let duration = workout.duration / 60 // Convert to minutes
            return total + Int(duration)
        }
        
        return totalMinutes
    }
}

