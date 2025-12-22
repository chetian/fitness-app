//
//  NotificationPreferences.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct NotificationPreferences: Codable {
    var enabled: Bool
    var dailyReminder: Bool
    var achievements: Bool
    var aiInsights: Bool
    var reminderTime: String // "HH:MM" format
    var deviceToken: String?
    
    static var defaultPreferences: NotificationPreferences {
        NotificationPreferences(
            enabled: false,
            dailyReminder: true,
            achievements: true,
            aiInsights: true,
            reminderTime: "09:00",
            deviceToken: nil
        )
    }
    
    // MARK: - Validation
    
    var isReminderTimeValid: Bool {
        let regex = "^([01][0-9]|2[0-3]):[0-5][0-9]$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: reminderTime)
    }
}

