//
//  ActivityCardView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI

struct ActivityCardView: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Title
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Value
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            
            // Subtitle
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    HStack(spacing: 12) {
        ActivityCardView(
            icon: "figure.walk",
            title: "Steps",
            value: "7,543",
            subtitle: "of 10,000",
            color: .blue
        )
        
        ActivityCardView(
            icon: "flame.fill",
            title: "Calories",
            value: "432",
            subtitle: "kcal",
            color: .orange
        )
    }
    .padding()
    .background(Color.primaryBackground)
}

