//
//  OnboardingViewModel.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import UserNotifications

@MainActor
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentStep = 0
    @Published var name = ""
    @Published var age = ""
    @Published var weight = ""
    @Published var height = ""
    @Published var selectedGoals: Set<FitnessProfile.FitnessGoal> = []
    @Published var selectedActivityLevel: FitnessProfile.ActivityLevel = .moderatelyActive
    @Published var healthKitPermissionGranted = false
    @Published var notificationPermissionGranted = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Constants
    
    let totalSteps = 5
    
    // MARK: - Services
    
    private let databaseService = DatabaseService.shared
    private let authService = AuthenticationService.shared
    
    // MARK: - Computed Properties
    
    var progress: Double {
        return Double(currentStep) / Double(totalSteps)
    }
    
    var canProceedFromCurrentStep: Bool {
        switch currentStep {
        case 0: // Welcome
            return true
        case 1: // Profile
            return isProfileDataValid
        case 2: // Goals
            return !selectedGoals.isEmpty
        case 3: // HealthKit
            return true // Optional
        case 4: // Notifications
            return true // Optional
        default:
            return false
        }
    }
    
    private var isProfileDataValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        
        guard let ageInt = Int(age), ValidationHelpers.isValidAge(ageInt) else { return false }
        
        guard let weightDouble = Double(weight), ValidationHelpers.isValidWeight(weightDouble) else { return false }
        
        guard let heightDouble = Double(height), ValidationHelpers.isValidHeight(heightDouble) else { return false }
        
        return true
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation {
                currentStep += 1
            }
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation {
                currentStep -= 1
            }
        }
    }
    
    func skipStep() {
        nextStep()
    }
    
    // MARK: - Data Validation
    
    func validateProfileData() -> String? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Please enter your name"
        }
        
        guard let ageInt = Int(age) else {
            return "Please enter a valid age"
        }
        
        if !ValidationHelpers.isValidAge(ageInt) {
            return ValidationHelpers.ageErrorMessage()
        }
        
        guard let weightDouble = Double(weight) else {
            return "Please enter a valid weight"
        }
        
        if !ValidationHelpers.isValidWeight(weightDouble) {
            return ValidationHelpers.weightErrorMessage()
        }
        
        guard let heightDouble = Double(height) else {
            return "Please enter a valid height"
        }
        
        if !ValidationHelpers.isValidHeight(heightDouble) {
            return ValidationHelpers.heightErrorMessage()
        }
        
        return nil
    }
    
    // MARK: - Permissions
    
    func requestHealthKitPermissions() {
        // This will be implemented in HealthKitService
        // For now, just mark as granted for UI flow
        healthKitPermissionGranted = true
        print("HealthKit permissions requested (implementation pending)")
    }
    
    func requestNotificationPermissions() async {
        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            notificationPermissionGranted = granted
            if granted {
                print("Notification permissions granted")
            }
        } catch {
            print("Error requesting notification permissions: \(error)")
        }
    }
    
    // MARK: - Save Profile
    
    func saveProfile() async {
        guard let firebaseUser = authService.currentUser else {
            errorMessage = "No authenticated user found"
            showError = true
            return
        }
        
        // Validate data
        if let validationError = validateProfileData() {
            errorMessage = validationError
            showError = true
            return
        }
        
        isLoading = true
        
        // Parse values
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightDouble = Double(height) else {
            errorMessage = "Invalid profile data"
            showError = true
            isLoading = false
            return
        }
        
        // Create fitness profile
        let fitnessProfile = FitnessProfile(
            age: ageInt,
            weight: weightDouble,
            height: heightDouble,
            weightGoal: nil,
            fitnessGoals: Array(selectedGoals),
            activityLevel: selectedActivityLevel
        )
        
        // Create user
        let newUser = User(
            id: "", // MongoDB will generate
            firebaseUid: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: name,
            authProvider: determineAuthProvider(from: firebaseUser),
            profilePictureUrl: firebaseUser.photoURL?.absoluteString,
            createdAt: Date(),
            updatedAt: Date(),
            lastLoginAt: Date(),
            fitnessProfile: fitnessProfile,
            notificationPreferences: .defaultPreferences,
            healthKitEnabled: healthKitPermissionGranted,
            onboardingCompleted: true
        )
        
        do {
            let createdUser = try await databaseService.createUser(newUser)
            print("User profile created successfully: \(createdUser.email)")
            
            // Save onboarding completion to UserDefaults
            UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.onboardingCompleted)
            
            // Notify auth view model to refresh user
            NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationKeys.authStateChanged), object: firebaseUser)
            
        } catch {
            errorMessage = "Failed to save profile. Please try again."
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    private func determineAuthProvider(from firebaseUser: FirebaseAuth.User) -> AuthProvider {
        guard let providerData = firebaseUser.providerData.first else {
            return .email
        }
        
        switch providerData.providerID {
        case "apple.com":
            return .apple
        case "google.com":
            return .google
        default:
            return .email
        }
    }
    
    func saveProgress() {
        // Save current onboarding state to UserDefaults for resume capability
        let progress: [String: Any] = [
            "currentStep": currentStep,
            "name": name,
            "age": age,
            "weight": weight,
            "height": height,
            "selectedGoals": selectedGoals.map { $0.rawValue },
            "activityLevel": selectedActivityLevel.rawValue,
            "healthKitGranted": healthKitPermissionGranted,
            "notificationGranted": notificationPermissionGranted
        ]
        
        UserDefaults.standard.set(progress, forKey: "onboardingProgress")
    }
    
    func loadProgress() {
        guard let progress = UserDefaults.standard.dictionary(forKey: "onboardingProgress") else {
            return
        }
        
        currentStep = progress["currentStep"] as? Int ?? 0
        name = progress["name"] as? String ?? ""
        age = progress["age"] as? String ?? ""
        weight = progress["weight"] as? String ?? ""
        height = progress["height"] as? String ?? ""
        
        if let goalStrings = progress["selectedGoals"] as? [String] {
            selectedGoals = Set(goalStrings.compactMap { FitnessProfile.FitnessGoal(rawValue: $0) })
        }
        
        if let activityLevelString = progress["activityLevel"] as? String,
           let activityLevel = FitnessProfile.ActivityLevel(rawValue: activityLevelString) {
            selectedActivityLevel = activityLevel
        }
        
        healthKitPermissionGranted = progress["healthKitGranted"] as? Bool ?? false
        notificationPermissionGranted = progress["notificationGranted"] as? Bool ?? false
    }
    
    func clearProgress() {
        UserDefaults.standard.removeObject(forKey: "onboardingProgress")
        
        // Reset all fields to defaults
        currentStep = 0
        age = ""
        weight = ""
        height = ""
        selectedGoals = []
        selectedActivityLevel = .moderatelyActive
        healthKitPermissionGranted = false
        notificationPermissionGranted = false
        
        // Pre-populate name from Firebase user if available
        if let firebaseUser = authService.currentUser,
           let displayName = firebaseUser.displayName, !displayName.isEmpty {
            name = displayName
            print("🧹 Onboarding progress cleared, pre-populated name: \(displayName)")
        } else {
            name = ""
            print("🧹 Onboarding progress cleared")
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            clearProgress()
            print("✅ Signed out from onboarding")
            
            // Post notification to update auth state
            NotificationCenter.default.post(
                name: NSNotification.Name(Constants.NotificationKeys.authStateChanged),
                object: nil
            )
        } catch {
            errorMessage = "Failed to sign out. Please try again."
            showError = true
        }
    }
}

