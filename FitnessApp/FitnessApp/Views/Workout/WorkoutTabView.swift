//
//  WorkoutTabView.swift
//  FitnessApp
//
//  Shell view for the Workout tab. Start-workout experience is future work.
//

import SwiftUI

struct WorkoutTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                    
                    Text("Start a workout")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Begin and track your workouts here. Coming soon.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    WorkoutTabView()
}
