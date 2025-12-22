//
//  OnboardingStepView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI
import UserNotifications

// MARK: - Step 1: Welcome

struct WelcomeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.accentColor)
                
                VStack(spacing: 16) {
                    Text("Welcome to FitnessApp!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Let's set up your fitness profile and start tracking your journey to better health")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 20) {
                    FeatureRow(icon: "chart.bar.fill", title: "Track Progress", description: "Monitor your fitness metrics daily")
                    FeatureRow(icon: "applewatch", title: "Apple Watch Sync", description: "Connect your Apple Watch data")
                    FeatureRow(icon: "sparkles", title: "AI Insights", description: "Get personalized recommendations")
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                Spacer(minLength: 60)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.accentColor)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Step 2: Profile Setup

struct ProfileStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, age, weight, height
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Your Profile")
                        .font(.title.bold())
                    
                    Text("Tell us a bit about yourself")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your name", text: $viewModel.name)
                            .textContentType(.name)
                            .autocapitalization(.words)
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .name)
                    }
                    
                    // Age
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your age", text: $viewModel.age)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(10)
                            .focused($focusedField, equals: .age)
                        
                        if !viewModel.age.isEmpty, let age = Int(viewModel.age), !ValidationHelpers.isValidAge(age) {
                            Text(ValidationHelpers.ageErrorMessage())
                                .font(.caption)
                                .foregroundColor(.errorRed)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        // Weight
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight (kg)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("70", text: $viewModel.weight)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(10)
                                .focused($focusedField, equals: .weight)
                        }
                        
                        // Height
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Height (cm)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("170", text: $viewModel.height)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(10)
                                .focused($focusedField, equals: .height)
                        }
                    }
                    
                    // BMI Preview (if valid data)
                    if let weight = Double(viewModel.weight),
                       let height = Double(viewModel.height),
                       ValidationHelpers.isValidWeight(weight),
                       ValidationHelpers.isValidHeight(height) {
                        let bmi = weight / pow(height / 100, 2)
                        
                        HStack {
                            Text("Your BMI:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f", bmi))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 40)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Step 3: Fitness Goals

struct GoalsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Your Goals")
                        .font(.title.bold())
                    
                    Text("What do you want to achieve?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Goals Selection
                VStack(spacing: 12) {
                    ForEach(FitnessProfile.FitnessGoal.allCases, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: viewModel.selectedGoals.contains(goal),
                            onTap: {
                                if viewModel.selectedGoals.contains(goal) {
                                    viewModel.selectedGoals.remove(goal)
                                } else {
                                    viewModel.selectedGoals.insert(goal)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                // Activity Level
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity Level")
                        .font(.headline)
                        .padding(.horizontal, 32)
                    
                    ForEach(FitnessProfile.ActivityLevel.allCases, id: \.self) { level in
                        ActivityLevelCard(
                            level: level,
                            isSelected: viewModel.selectedActivityLevel == level,
                            onTap: {
                                viewModel.selectedActivityLevel = level
                            }
                        )
                    }
                }
                .padding(.top, 16)
                
                Spacer(minLength: 40)
            }
        }
    }
}

struct GoalCard: View {
    let goal: FitnessProfile.FitnessGoal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .accentColor)
                    .frame(width: 44)
                
                Text(goal.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor : Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct ActivityLevelCard: View {
    let level: FitnessProfile.ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor : Color.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 4: HealthKit Permissions

struct HealthKitStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                
                VStack(spacing: 16) {
                    Text("Connect Apple Health")
                        .font(.title.bold())
                    
                    Text("Sync your Apple Watch and iPhone health data for comprehensive tracking")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 16) {
                    PermissionRow(icon: "figure.walk", text: "Daily step count")
                    PermissionRow(icon: "flame.fill", text: "Calories burned")
                    PermissionRow(icon: "heart.fill", text: "Heart rate data")
                    PermissionRow(icon: "figure.run", text: "Workout sessions")
                }
                .padding(.horizontal, 32)
                
                if !viewModel.healthKitPermissionGranted {
                    Button {
                        viewModel.requestHealthKitPermissions()
                    } label: {
                        Text("Grant Access")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 32)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.successGreen)
                        Text("Access Granted")
                            .fontWeight(.semibold)
                    }
                    .padding()
                }
                
                Text("You can change this later in Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer(minLength: 60)
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(10)
    }
}

// MARK: - Step 5: Notifications

struct NotificationsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)
                
                Image(systemName: "bell.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.accentColor)
                
                VStack(spacing: 16) {
                    Text("Stay Motivated")
                        .font(.title.bold())
                    
                    Text("Get reminders and encouragement to reach your fitness goals")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 16) {
                    NotificationTypeRow(icon: "bell.fill", title: "Daily Reminders", description: "Don't forget your workouts")
                    NotificationTypeRow(icon: "trophy.fill", title: "Achievements", description: "Celebrate your milestones")
                    NotificationTypeRow(icon: "sparkles", title: "AI Insights", description: "Personalized tips and trends")
                }
                .padding(.horizontal, 32)
                
                if !viewModel.notificationPermissionGranted {
                    Button {
                        Task {
                            await viewModel.requestNotificationPermissions()
                        }
                    } label: {
                        Text("Enable Notifications")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 32)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.successGreen)
                        Text("Notifications Enabled")
                            .fontWeight(.semibold)
                    }
                    .padding()
                }
                
                Text("You can customize notifications in Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer(minLength: 60)
            }
        }
    }
}

struct NotificationTypeRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

#Preview("Welcome") {
    WelcomeStepView(viewModel: OnboardingViewModel())
}

#Preview("Profile") {
    ProfileStepView(viewModel: OnboardingViewModel())
}

#Preview("Goals") {
    GoalsStepView(viewModel: OnboardingViewModel())
}

#Preview("HealthKit") {
    HealthKitStepView(viewModel: OnboardingViewModel())
}

#Preview("Notifications") {
    NotificationsStepView(viewModel: OnboardingViewModel())
}

