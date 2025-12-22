//
//  FitnessAppApp.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct FitnessAppApp: App {
    
    // Register app delegate for Firebase and notification handling
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google Sign-In
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

