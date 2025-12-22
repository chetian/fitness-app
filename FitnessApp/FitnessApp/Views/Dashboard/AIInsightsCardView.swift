//
//  AIInsightsCardView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI

struct AIInsightsCardView: View {
    let insight: AIInsight
    
    var backgroundColor: Color {
        switch insight.insightType {
        case .motivational: return Color.orange.opacity(0.1)
        case .achievement: return Color.yellow.opacity(0.1)
        case .recommendation: return Color.blue.opacity(0.1)
        case .trend: return Color.purple.opacity(0.1)
        }
    }
    
    var iconColor: Color {
        switch insight.insightType {
        case .motivational: return .orange
        case .achievement: return .yellow
        case .recommendation: return .blue
        case .trend: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: insight.insightType.icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            // Message
            Text(insight.message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(iconColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        AIInsightsCardView(insight: AIInsight(
            id: "1",
            userId: "user",
            message: "You're off to a great start! Keep up the momentum! 💪",
            insightType: .motivational,
            generatedAt: Date(),
            displayUntil: Date()
        ))
        
        AIInsightsCardView(insight: AIInsight(
            id: "2",
            userId: "user",
            message: "Amazing! You've hit 10,000 steps today! 🎉",
            insightType: .achievement,
            generatedAt: Date(),
            displayUntil: Date()
        ))
        
        AIInsightsCardView(insight: AIInsight(
            id: "3",
            userId: "user",
            message: "Try adding 10 minutes of cardio to reach your weekly goal",
            insightType: .recommendation,
            generatedAt: Date(),
            displayUntil: Date()
        ))
        
        AIInsightsCardView(insight: AIInsight(
            id: "4",
            userId: "user",
            message: "You're 25% more active this week compared to last week!",
            insightType: .trend,
            generatedAt: Date(),
            displayUntil: Date()
        ))
    }
    .padding()
    .background(Color.primaryBackground)
}

