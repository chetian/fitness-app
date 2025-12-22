//
//  User.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String // MongoDB _id
    let firebaseUid: String
    let email: String
    var displayName: String
    let authProvider: AuthProvider
    var profilePictureUrl: String?
    let createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date
    var fitnessProfile: FitnessProfile
    var notificationPreferences: NotificationPreferences
    var healthKitEnabled: Bool
    var onboardingCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firebaseUid, email, displayName, authProvider
        case profilePictureUrl, createdAt, updatedAt, lastLoginAt
        case fitnessProfile, notificationPreferences
        case healthKitEnabled, onboardingCompleted
    }
    
    // Memberwise initializer (needed because we have custom init(from:))
    init(
        id: String,
        firebaseUid: String,
        email: String,
        displayName: String,
        authProvider: AuthProvider,
        profilePictureUrl: String? = nil,
        createdAt: Date,
        updatedAt: Date,
        lastLoginAt: Date,
        fitnessProfile: FitnessProfile,
        notificationPreferences: NotificationPreferences,
        healthKitEnabled: Bool,
        onboardingCompleted: Bool
    ) {
        self.id = id
        self.firebaseUid = firebaseUid
        self.email = email
        self.displayName = displayName
        self.authProvider = authProvider
        self.profilePictureUrl = profilePictureUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
        self.fitnessProfile = fitnessProfile
        self.notificationPreferences = notificationPreferences
        self.healthKitEnabled = healthKitEnabled
        self.onboardingCompleted = onboardingCompleted
    }
    
    // Custom decoder to handle both ISO8601 strings and Unix timestamps
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        firebaseUid = try container.decode(String.self, forKey: .firebaseUid)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decode(String.self, forKey: .displayName)
        authProvider = try container.decode(AuthProvider.self, forKey: .authProvider)
        profilePictureUrl = try container.decodeIfPresent(String.self, forKey: .profilePictureUrl)
        fitnessProfile = try container.decode(FitnessProfile.self, forKey: .fitnessProfile)
        notificationPreferences = try container.decode(NotificationPreferences.self, forKey: .notificationPreferences)
        healthKitEnabled = try container.decode(Bool.self, forKey: .healthKitEnabled)
        onboardingCompleted = try container.decode(Bool.self, forKey: .onboardingCompleted)
        
        // Decode dates - handle both ISO8601 strings and Unix timestamps
        createdAt = try Self.decodeDate(from: container, forKey: .createdAt)
        updatedAt = try Self.decodeDate(from: container, forKey: .updatedAt)
        lastLoginAt = try Self.decodeDate(from: container, forKey: .lastLoginAt)
    }
    
    // Custom encoder to always use ISO8601 strings
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Only encode id if it's not empty (new users don't have MongoDB _id yet)
        if !id.isEmpty {
            try container.encode(id, forKey: .id)
        }
        
        try container.encode(firebaseUid, forKey: .firebaseUid)
        try container.encode(email, forKey: .email)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(authProvider, forKey: .authProvider)
        try container.encodeIfPresent(profilePictureUrl, forKey: .profilePictureUrl)
        try container.encode(fitnessProfile, forKey: .fitnessProfile)
        try container.encode(notificationPreferences, forKey: .notificationPreferences)
        try container.encode(healthKitEnabled, forKey: .healthKitEnabled)
        try container.encode(onboardingCompleted, forKey: .onboardingCompleted)
        
        // Encode dates as ISO8601 strings
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        try container.encode(formatter.string(from: lastLoginAt), forKey: .lastLoginAt)
    }
    
    // Helper to decode dates that might be ISO8601 strings or Unix timestamps
    private static func decodeDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date {
        // Try ISO8601 string first (with multiple formatters for different formats)
        if let dateString = try? container.decode(String.self, forKey: key) {
            // Try with fractional seconds
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Try JSONDecoder's default date formatter
            let jsonFormatter = DateFormatter()
            jsonFormatter.locale = Locale(identifier: "en_US_POSIX")
            jsonFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            if let date = jsonFormatter.date(from: dateString) {
                return date
            }
            
            // Try without milliseconds
            jsonFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            if let date = jsonFormatter.date(from: dateString) {
                return date
            }
        }
        
        // Try Unix timestamp (Double)
        if let timestamp = try? container.decode(Double.self, forKey: key) {
            return Date(timeIntervalSince1970: timestamp)
        }
        
        // Try Unix timestamp (TimeInterval from reference date - Swift's Date encoding)
        if let timeInterval = try? container.decode(TimeInterval.self, forKey: key) {
            return Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Could not decode date from any known format")
    }
}

enum AuthProvider: String, Codable {
    case apple
    case google
    case email
    
    var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .email: return "Email"
        }
    }
}

