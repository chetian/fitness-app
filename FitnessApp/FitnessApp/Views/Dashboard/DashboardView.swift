//
//  DashboardView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    
    @StateObject private var viewModel = DashboardViewModel()
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        DashboardHeaderView(
                            greeting: viewModel.greeting,
                            userName: viewModel.userName,
                            profilePictureUrl: viewModel.currentUser?.profilePictureUrl
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Sync Status
                        if let lastSync = viewModel.lastSyncDate {
                            Text("Last updated: \(lastSync, style: .relative) ago")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Activity Summary Cards
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ActivityCardView(
                                    icon: "figure.walk",
                                    title: "Steps",
                                    value: "\(viewModel.todaySteps)",
                                    subtitle: "of 10,000",
                                    color: .blue
                                )
                                
                                ActivityCardView(
                                    icon: "flame.fill",
                                    title: "Calories",
                                    value: "\(viewModel.todayCalories)",
                                    subtitle: "kcal",
                                    color: .orange
                                )
                            }
                            
                            ActivityCardView(
                                icon: "clock.fill",
                                title: "Active Minutes",
                                value: "\(viewModel.todayActiveMinutes)",
                                subtitle: "minutes today",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                        
                        // Weekly Progress Chart
                        if !viewModel.weeklyData.isEmpty {
                            WeeklyChartView(data: viewModel.weeklyData)
                                .frame(height: 200)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                        
                        // AI Insights
                        if !viewModel.insights.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Insights")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.insights) { insight in
                                    AIInsightsCardView(insight: insight)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Empty State
                        if viewModel.todaySteps == 0 && !viewModel.isLoading {
                            EmptyStateView()
                                .padding()
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.refreshData()
                }
                
                // Loading Overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your data...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if let user = authViewModel.currentUser {
                await viewModel.loadDashboardData(user: user)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}

// MARK: - Dashboard Header

struct DashboardHeaderView: View {
    let greeting: String
    let userName: String
    let profilePictureUrl: String?
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Picture
            if let urlString = profilePictureUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.secondary)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.accentColor)
                    .frame(width: 50, height: 50)
            }
            
            // Greeting
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(userName)
                    .font(.title2.bold())
            }
            
            Spacer()
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Start Moving!")
                .font(.title2.bold())
            
            Text("Your activity data will appear here once you start moving or sync your Apple Watch")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Profile Placeholder

struct ProfilePlaceholderView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        ProfileView()
    }
}

#Preview {
    DashboardView(authViewModel: AuthenticationViewModel())
}

