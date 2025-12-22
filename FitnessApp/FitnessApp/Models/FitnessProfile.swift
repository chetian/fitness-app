//
//  FitnessProfile.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct FitnessProfile: Codable {
    var age: Int
    var weight: Double // kg
    var height: Double // cm
    var weightGoal: Double? // kg
    var fitnessGoals: [FitnessGoal]
    var activityLevel: ActivityLevel
    
    enum FitnessGoal: String, Codable, CaseIterable {
        case weightLoss = "weight_loss"
        case muscleGain = "muscle_gain"
        case endurance = "endurance"
        case generalFitness = "general_fitness"
        
        var displayName: String {
            switch self {
            case .weightLoss: return "Weight Loss"
            case .muscleGain: return "Muscle Gain"
            case .endurance: return "Endurance"
            case .generalFitness: return "General Fitness"
            }
        }
        
        var description: String {
            switch self {
            case .weightLoss: return "Lose weight and burn fat"
            case .muscleGain: return "Build muscle and strength"
            case .endurance: return "Improve stamina and cardio"
            case .generalFitness: return "Overall health and wellness"
            }
        }
        
        var icon: String {
            switch self {
            case .weightLoss: return "scalemass.fill"
            case .muscleGain: return "dumbbell.fill"
            case .endurance: return "figure.run"
            case .generalFitness: return "heart.fill"
            }
        }
    }
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary
        case lightlyActive = "lightly_active"
        case moderatelyActive = "moderately_active"
        case veryActive = "very_active"
        case extraActive = "extra_active"
        
        var displayName: String {
            switch self {
            case .sedentary: return "Sedentary"
            case .lightlyActive: return "Lightly Active"
            case .moderatelyActive: return "Moderately Active"
            case .veryActive: return "Very Active"
            case .extraActive: return "Extra Active"
            }
        }
        
        var description: String {
            switch self {
            case .sedentary: return "Little or no exercise"
            case .lightlyActive: return "Exercise 1-3 days/week"
            case .moderatelyActive: return "Exercise 3-5 days/week"
            case .veryActive: return "Exercise 6-7 days/week"
            case .extraActive: return "Very intense exercise daily"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    var bmiFormatted: String {
        return String(format: "%.1f", bmi)
    }
}

