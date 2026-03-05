//
//  PlanTabView.swift
//  FitnessApp
//
//  Shell view for the Plan tab. Full workout planning experience is future work.
//

import SwiftUI

struct PlanTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                    
                    Text("Plan your workouts")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Create and schedule your workouts here. Coming soon.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Plan")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    PlanTabView()
}
