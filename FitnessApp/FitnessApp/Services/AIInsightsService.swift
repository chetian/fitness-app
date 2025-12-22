//
//  AIInsightsService.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct AIInsight: Codable, Identifiable {
    let id: String
    let userId: String
    let message: String
    let insightType: InsightType
    let generatedAt: Date
    var displayUntil: Date
    
    enum InsightType: String, Codable {
        case motivational
        case achievement
        case recommendation
        case trend
        
        var icon: String { // SF Symbol
            switch self {
            case .motivational: return "flame.fill"
            case .achievement: return "star.fill"
            case .recommendation: return "lightbulb.fill"
            case .trend: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var color: String { // Asset catalog color name
            switch self {
            case .motivational: return "insightOrange"
            case .achievement: return "insightGold"
            case .recommendation: return "insightBlue"
            case .trend: return "insightPurple"
            }
        }
    }
    
    // MARK: - Mock Insights
    
    static func mockInsights(for userId: String) -> [AIInsight] {
        let insights = [
            AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: "You're off to a great start! Keep up the momentum! 💪",
                insightType: .motivational,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400 * 7)
            ),
            AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: "You're 25% more active this week compared to last week!",
                insightType: .trend,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400 * 3)
            ),
            AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: "Try adding 10 minutes of cardio to reach your weekly goal",
                insightType: .recommendation,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400 * 5)
            )
        ]
        
        return insights
    }
}

class AIInsightsService {
    
    static let shared = AIInsightsService()
    
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Fetch Insights
    
    func fetchInsights(userId: String) async throws -> [AIInsight] {
        // Try to fetch from backend
        do {
            struct Response: Codable {
                let insights: [AIInsight]
            }
            
            let response: Response = try await networkManager.get(endpoint: "/ai-insights/\(userId)")
            return response.insights
            
        } catch {
            // Fallback to generated insights if backend unavailable
            print("Failed to fetch insights from backend, using generated insights")
            return generateLocalInsights(userId: userId)
        }
    }
    
    // MARK: - Generate Local Insights
    
    private func generateLocalInsights(userId: String) -> [AIInsight] {
        // Use cached metrics to generate simple insights
        let insights = AIInsight.mockInsights(for: userId)
        
        // Add time-based motivational messages
        let hour = Calendar.current.component(.hour, from: Date())
        let timeBasedMessage: String
        
        switch hour {
        case 5..<12:
            timeBasedMessage = "Good morning! Time to start your day with some movement!"
        case 12..<17:
            timeBasedMessage = "Afternoon energy boost! A quick workout can help you power through the rest of your day."
        case 17..<22:
            timeBasedMessage = "Evening is a great time to unwind with some exercise!"
        default:
            timeBasedMessage = "Remember to get good rest for tomorrow's activities!"
        }
        
        let timeInsight = AIInsight(
            id: UUID().uuidString,
            userId: userId,
            message: timeBasedMessage,
            insightType: .motivational,
            generatedAt: Date(),
            displayUntil: Date().addingTimeInterval(86400)
        )
        
        return [timeInsight] + insights
    }
    
    // MARK: - Generate Insights from Activity Data
    
    func generateInsightsFromActivity(steps: Int, calories: Int, previousSteps: Int? = nil) -> [AIInsight] {
        var insights: [AIInsight] = []
        let userId = KeychainManager.shared.getToken(forKey: Constants.KeychainKeys.firebaseUID) ?? "user"
        
        // Step achievement
        if steps >= 10000 {
            insights.append(AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: "🎉 Amazing! You've hit 10,000 steps today!",
                insightType: .achievement,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400)
            ))
        } else if steps >= 5000 {
            let remaining = 10000 - steps
            insights.append(AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: "Great progress! Just \(remaining) more steps to reach 10,000!",
                insightType: .motivational,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400)
            ))
        }
        
        // Calorie achievement
        if calories >= 500 {
            insights.append(AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: "Excellent! You've burned \(calories) calories today! 🔥",
                insightType: .achievement,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400)
            ))
        }
        
        // Trend comparison
        if let previousSteps = previousSteps, steps > previousSteps {
            let increase = ((Double(steps) - Double(previousSteps)) / Double(previousSteps)) * 100
            insights.append(AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: String(format: "You're %.0f%% more active than yesterday! Keep it up! 📈", increase),
                insightType: .trend,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400)
            ))
        }
        
        // Recommendation
        if steps < 5000 {
            insights.append(AIInsight(
                id: UUID().uuidString,
                userId: userId,
                message: "Try taking a 15-minute walk to boost your step count!",
                insightType: .recommendation,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400)
            ))
        }
        
        return insights
    }
}

