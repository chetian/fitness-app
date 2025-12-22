//
//  ProfileViewModel.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var user: User?
    @Published var isEditing = false
    @Published var isSaving = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSignOutConfirmation = false
    @Published var successMessage: String?
    @Published var showSuccess = false
    
    // Edit state
    @Published var editedDisplayName = ""
    @Published var editedAge = ""
    @Published var editedWeight = ""
    @Published var editedHeight = ""
    @Published var editedWeightGoal = ""
    @Published var editedGoals: Set<FitnessProfile.FitnessGoal> = []
    @Published var editedActivityLevel: FitnessProfile.ActivityLevel = .moderatelyActive
    
    // MARK: - Services
    
    private let databaseService = DatabaseService.shared
    private let authService = AuthenticationService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var canSave: Bool {
        guard !editedDisplayName.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard let age = Int(editedAge), ValidationHelpers.isValidAge(age) else { return false }
        guard let weight = Double(editedWeight), ValidationHelpers.isValidWeight(weight) else { return false }
        guard let height = Double(editedHeight), ValidationHelpers.isValidHeight(height) else { return false }
        return !editedGoals.isEmpty
    }
    
    var formattedCreatedDate: String {
        guard let user = user else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: user.createdAt)
    }
    
    // MARK: - Initialization
    
    init() {
        setupAuthStateObserver()
    }
    
    private func setupAuthStateObserver() {
        NotificationCenter.default.publisher(for: NSNotification.Name(Constants.NotificationKeys.authStateChanged))
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.loadUserProfile()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Profile
    
    func loadUserProfile() async {
        guard let firebaseUser = authService.currentUser else {
            errorMessage = "No authenticated user"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            let fetchedUser = try await databaseService.fetchUser(authId: firebaseUser.uid)
            self.user = fetchedUser
            populateEditFields(from: fetchedUser)
            print("Profile loaded successfully")
        } catch {
            errorMessage = "Failed to load profile. Please try again."
            showError = true
            print("Error loading profile: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Edit Profile
    
    func startEditing() {
        guard let user = user else { return }
        populateEditFields(from: user)
        isEditing = true
    }
    
    func cancelEditing() {
        guard let user = user else { return }
        populateEditFields(from: user)
        isEditing = false
    }
    
    private func populateEditFields(from user: User) {
        editedDisplayName = user.displayName
        editedAge = "\(user.fitnessProfile.age)"
        editedWeight = "\(user.fitnessProfile.weight)"
        editedHeight = "\(user.fitnessProfile.height)"
        editedWeightGoal = user.fitnessProfile.weightGoal != nil ? "\(user.fitnessProfile.weightGoal!)" : ""
        editedGoals = Set(user.fitnessProfile.fitnessGoals)
        editedActivityLevel = user.fitnessProfile.activityLevel
    }
    
    func saveProfileChanges() async {
        guard var currentUser = user else { return }
        guard canSave else {
            errorMessage = "Please fill in all required fields correctly"
            showError = true
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        // Update user object
        currentUser.displayName = editedDisplayName.trimmingCharacters(in: .whitespaces)
        currentUser.fitnessProfile.age = Int(editedAge) ?? currentUser.fitnessProfile.age
        currentUser.fitnessProfile.weight = Double(editedWeight) ?? currentUser.fitnessProfile.weight
        currentUser.fitnessProfile.height = Double(editedHeight) ?? currentUser.fitnessProfile.height
        currentUser.fitnessProfile.weightGoal = editedWeightGoal.isEmpty ? nil : Double(editedWeightGoal)
        currentUser.fitnessProfile.fitnessGoals = Array(editedGoals)
        currentUser.fitnessProfile.activityLevel = editedActivityLevel
        currentUser.updatedAt = Date()
        
        do {
            let updatedUser = try await databaseService.updateUser(
                authId: currentUser.firebaseUid,
                user: currentUser
            )
            
            self.user = updatedUser
            self.isEditing = false
            successMessage = "Profile updated successfully!"
            showSuccess = true
            
            // Hide success message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showSuccess = false
                self.successMessage = nil
            }
            
            print("Profile updated successfully")
            
        } catch {
            errorMessage = "Failed to save changes. Please try again."
            showError = true
            print("Error saving profile: \(error)")
        }
        
        isSaving = false
    }
    
    // MARK: - Sign Out
    
    func requestSignOut() {
        showSignOutConfirmation = true
    }
    
    func handleSignOut() async {
        do {
            try authService.signOut()
            self.user = nil
            print("User signed out successfully")
            
            // Post notification to reset app state
            NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationKeys.authStateChanged), object: nil)
            
        } catch {
            errorMessage = "Failed to sign out. Please try again."
            showError = true
            print("Error signing out: \(error)")
        }
    }
    
    // MARK: - Validation
    
    func validateField(_ field: String) -> String? {
        switch field {
        case "displayName":
            if editedDisplayName.trimmingCharacters(in: .whitespaces).isEmpty {
                return "Name is required"
            }
        case "age":
            guard let age = Int(editedAge) else {
                return "Invalid age"
            }
            if !ValidationHelpers.isValidAge(age) {
                return "Age must be between \(Constants.ValidationRanges.ageMin) and \(Constants.ValidationRanges.ageMax)"
            }
        case "weight":
            guard let weight = Double(editedWeight) else {
                return "Invalid weight"
            }
            if !ValidationHelpers.isValidWeight(weight) {
                return "Weight must be between \(Constants.ValidationRanges.weightMin) and \(Constants.ValidationRanges.weightMax) kg"
            }
        case "height":
            guard let height = Double(editedHeight) else {
                return "Invalid height"
            }
            if !ValidationHelpers.isValidHeight(height) {
                return "Height must be between \(Constants.ValidationRanges.heightMin) and \(Constants.ValidationRanges.heightMax) cm"
            }
        default:
            break
        }
        return nil
    }
}

