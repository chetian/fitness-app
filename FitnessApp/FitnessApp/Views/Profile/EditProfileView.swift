//
//  EditProfileView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI

struct EditProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Info Section
                    BasicInfoSection(viewModel: viewModel)
                    
                    // Physical Stats Section
                    PhysicalStatsSection(viewModel: viewModel)
                    
                    // Fitness Goals Section
                    FitnessGoalsSection(viewModel: viewModel)
                    
                    // Activity Level Section
                    ActivityLevelSection(viewModel: viewModel)
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            
            // Save Button (floating)
            VStack {
                Spacer()
                SaveButtonView(viewModel: viewModel, dismiss: dismiss)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    viewModel.cancelEditing()
                    dismiss()
                }
            }
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(viewModel.successMessage ?? "Profile updated successfully!")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
}

// MARK: - Basic Info Section

struct BasicInfoSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.headline)
            
            VStack(spacing: 16) {
                ValidatedTextField(
                    label: "Display Name",
                    text: $viewModel.editedDisplayName,
                    placeholder: "Your name",
                    validation: { viewModel.validateField("displayName") }
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Physical Stats Section

struct PhysicalStatsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Physical Stats")
                .font(.headline)
            
            VStack(spacing: 16) {
                ValidatedTextField(
                    label: "Age",
                    text: $viewModel.editedAge,
                    placeholder: "25",
                    keyboardType: .numberPad,
                    validation: { viewModel.validateField("age") }
                )
                
                ValidatedTextField(
                    label: "Weight (kg)",
                    text: $viewModel.editedWeight,
                    placeholder: "70",
                    keyboardType: .decimalPad,
                    validation: { viewModel.validateField("weight") }
                )
                
                ValidatedTextField(
                    label: "Height (cm)",
                    text: $viewModel.editedHeight,
                    placeholder: "175",
                    keyboardType: .decimalPad,
                    validation: { viewModel.validateField("height") }
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Fitness Goals Section

struct FitnessGoalsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fitness Goals")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(FitnessProfile.FitnessGoal.allCases, id: \.self) { goal in
                    GoalToggle(
                        goal: goal,
                        isSelected: viewModel.editedGoals.contains(goal),
                        action: {
                            if viewModel.editedGoals.contains(goal) {
                                viewModel.editedGoals.remove(goal)
                            } else {
                                viewModel.editedGoals.insert(goal)
                            }
                        }
                    )
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            
            if viewModel.editedGoals.isEmpty {
                Text("Please select at least one goal")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Activity Level Section

struct ActivityLevelSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Level")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(FitnessProfile.ActivityLevel.allCases, id: \.self) { level in
                    ActivityLevelOption(
                        level: level,
                        isSelected: viewModel.editedActivityLevel == level,
                        action: { viewModel.editedActivityLevel = level }
                    )
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Save Button

struct SaveButtonView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: {
                Task {
                    await viewModel.saveProfileChanges()
                }
            }) {
                Group {
                    if viewModel.isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Save Changes")
                            .font(.headline)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(viewModel.canSave ? Color.accentColor : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!viewModel.canSave || viewModel.isSaving)
            .padding()
            .background(Color.primaryBackground)
        }
    }
}

// MARK: - Reusable Components

struct ValidatedTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    let validation: () -> String?
    
    @State private var isFocused = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.secondaryBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(errorBorderColor, lineWidth: 1)
                )
            
            if let error = validation() {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var errorBorderColor: Color {
        if let _ = validation() {
            return .red
        }
        return .clear
    }
}

struct GoalToggle: View {
    let goal: FitnessProfile.FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.secondaryBackground)
            .cornerRadius(8)
        }
    }
}

struct ActivityLevelOption: View {
    let level: FitnessProfile.ActivityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.body.weight(isSelected ? .semibold : .regular))
                        .foregroundColor(.primary)
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .font(.title3)
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.secondaryBackground)
            .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView(viewModel: ProfileViewModel())
    }
}

