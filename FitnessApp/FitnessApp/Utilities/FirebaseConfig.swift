//
//  FirebaseConfig.swift
//  FitnessApp
//
//  Firebase configuration from environment variables
//

import Foundation
import FirebaseCore

struct FirebaseConfig {
    
    // MARK: - Configuration Values
    // These should be loaded from Firebase.env file or Info.plist
    
    private static let config: [String: String] = {
        // Try to load from Info.plist first (for values we can safely include)
        guard let plistPath = Bundle.main.path(forResource: "FirebaseConfig", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath) as? [String: String] else {
            print("⚠️ FirebaseConfig.plist not found. Using placeholder values.")
            return [:]
        }
        return plistDict
    }()
    
    static var apiKey: String {
        config["FIREBASE_API_KEY"] ?? ""
    }
    
    static var projectID: String {
        config["FIREBASE_PROJECT_ID"] ?? ""
    }
    
    static var reversedClientID: String {
        config["FIREBASE_REVERSED_CLIENT_ID"] ?? ""
    }
    
    static var clientID: String {
        config["FIREBASE_CLIENT_ID"] ?? ""
    }
    
    static var bundleID: String {
        config["FIREBASE_BUNDLE_ID"] ?? ""
    }
    
    static var databaseURL: String {
        config["FIREBASE_DATABASE_URL"] ?? ""
    }
    
    static var storageBucket: String {
        config["FIREBASE_STORAGE_BUCKET"] ?? ""
    }
    
    static var gcmSenderID: String {
        config["FIREBASE_GCM_SENDER_ID"] ?? ""
    }
    
    // MARK: - Firebase Options
    
    static func createFirebaseOptions() -> FirebaseOptions {
        let options = FirebaseOptions(googleAppID: "1:\(gcmSenderID):ios:\(bundleID.replacingOccurrences(of: ".", with: ""))", 
                                      gcmSenderID: gcmSenderID)
        options.apiKey = apiKey
        options.projectID = projectID
        options.clientID = clientID
        options.databaseURL = databaseURL
        options.storageBucket = storageBucket
        options.bundleID = bundleID
        
        return options
    }
}

