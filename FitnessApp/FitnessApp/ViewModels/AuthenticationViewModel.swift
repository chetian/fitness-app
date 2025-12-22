//
//  AuthenticationViewModel.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var isLoadingProfile = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    @Published var showError = false
    
    // MARK: - Services
    
    private let authService = AuthenticationService.shared
    private let databaseService = DatabaseService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateObserver()
        checkAuthenticationState()
    }
    
    // MARK: - Setup
    
    private func setupAuthStateObserver() {
        NotificationCenter.default.publisher(for: NSNotification.Name(Constants.NotificationKeys.authStateChanged))
            .sink { [weak self] notification in
                Task { @MainActor in
                    if let firebaseUser = notification.object as? FirebaseAuth.User {
                        self?.isAuthenticated = true
                        await self?.fetchOrCreateUserProfile(firebaseUser: firebaseUser)
                    } else {
                        self?.isAuthenticated = false
                        self?.currentUser = nil
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthenticationState() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🔍 CHECKING AUTHENTICATION STATE")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Firebase Auth Current User: \(authService.currentUser?.email ?? "none")")
        print("Firebase Auth UID: \(authService.currentUser?.uid ?? "none")")
        print("Is Authenticated: \(authService.isAuthenticated)")
        
        isAuthenticated = authService.isAuthenticated
        
        if let firebaseUser = authService.currentUser {
            print("✅ User is authenticated, fetching profile...")
            Task {
                await fetchOrCreateUserProfile(firebaseUser: firebaseUser)
            }
        } else {
            print("❌ No authenticated user found")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    
    // MARK: - Authentication Methods
    
    func handleAppleSignIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithApple()
            print("Apple Sign-In successful: \(result.user.uid)")
            // Auth state observer will handle the rest
        } catch let error as AuthenticationError {
            if error != .cancelled {
                errorMessage = error.errorDescription
                showError = true
            }
        } catch {
            errorMessage = "An unexpected error occurred"
            showError = true
        }
        
        isLoading = false
    }
    
    func handleGoogleSignIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithGoogle()
            print("Google Sign-In successful: \(result.user.uid)")
            // Auth state observer will handle the rest
        } catch let error as AuthenticationError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = "An unexpected error occurred"
            showError = true
        }
        
        isLoading = false
    }
    
    func handleEmailSignIn(email: String, password: String) async {
        // Validate input
        guard ValidationHelpers.isValidEmail(email) else {
            errorMessage = ValidationHelpers.emailErrorMessage()
            showError = true
            return
        }
        
        guard ValidationHelpers.isValidPassword(password) else {
            errorMessage = ValidationHelpers.passwordErrorMessage()
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithEmail(email: email, password: password)
            print("Email Sign-In successful: \(result.user.uid)")
            // Auth state observer will handle the rest
        } catch let error as AuthenticationError {
            errorMessage = error.errorDescription
            showError = true
        } catch {
            errorMessage = "An unexpected error occurred"
            showError = true
        }
        
        isLoading = false
    }
    
    func handleEmailSignUp(email: String, password: String, displayName: String) async {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📧 EMAIL SIGN-UP STARTED")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Email: \(email)")
        print("Display Name: \(displayName)")
        print("Current Firebase User: \(authService.currentUser?.email ?? "none")")
        print("Current isAuthenticated: \(isAuthenticated)")
        
        // Validate input
        guard ValidationHelpers.isValidEmail(email) else {
            print("❌ Validation failed: Invalid email")
            errorMessage = ValidationHelpers.emailErrorMessage()
            showError = true
            return
        }
        
        guard ValidationHelpers.isValidPassword(password) else {
            print("❌ Validation failed: Invalid password")
            errorMessage = ValidationHelpers.passwordErrorMessage()
            showError = true
            return
        }
        
        guard !displayName.isEmpty else {
            print("❌ Validation failed: Empty display name")
            errorMessage = "Please enter your name"
            showError = true
            return
        }
        
        print("✅ Validation passed")
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("📤 Calling authService.signUpWithEmail...")
            let result = try await authService.signUpWithEmail(email: email, password: password)
            print("✅ Email Sign-Up successful: \(result.user.uid)")
            print("   User email: \(result.user.email ?? "none")")
            
            // Update display name
            print("📝 Updating display name to: \(displayName)")
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            print("✅ Display name updated")
            
            print("⏳ Waiting for auth state observer to handle profile creation...")
            // Auth state observer will handle profile creation
        } catch let error as AuthenticationError {
            print("❌ AuthenticationError: \(error)")
            errorMessage = error.errorDescription
            showError = true
        } catch let error as NSError {
            print("❌ NSError caught:")
            print("   Domain: \(error.domain)")
            print("   Code: \(error.code)")
            print("   Description: \(error.localizedDescription)")
            print("   UserInfo: \(error.userInfo)")
            errorMessage = "An error occurred: \(error.localizedDescription)"
            showError = true
        } catch {
            print("❌ Unknown error: \(error)")
            errorMessage = "An unexpected error occurred"
            showError = true
        }
        
        isLoading = false
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📧 EMAIL SIGN-UP COMPLETED")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    
    func signOut() {
        do {
            try authService.signOut()
            isAuthenticated = false
            currentUser = nil
            
            // Clear any cached state
            UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.onboardingCompleted)
            UserDefaults.standard.removeObject(forKey: "onboardingProgress")
            
            print("✅ Signed out successfully")
        } catch {
            errorMessage = "Failed to sign out. Please try again."
            showError = true
        }
    }
    
    // MARK: - User Profile Management
    
    private func fetchOrCreateUserProfile(firebaseUser: FirebaseAuth.User) async {
        isLoadingProfile = true
        defer { isLoadingProfile = false }
        
        do {
            // Try to fetch existing user
            print("📥 Fetching user profile from database...")
            let user = try await databaseService.fetchUser(authId: firebaseUser.uid)
            self.currentUser = user
            
            // Update last login
            var updatedUser = user
            updatedUser.lastLoginAt = Date()
            _ = try? await databaseService.updateUser(authId: firebaseUser.uid, user: updatedUser)
            
            print("✅ User profile loaded: \(user.email)")
            
        } catch NetworkError.unauthorized {
            print("❌ Unauthorized - signing out")
            errorMessage = "Session expired. Please sign in again."
            showError = true
            try? authService.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch NetworkError.serverError(let code) where code != 404 {
            // 5xx errors or non-404 errors - sign out
            print("❌ Server error (\(code)) - signing out")
            errorMessage = "Failed to load user profile. Please sign in again."
            showError = true
            try? authService.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            // User doesn't exist in MongoDB - this could be:
            // 1. Genuinely new user who just signed up
            // 2. Stale Firebase auth from previous installation
            print("⚠️ User not found in database")
            print("   Firebase UID: \(firebaseUser.uid)")
            print("   Email: \(firebaseUser.email ?? "none")")
            print("   Creation Date: \(firebaseUser.metadata.creationDate ?? Date())")
            print("   Last Sign In: \(firebaseUser.metadata.lastSignInDate ?? Date())")
            
            // Check if this is a fresh Firebase account (created recently)
            let accountAge = Date().timeIntervalSince(firebaseUser.metadata.creationDate ?? Date())
            let minutesSinceCreation = accountAge / 60
            
            if minutesSinceCreation < 5 {
                // Account created in last 5 minutes - this is a new user
                print("✅ New user detected (account age: \(Int(minutesSinceCreation)) minutes)")
                self.currentUser = nil
            } else {
                // Old account without profile - likely stale auth from reinstall
                print("⚠️ Stale auth detected (account age: \(Int(minutesSinceCreation / 60)) hours)")
                print("   Signing out and redirecting to login")
                try? authService.signOut()
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    func createUserProfile(displayName: String, email: String, authProvider: AuthProvider) async {
        guard let firebaseUser = authService.currentUser else {
            errorMessage = "No authenticated user found"
            showError = true
            return
        }
        
        isLoading = true
        
        // Create default fitness profile
        let defaultFitnessProfile = FitnessProfile(
            age: 25,
            weight: 70.0,
            height: 170.0,
            weightGoal: nil,
            fitnessGoals: [.generalFitness],
            activityLevel: .moderatelyActive
        )
        
        let newUser = User(
            id: "", // MongoDB will generate
            firebaseUid: firebaseUser.uid,
            email: email,
            displayName: displayName,
            authProvider: authProvider,
            profilePictureUrl: firebaseUser.photoURL?.absoluteString,
            createdAt: Date(),
            updatedAt: Date(),
            lastLoginAt: Date(),
            fitnessProfile: defaultFitnessProfile,
            notificationPreferences: NotificationPreferences.defaultPreferences,
            healthKitEnabled: false,
            onboardingCompleted: false
        )
        
        do {
            let createdUser = try await databaseService.createUser(newUser)
            self.currentUser = createdUser
            print("User profile created: \(createdUser.email)")
        } catch {
            errorMessage = "Failed to create user profile. Please try again."
            showError = true
        }
        
        isLoading = false
    }
}

