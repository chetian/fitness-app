//
//  EmailSignInView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI

struct EmailSignInView: View {
    
    @ObservedObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUpMode = false
    @State private var showPassword = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case displayName, email, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "envelope.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.accentColor)
                            
                            Text(isSignUpMode ? "Create Account" : "Sign In")
                                .font(.title.bold())
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Display Name (Sign Up only)
                            if isSignUpMode {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Enter your name", text: $displayName)
                                        .textContentType(.name)
                                        .autocapitalization(.words)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(10)
                                        .focused($focusedField, equals: .displayName)
                                }
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter your email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(10)
                                    .focused($focusedField, equals: .email)
                                
                                if !email.isEmpty && !ValidationHelpers.isValidEmail(email) {
                                    Text(ValidationHelpers.emailErrorMessage())
                                        .font(.caption)
                                        .foregroundColor(.errorRed)
                                }
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    if showPassword {
                                        TextField("Enter your password", text: $password)
                                            .textContentType(isSignUpMode ? .newPassword : .password)
                                            .autocapitalization(.none)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textContentType(isSignUpMode ? .newPassword : .password)
                                            .autocapitalization(.none)
                                    }
                                    
                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(10)
                                .focused($focusedField, equals: .password)
                                
                                if !password.isEmpty && !ValidationHelpers.isValidPassword(password) {
                                    Text(ValidationHelpers.passwordErrorMessage())
                                        .font(.caption)
                                        .foregroundColor(.errorRed)
                                }
                                
                                // Password Strength (Sign Up only)
                                if isSignUpMode && !password.isEmpty {
                                    let strength = ValidationHelpers.passwordStrength(password)
                                    HStack {
                                        Text("Password Strength:")
                                            .font(.caption)
                                        Text(strength.description)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(strengthColor(for: strength))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Action Button
                        Button {
                            Task {
                                if isSignUpMode {
                                    await viewModel.handleEmailSignUp(email: email, password: password, displayName: displayName)
                                } else {
                                    await viewModel.handleEmailSignIn(email: email, password: password)
                                }
                                
                                if viewModel.isAuthenticated {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text(isSignUpMode ? "Create Account" : "Sign In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(isFormValid ? Color.accentColor : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid || viewModel.isLoading)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        
                        // Toggle Sign In/Sign Up
                        Button {
                            withAnimation {
                                isSignUpMode.toggle()
                                // Clear fields when switching modes
                                if !isSignUpMode {
                                    displayName = ""
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text(isSignUpMode ? "Sign In" : "Create Account")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accentColor)
                            }
                            .font(.callout)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Loading Overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        if isSignUpMode {
            return !displayName.isEmpty &&
                   ValidationHelpers.isValidEmail(email) &&
                   ValidationHelpers.isValidPassword(password)
        } else {
            return ValidationHelpers.isValidEmail(email) &&
                   !password.isEmpty
        }
    }
    
    private func strengthColor(for strength: ValidationHelpers.PasswordStrength) -> Color {
        switch strength {
        case .weak: return .errorRed
        case .medium: return .warningYellow
        case .strong: return .successGreen
        }
    }
}

#Preview {
    EmailSignInView(viewModel: AuthenticationViewModel())
}

