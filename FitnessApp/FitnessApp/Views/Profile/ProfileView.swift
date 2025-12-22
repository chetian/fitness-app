//
//  ProfileView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading profile...")
                } else if let user = viewModel.user {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            ProfileHeaderView(user: user)
                            
                            // Personal Info Section
                            PersonalInfoSection(user: user)
                            
                            // App Settings Section
                            AppSettingsSection()
                            
                            // About Section
                            AboutSection(user: user)
                            
                            // Sign Out Button
                            SignOutButton(action: { viewModel.requestSignOut() })
                            
                            Spacer(minLength: 40)
                        }
                        .padding()
                    }
                } else {
                    Text("Unable to load profile")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.user != nil {
                        NavigationLink(destination: EditProfileView(viewModel: viewModel)) {
                            Text("Edit")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .alert("Sign Out", isPresented: $viewModel.showSignOutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await viewModel.handleSignOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .task {
            await viewModel.loadUserProfile()
        }
    }
}

// MARK: - Profile Header

struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(user.displayName.prefix(1).uppercased())
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Name
            Text(user.displayName)
                .font(.title2.bold())
            
            // Email
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Auth Provider Badge
            HStack(spacing: 4) {
                Image(systemName: authProviderIcon(user.authProvider))
                    .font(.caption)
                Text("Signed in with \(user.authProvider.displayName)")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
    
    private func authProviderIcon(_ provider: AuthProvider) -> String {
        switch provider {
        case .apple: return "apple.logo"
        case .google: return "g.circle.fill"
        case .email: return "envelope.fill"
        }
    }
}

// MARK: - Personal Info Section

struct PersonalInfoSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                InfoRow(label: "Age", value: "\(user.fitnessProfile.age) years")
                Divider().padding(.leading, 16)
                InfoRow(label: "Weight", value: "\(Int(user.fitnessProfile.weight)) kg")
                Divider().padding(.leading, 16)
                InfoRow(label: "Height", value: "\(Int(user.fitnessProfile.height)) cm")
                Divider().padding(.leading, 16)
                InfoRow(label: "Activity Level", value: user.fitnessProfile.activityLevel.displayName)
                Divider().padding(.leading, 16)
                InfoRow(label: "Fitness Goals", value: "\(user.fitnessProfile.fitnessGoals.count) goals")
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - App Settings Section

struct AppSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Settings")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                NavigationLink(destination: Text("Notifications").navigationTitle("Notifications")) {
                    SettingsRow(icon: "bell.fill", label: "Notifications", value: "")
                }
                Divider().padding(.leading, 52)
                
                NavigationLink(destination: Text("Privacy").navigationTitle("Privacy")) {
                    SettingsRow(icon: "lock.fill", label: "Privacy", value: "")
                }
                Divider().padding(.leading, 52)
                
                NavigationLink(destination: Text("Data & Storage").navigationTitle("Data & Storage")) {
                    SettingsRow(icon: "externaldrive.fill", label: "Data & Storage", value: "")
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - About Section

struct AboutSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                InfoRow(label: "App Version", value: Constants.appVersion)
                Divider().padding(.leading, 16)
                InfoRow(label: "Member Since", value: formattedDate(user.createdAt))
                Divider().padding(.leading, 16)
                
                Link(destination: URL(string: "https://example.com/privacy")!) {
                    SettingsRow(icon: "hand.raised.fill", label: "Privacy Policy", value: "")
                }
                Divider().padding(.leading, 52)
                
                Link(destination: URL(string: "https://example.com/terms")!) {
                    SettingsRow(icon: "doc.text.fill", label: "Terms of Service", value: "")
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Sign Out Button

struct SignOutButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Sign Out")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.red)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Reusable Components

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.cardBackground)
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 28)
            
            Text(label)
                .foregroundColor(.primary)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.cardBackground)
    }
}

#Preview {
    ProfileView()
}

