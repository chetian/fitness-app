//
//  AuthenticationView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showEmailSignIn = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // App Logo and Title
                        VStack(spacing: 16) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.accentColor)
                            
                            Text("FitnessApp")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                            
                            Text("Track your fitness journey")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                        
                        // Sign In Buttons
                        VStack(spacing: 16) {
                            // Sign in with Apple
                            SignInWithAppleButton(
                                .signIn,
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                },
                                onCompletion: { _ in
                                    Task {
                                        await viewModel.handleAppleSignIn()
                                    }
                                }
                            )
                            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                            .frame(height: 50)
                            .cornerRadius(8)
                            
                            // Sign in with Google
                            Button {
                                Task {
                                    await viewModel.handleGoogleSignIn()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .font(.title2)
                                    Text("Sign in with Google")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // Sign in with Email
                            Button {
                                showEmailSignIn = true
                            } label: {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.title2)
                                    Text("Sign in with Email")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Terms and Privacy
                        VStack(spacing: 8) {
                            Text("By continuing, you agree to our")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                                    .font(.caption)
                                Text("and")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                                    .font(.caption)
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding(.bottom, 40)
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
            .sheet(isPresented: $showEmailSignIn) {
                EmailSignInView(viewModel: viewModel)
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
}

#Preview {
    AuthenticationView()
}

