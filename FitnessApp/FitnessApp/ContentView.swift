//
//  ContentView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.isLoadingProfile {
                    // Checking if user profile exists in database
                    ProgressView("Loading profile...")
                } else if let user = authViewModel.currentUser {
                    // User exists in database
                    if user.onboardingCompleted {
                        // Main tab bar (Today, Plan, Workout, Activities, Profile)
                        MainTabView(authViewModel: authViewModel)
                    } else {
                        // Existing user who hasn't completed onboarding - can resume progress
                        OnboardingPlaceholderView(viewModel: authViewModel, isNewUser: false)
                    }
                } else {
                    // New user - no profile in database, needs onboarding
                    OnboardingPlaceholderView(viewModel: authViewModel, isNewUser: true)
                }
            } else {
                // Authentication
                AuthenticationView()
            }
        }
    }
}

// MARK: - Placeholder Views

struct DashboardPlaceholderView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        DashboardView(authViewModel: authViewModel)
    }
}

struct OnboardingPlaceholderView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    var isNewUser: Bool = true
    
    var body: some View {
        OnboardingContainerView(isNewUser: isNewUser)
    }
}

#Preview {
    ContentView()
}
