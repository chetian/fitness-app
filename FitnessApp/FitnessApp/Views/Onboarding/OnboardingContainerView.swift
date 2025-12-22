//
//  OnboardingContainerView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI

struct OnboardingContainerView: View {
    
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.colorScheme) var colorScheme
    var isNewUser: Bool = true // Default to true to start fresh
    @State private var showSignOutConfirmation = false
    
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with progress and sign out
                HStack {
                    Spacer()
                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.backward.circle")
                            Text("Sign Out")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                    }
                }
                
                // Progress Bar
                ProgressView(value: viewModel.progress)
                    .tint(.accentColor)
                    .padding(.horizontal)
                    .padding(.top, 4)
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(viewModel: viewModel)
                        .tag(0)
                    
                    ProfileStepView(viewModel: viewModel)
                        .tag(1)
                    
                    GoalsStepView(viewModel: viewModel)
                        .tag(2)
                    
                    HealthKitStepView(viewModel: viewModel)
                        .tag(3)
                    
                    NotificationsStepView(viewModel: viewModel)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    // Back Button
                    if viewModel.currentStep > 0 {
                        Button {
                            viewModel.previousStep()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.secondaryBackground)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Next/Skip/Finish Button
                    Button {
                        if viewModel.currentStep == viewModel.totalSteps - 1 {
                            // Finish onboarding
                            Task {
                                await viewModel.saveProfile()
                            }
                        } else {
                            viewModel.nextStep()
                            viewModel.saveProgress()
                        }
                    } label: {
                        HStack {
                            Text(buttonText)
                            if viewModel.currentStep < viewModel.totalSteps - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.canProceedFromCurrentStep ? Color.accentColor : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!viewModel.canProceedFromCurrentStep || viewModel.isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                // Skip Button (for optional steps)
                if showSkipButton {
                    Button {
                        viewModel.skipStep()
                    } label: {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                }
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Creating your profile...")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                viewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out? Your onboarding progress will be lost.")
        }
        .onAppear {
            if isNewUser {
                // Clear any saved progress for new users
                viewModel.clearProgress()
                print("🔄 Onboarding: Starting fresh for new user")
            } else {
                // Load saved progress for returning users
                viewModel.loadProgress()
                print("🔄 Onboarding: Loading saved progress")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var buttonText: String {
        if viewModel.currentStep == viewModel.totalSteps - 1 {
            return "Finish"
        } else {
            return "Next"
        }
    }
    
    private var showSkipButton: Bool {
        // Show skip button for HealthKit and Notifications steps
        return viewModel.currentStep == 3 || viewModel.currentStep == 4
    }
}

#Preview {
    OnboardingContainerView()
}

