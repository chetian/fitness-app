//
//  ValidationHelpers.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation

struct ValidationHelpers {
    
    // MARK: - Email Validation
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Password Validation
    
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= Constants.ValidationRanges.passwordMinLength &&
               password.rangeOfCharacter(from: .letters) != nil &&
               password.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    static func passwordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil { score += 1 }
        
        switch score {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
    
    enum PasswordStrength {
        case weak, medium, strong
        
        var description: String {
            switch self {
            case .weak: return "Weak"
            case .medium: return "Medium"
            case .strong: return "Strong"
            }
        }
        
        var color: String {
            switch self {
            case .weak: return "errorRed"
            case .medium: return "warningYellow"
            case .strong: return "successGreen"
            }
        }
    }
    
    // MARK: - Fitness Profile Validation
    
    static func isValidAge(_ age: Int) -> Bool {
        return age >= Constants.ValidationRanges.ageMin &&
               age <= Constants.ValidationRanges.ageMax
    }
    
    static func isValidWeight(_ weight: Double) -> Bool {
        return weight >= Constants.ValidationRanges.weightMin &&
               weight <= Constants.ValidationRanges.weightMax
    }
    
    static func isValidHeight(_ height: Double) -> Bool {
        return height >= Constants.ValidationRanges.heightMin &&
               height <= Constants.ValidationRanges.heightMax
    }
    
    // MARK: - Error Messages
    
    static func emailErrorMessage() -> String {
        return "Please enter a valid email address"
    }
    
    static func passwordErrorMessage() -> String {
        return "Password must be at least \(Constants.ValidationRanges.passwordMinLength) characters and include letters and numbers"
    }
    
    static func ageErrorMessage() -> String {
        return "Age must be between \(Constants.ValidationRanges.ageMin) and \(Constants.ValidationRanges.ageMax)"
    }
    
    static func weightErrorMessage() -> String {
        return "Weight must be between \(Int(Constants.ValidationRanges.weightMin)) and \(Int(Constants.ValidationRanges.weightMax)) kg"
    }
    
    static func heightErrorMessage() -> String {
        return "Height must be between \(Int(Constants.ValidationRanges.heightMin)) and \(Int(Constants.ValidationRanges.heightMax)) cm"
    }
}

