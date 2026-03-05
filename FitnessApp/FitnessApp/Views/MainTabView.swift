//
//  MainTabView.swift
//  FitnessApp
//
//  Bottom tab bar container with five tabs: Today, Plan, Workout, Activities, Profile.
//

import SwiftUI

// MARK: - Tab Selection

enum AppTab: Int, CaseIterable {
    case today = 0
    case plan
    case workout
    case activities
    case profile
    
    var title: String {
        switch self {
        case .today: return "Today"
        case .plan: return "Plan"
        case .workout: return "Workout"
        case .activities: return "Activities"
        case .profile: return "Profile"
        }
    }
    
    var systemImage: String {
        switch self {
        case .today: return "house.fill"
        case .plan: return "calendar"
        case .workout: return "figure.run"
        case .activities: return "list.bullet.clipboard"
        case .profile: return "person.fill"
        }
    }
    
    var accessibilityLabel: String {
        title
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab: AppTab = .today
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardPlaceholderView(authViewModel: authViewModel)
                .tabItem {
                    Label(AppTab.today.title, systemImage: AppTab.today.systemImage)
                }
                .tag(AppTab.today)
                .accessibilityLabel(AppTab.today.accessibilityLabel)
                .accessibilityHint("Shows your dashboard and today's activity")
            
            PlanTabView()
                .tabItem {
                    Label(AppTab.plan.title, systemImage: AppTab.plan.systemImage)
                }
                .tag(AppTab.plan)
                .accessibilityLabel(AppTab.plan.accessibilityLabel)
                .accessibilityHint("Plan your workouts")
            
            WorkoutTabView()
                .tabItem {
                    Label(AppTab.workout.title, systemImage: AppTab.workout.systemImage)
                }
                .tag(AppTab.workout)
                .accessibilityLabel(AppTab.workout.accessibilityLabel)
                .accessibilityHint("Start a workout")
            
            ActivitiesTabView()
                .tabItem {
                    Label(AppTab.activities.title, systemImage: AppTab.activities.systemImage)
                }
                .tag(AppTab.activities)
                .accessibilityLabel(AppTab.activities.accessibilityLabel)
                .accessibilityHint("View your activity history")
            
            ProfilePlaceholderView(authViewModel: authViewModel)
                .tabItem {
                    Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
                }
                .tag(AppTab.profile)
                .accessibilityLabel(AppTab.profile.accessibilityLabel)
                .accessibilityHint("View profile and settings")
        }
        .tint(.accentColor)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(Color.cardBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView(authViewModel: AuthenticationViewModel())
}
