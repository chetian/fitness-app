//
//  AuthenticationService.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import CryptoKit

enum AuthenticationError: LocalizedError, Equatable {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case unknownError(String)
    case appleSignInFailed
    case googleSignInFailed
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .userNotFound:
            return "No account found with this email. Please sign up first."
        case .emailAlreadyInUse:
            return "This email is already registered. Please sign in instead."
        case .weakPassword:
            return "Password is too weak. Please use a stronger password."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .unknownError(let message):
            return "An error occurred: \(message)"
        case .appleSignInFailed:
            return "Apple Sign-In failed. Please try again."
        case .googleSignInFailed:
            return "Google Sign-In failed. Please try again."
        case .cancelled:
            return "Sign-in was cancelled."
        }
    }
}

class AuthenticationService: NSObject {
    
    static let shared = AuthenticationService()
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    
    var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    private override init() {
        super.init()
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                // User is signed in
                print("Auth state changed: User signed in - \(user.uid)")
                
                // Get and store ID token
                user.getIDToken { token, error in
                    if let token = token {
                        _ = KeychainManager.shared.saveToken(token, forKey: Constants.KeychainKeys.firebaseToken)
                        _ = KeychainManager.shared.saveToken(user.uid, forKey: Constants.KeychainKeys.firebaseUID)
                    }
                }
                
                // Post notification
                NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationKeys.authStateChanged), object: user)
            } else {
                // User is signed out
                print("Auth state changed: User signed out")
                NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationKeys.authStateChanged), object: nil)
            }
        }
    }
    
    // MARK: - Sign In with Apple
    
    func signInWithApple() async throws -> AuthDataResult {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        return try await withCheckedThrowingContinuation { continuation in
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate(continuation: continuation, currentNonce: nonce)
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
            
            // Keep delegate alive
            objc_setAssociatedObject(authorizationController, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // MARK: - Sign In with Google
    
    func signInWithGoogle() async throws -> AuthDataResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Google Sign-In Error: Firebase clientID is nil")
            print("   Check GoogleService-Info.plist for CLIENT_ID key")
            throw AuthenticationError.googleSignInFailed
        }
        
        print("✅ Google Sign-In: Client ID found: \(clientID)")
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ Google Sign-In Error: Could not find root view controller")
            throw AuthenticationError.googleSignInFailed
        }
        
        print("✅ Google Sign-In: Starting sign-in flow...")
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = result.user
            
            print("✅ Google Sign-In: User signed in with Google: \(user.profile?.email ?? "unknown")")
            
            guard let idToken = user.idToken?.tokenString else {
                print("❌ Google Sign-In Error: Failed to get ID token")
                throw AuthenticationError.googleSignInFailed
            }
            
            print("✅ Google Sign-In: ID token obtained, signing in with Firebase...")
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                          accessToken: user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            print("✅ Google Sign-In: Successfully signed in to Firebase: \(authResult.user.uid)")
            return authResult
        } catch let error as NSError {
            print("❌ Google Sign-In Error: \(error.domain) - \(error.code)")
            print("   Description: \(error.localizedDescription)")
            print("   UserInfo: \(error.userInfo)")
            throw AuthenticationError.googleSignInFailed
        }
    }
    
    // MARK: - Email/Password Authentication
    
    func signInWithEmail(email: String, password: String) async throws -> AuthDataResult {
        print("🔐 signInWithEmail called")
        print("   Email: \(email)")
        
        do {
            print("📤 Signing in to Firebase...")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Email Sign-In successful")
            print("   UID: \(result.user.uid)")
            print("   Email: \(result.user.email ?? "unknown")")
            return result
        } catch let error as NSError {
            print("❌ Email Sign-In Error:")
            print("   Domain: \(error.domain)")
            print("   Code: \(error.code)")
            print("   Description: \(error.localizedDescription)")
            throw mapFirebaseError(error)
        }
    }
    
    func signUpWithEmail(email: String, password: String) async throws -> AuthDataResult {
        print("🔐 signUpWithEmail called")
        print("   Email: \(email)")
        
        do {
            // Ensure no one is currently signed in before creating new account
            let currentUser = Auth.auth().currentUser
            if currentUser != nil {
                print("⚠️  Current user detected:")
                print("   UID: \(currentUser?.uid ?? "unknown")")
                print("   Email: \(currentUser?.email ?? "unknown")")
                print("   Signing out first...")
                try Auth.auth().signOut()
                print("✅ Signed out successfully")
            } else {
                print("✅ No current user, proceeding with sign-up")
            }
            
            print("📤 Creating Firebase user account...")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ Email Sign-Up: Account created")
            print("   UID: \(result.user.uid)")
            print("   Email: \(result.user.email ?? "unknown")")
            return result
        } catch let error as NSError {
            print("❌ Email Sign-Up Error:")
            print("   Domain: \(error.domain)")
            print("   Code: \(error.code)")
            print("   Description: \(error.localizedDescription)")
            
            // Check for specific error codes
            if let errorCode = AuthErrorCode(_bridgedNSError: error) {
                print("   Firebase Error Code: \(errorCode.code)")
                switch errorCode.code {
                case .emailAlreadyInUse:
                    print("   → Email is already registered")
                case .invalidEmail:
                    print("   → Invalid email format")
                case .weakPassword:
                    print("   → Password is too weak")
                case .networkError:
                    print("   → Network error")
                default:
                    print("   → Other error")
                }
            }
            
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            
            // Clear Keychain
            _ = KeychainManager.shared.deleteToken(forKey: Constants.KeychainKeys.firebaseToken)
            _ = KeychainManager.shared.deleteToken(forKey: Constants.KeychainKeys.firebaseUID)
            
            // Sign out Google if needed
            GIDSignIn.sharedInstance.signOut()
            
        } catch {
            throw AuthenticationError.unknownError("Failed to sign out")
        }
    }
    
    // MARK: - Helper Methods
    
    private func mapFirebaseError(_ error: NSError) -> AuthenticationError {
        guard let errorCode = AuthErrorCode(_bridgedNSError: error) else {
            return .unknownError(error.localizedDescription)
        }
        
        switch errorCode.code {
        case .wrongPassword, .invalidEmail:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .unknownError(error.localizedDescription)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

// MARK: - Apple Sign In Delegate

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    let continuation: CheckedContinuation<AuthDataResult, Error>
    let currentNonce: String
    
    init(continuation: CheckedContinuation<AuthDataResult, Error>, currentNonce: String) {
        self.continuation = continuation
        self.currentNonce = currentNonce
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation.resume(throwing: AuthenticationError.appleSignInFailed)
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation.resume(throwing: AuthenticationError.appleSignInFailed)
            return
        }
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: currentNonce
        )
        
        Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: AuthenticationError.appleSignInFailed)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let error = error as? ASAuthorizationError, error.code == .canceled {
            continuation.resume(throwing: AuthenticationError.cancelled)
        } else {
            continuation.resume(throwing: AuthenticationError.appleSignInFailed)
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

