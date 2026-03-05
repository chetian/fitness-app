//
//  ActivitiesTabView.swift
//  FitnessApp
//
//  Shell view for the Activities tab. Workout history/list experience is future work.
//

import SwiftUI

struct ActivitiesTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                    
                    Text("Your activities")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("View your past workouts and activity history here. Coming soon.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ActivitiesTabView()
}
