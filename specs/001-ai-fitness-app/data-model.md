# Data Model

## Overview

This document defines all data entities, their relationships, and validation rules for the AI-Driven Fitness iOS App.

## Entity Relationship Diagram

```
User (MongoDB)
  │
  ├── has one → FitnessProfile (embedded in User document)
  │
  ├── has many → FitnessMetrics (separate collection, referenced by userId)
  │
  ├── has many → Workouts (separate collection, referenced by userId)
  │
  └── has one → NotificationPreferences (embedded in User document)

OfflineWorkout (Core Data - local only)
  └── syncs to → Workouts (MongoDB)
```

---

## Entities

### 1. User (MongoDB Collection: `users`)

**Purpose:** Stores user account information and profile data.

**Schema:**
```json
{
  "_id": "ObjectId",
  "firebaseUid": "string (unique, indexed)",
  "email": "string",
  "displayName": "string",
  "authProvider": "string (apple|google|email)",
  "profilePictureUrl": "string (optional)",
  "createdAt": "ISODate",
  "updatedAt": "ISODate",
  "lastLoginAt": "ISODate",
  "fitnessProfile": {
    "age": "number",
    "weight": "number (kg)",
    "height": "number (cm)",
    "weightGoal": "number (kg, optional)",
    "fitnessGoals": ["string (weight_loss|muscle_gain|endurance|general_fitness)"],
    "activityLevel": "string (sedentary|lightly_active|moderately_active|very_active|extra_active)"
  },
  "notificationPreferences": {
    "enabled": "boolean",
    "dailyReminder": "boolean",
    "achievements": "boolean",
    "aiInsights": "boolean",
    "reminderTime": "string (HH:MM format)",
    "deviceToken": "string (FCM token)"
  },
  "healthKitEnabled": "boolean",
  "onboardingCompleted": "boolean"
}
```

**Indexes:**
- `firebaseUid` (unique)
- `email` (unique, sparse)

**Validation Rules:**
- `firebaseUid`: Required, string, 1-128 characters
- `email`: Required, valid email format
- `displayName`: Optional, string, 1-100 characters
- `authProvider`: Required, enum: `apple`, `google`, `email`
- `fitnessProfile.age`: Integer, range: 13-120
- `fitnessProfile.weight`: Float, range: 20-300 kg
- `fitnessProfile.height`: Float, range: 100-250 cm
- `fitnessProfile.fitnessGoals`: Array, at least 1 item from enum
- `notificationPreferences.reminderTime`: String matching regex `^([01][0-9]|2[0-3]):[0-5][0-9]$`

**Swift Model:**
```swift
struct User: Codable, Identifiable {
    let id: String // MongoDB _id
    let firebaseUid: String
    let email: String
    let displayName: String
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
}

enum AuthProvider: String, Codable {
    case apple, google, email
}
```

---

### 2. FitnessProfile (Embedded in User)

**Purpose:** Stores user's physical attributes and fitness goals.

**Swift Model:**
```swift
struct FitnessProfile: Codable {
    var age: Int
    var weight: Double // kg
    var height: Double // cm
    var weightGoal: Double? // kg
    var fitnessGoals: [FitnessGoal]
    var activityLevel: ActivityLevel
    
    enum FitnessGoal: String, Codable {
        case weightLoss = "weight_loss"
        case muscleGain = "muscle_gain"
        case endurance = "endurance"
        case generalFitness = "general_fitness"
    }
    
    enum ActivityLevel: String, Codable {
        case sedentary
        case lightlyActive = "lightly_active"
        case moderatelyActive = "moderately_active"
        case veryActive = "very_active"
        case extraActive = "extra_active"
    }
    
    // Computed properties
    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
}
```

---

### 3. NotificationPreferences (Embedded in User)

**Purpose:** Stores user's notification settings.

**Swift Model:**
```swift
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
}
```

---

### 4. FitnessMetrics (MongoDB Collection: `fitness_metrics`)

**Purpose:** Stores daily aggregated fitness data from HealthKit and manual entries.

**Schema:**
```json
{
  "_id": "ObjectId",
  "userId": "string (references User.firebaseUid)",
  "date": "ISODate (start of day)",
  "steps": "number",
  "activeEnergy": "number (kcal)",
  "activeMinutes": "number (minutes)",
  "restingHeartRate": "number (bpm, optional)",
  "averageHeartRate": "number (bpm, optional)",
  "maxHeartRate": "number (bpm, optional)",
  "distance": "number (meters, optional)",
  "floorsClimbed": "number (optional)",
  "dataSource": "string (healthkit|manual|apple_watch)",
  "createdAt": "ISODate",
  "updatedAt": "ISODate"
}
```

**Indexes:**
- `userId` + `date` (compound unique index)
- `userId` + `createdAt` (for querying recent data)

**Validation Rules:**
- `userId`: Required, string
- `date`: Required, ISODate (must be start of day: 00:00:00)
- `steps`: Integer, range: 0-100,000
- `activeEnergy`: Integer, range: 0-10,000 kcal
- `activeMinutes`: Integer, range: 0-1440 (24 hours)
- `restingHeartRate`: Integer, range: 30-200 bpm
- `dataSource`: Required, enum: `healthkit`, `manual`, `apple_watch`

**Swift Model:**
```swift
struct FitnessMetrics: Codable, Identifiable {
    let id: String // MongoDB _id
    let userId: String
    let date: Date
    var steps: Int
    var activeEnergy: Int // kcal
    var activeMinutes: Int
    var restingHeartRate: Int?
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var distance: Double? // meters
    var floorsClimbed: Int?
    let dataSource: DataSource
    let createdAt: Date
    var updatedAt: Date
    
    enum DataSource: String, Codable {
        case healthkit, manual, appleWatch = "apple_watch"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, date, steps, activeEnergy, activeMinutes
        case restingHeartRate, averageHeartRate, maxHeartRate
        case distance, floorsClimbed, dataSource, createdAt, updatedAt
    }
    
    // Computed properties
    var distanceKilometers: Double? {
        guard let distance = distance else { return nil }
        return distance / 1000.0
    }
    
    var formattedDistance: String? {
        guard let km = distanceKilometers else { return nil }
        return String(format: "%.2f km", km)
    }
}
```

---

### 5. Workout (MongoDB Collection: `workouts`)

**Purpose:** Stores individual workout sessions from HealthKit or manual entry.

**Schema:**
```json
{
  "_id": "ObjectId",
  "userId": "string (references User.firebaseUid)",
  "workoutId": "string (UUID, unique)",
  "type": "string (running|cycling|swimming|strength|yoga|other)",
  "startDate": "ISODate",
  "endDate": "ISODate",
  "duration": "number (seconds)",
  "distance": "number (meters, optional)",
  "calories": "number (kcal)",
  "averageHeartRate": "number (bpm, optional)",
  "maxHeartRate": "number (bpm, optional)",
  "notes": "string (optional)",
  "dataSource": "string (healthkit|manual)",
  "createdAt": "ISODate",
  "updatedAt": "ISODate"
}
```

**Indexes:**
- `userId` + `startDate` (compound index)
- `workoutId` (unique)

**Validation Rules:**
- `userId`: Required, string
- `workoutId`: Required, UUID format
- `type`: Required, enum
- `startDate`: Required, must be before `endDate`
- `endDate`: Required, must be after `startDate`
- `duration`: Required, integer, range: 60-86400 seconds (1 min - 24 hours)
- `calories`: Integer, range: 0-5000 kcal
- `distance`: Float, range: 0-100,000 meters (optional)
- `dataSource`: Required, enum: `healthkit`, `manual`

**Swift Model:**
```swift
struct Workout: Codable, Identifiable {
    let id: String // MongoDB _id
    let userId: String
    let workoutId: String // UUID
    var type: WorkoutType
    let startDate: Date
    let endDate: Date
    var duration: TimeInterval // seconds
    var distance: Double? // meters
    var calories: Int
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var notes: String?
    let dataSource: DataSource
    let createdAt: Date
    var updatedAt: Date
    
    enum WorkoutType: String, Codable, CaseIterable {
        case running, cycling, swimming, strength, yoga
        case walking, hiking, elliptical, rowing
        case other
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var icon: String { // SF Symbol name
            switch self {
            case .running: return "figure.run"
            case .cycling: return "bicycle"
            case .swimming: return "figure.pool.swim"
            case .strength: return "dumbbell.fill"
            case .yoga: return "figure.mind.and.body"
            case .walking: return "figure.walk"
            case .hiking: return "figure.hiking"
            case .elliptical: return "figure.elliptical"
            case .rowing: return "figure.rowing"
            case .other: return "figure.mixed.cardio"
            }
        }
    }
    
    enum DataSource: String, Codable {
        case healthkit, manual
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, workoutId, type, startDate, endDate
        case duration, distance, calories
        case averageHeartRate, maxHeartRate, notes
        case dataSource, createdAt, updatedAt
    }
    
    // Computed properties
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var distanceKilometers: Double? {
        guard let distance = distance else { return nil }
        return distance / 1000.0
    }
}
```

---

### 6. OfflineWorkout (Core Data Entity - Local Only)

**Purpose:** Temporary storage for workouts created offline before sync to MongoDB.

**Core Data Entity Attributes:**
- `id` (UUID, primary key)
- `userId` (String, Firebase UID)
- `type` (String)
- `startDate` (Date)
- `endDate` (Date)
- `duration` (Double, seconds)
- `distance` (Double, optional, meters)
- `calories` (Int16)
- `notes` (String, optional)
- `synced` (Bool, default: false)
- `createdAt` (Date)
- `updatedAt` (Date)

**Swift Model (NSManagedObject subclass):**
```swift
@objc(OfflineWorkout)
public class OfflineWorkout: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var userId: String
    @NSManaged public var type: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var duration: Double
    @NSManaged public var distance: NSNumber? // Optional Double
    @NSManaged public var calories: Int16
    @NSManaged public var notes: String?
    @NSManaged public var synced: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    // Convert to Workout model for API upload
    func toWorkout() -> Workout {
        Workout(
            id: "", // Will be generated by MongoDB
            userId: userId,
            workoutId: id.uuidString,
            type: Workout.WorkoutType(rawValue: type) ?? .other,
            startDate: startDate,
            endDate: endDate,
            duration: duration,
            distance: distance?.doubleValue,
            calories: Int(calories),
            averageHeartRate: nil,
            maxHeartRate: nil,
            notes: notes,
            dataSource: .manual,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
```

---

### 7. AIInsight (Transient Model - Not Persisted)

**Purpose:** Represents AI-generated fitness insights displayed on dashboard.

**Swift Model:**
```swift
struct AIInsight: Codable, Identifiable {
    let id: String
    let userId: String
    let message: String
    let insightType: InsightType
    let generatedAt: Date
    var displayUntil: Date
    
    enum InsightType: String, Codable {
        case motivational
        case achievement
        case recommendation
        case trend
        
        var icon: String { // SF Symbol
            switch self {
            case .motivational: return "flame.fill"
            case .achievement: return "star.fill"
            case .recommendation: return "lightbulb.fill"
            case .trend: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var color: String { // Asset catalog color name
            switch self {
            case .motivational: return "InsightOrange"
            case .achievement: return "InsightGold"
            case .recommendation: return "InsightBlue"
            case .trend: return "InsightPurple"
            }
        }
    }
    
    // Example insights
    static var examples: [AIInsight] {
        [
            AIInsight(
                id: UUID().uuidString,
                userId: "user123",
                message: "You're 25% more active this week! Keep it up! 💪",
                insightType: .trend,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400 * 7)
            ),
            AIInsight(
                id: UUID().uuidString,
                userId: "user123",
                message: "Great job! You've hit 10,000 steps for 5 days straight! 🎉",
                insightType: .achievement,
                generatedAt: Date(),
                displayUntil: Date().addingTimeInterval(86400 * 3)
            )
        ]
    }
}
```

---

## Data Flow Diagrams

### User Authentication & Profile Creation

```
1. User authenticates with Firebase (Apple/Google/Email)
   ↓
2. Firebase returns authId (UID) and ID token
   ↓
3. iOS app calls MongoDB API: GET /users/:authId
   ↓
4a. If user exists → Fetch User document → Navigate to Dashboard
4b. If user not found → Navigate to Onboarding
   ↓
5. User completes onboarding → POST /users (create User document)
   ↓
6. Navigate to Dashboard
```

### Dashboard Data Sync

```
1. User opens Dashboard
   ↓
2. Check local cache (UserDefaults) for last known metrics
   ↓
3. Display cached data immediately
   ↓
4. Fetch fresh data from MongoDB API: GET /fitness-metrics/:userId?days=7
   ↓
5. If HealthKit enabled → Query HealthKit for today's data
   ↓
6. Merge HealthKit data with MongoDB data
   ↓
7. Update Dashboard UI with fresh data
   ↓
8. Save updated metrics to local cache
```

### Offline Workout Creation & Sync

```
1. User creates workout manually (offline)
   ↓
2. Save to Core Data (OfflineWorkout entity, synced=false)
   ↓
3. Display workout on Dashboard from Core Data
   ↓
4. App comes online (network available)
   ↓
5. Query Core Data for workouts where synced=false
   ↓
6. For each unsynced workout:
   a. POST /workouts (upload to MongoDB)
   b. On success → Update Core Data: synced=true
   c. On failure → Keep synced=false, retry later
   ↓
7. Optionally delete synced workouts older than 30 days
```

---

## Validation & Business Rules

### User Profile
- Age must be between 13-120 (App Store age rating: 13+)
- Weight must be between 20-300 kg
- Height must be between 100-250 cm
- At least one fitness goal must be selected
- Email must be valid format and unique in database

### Fitness Metrics
- Steps cannot exceed 100,000 per day (realistic maximum)
- Active energy cannot exceed 10,000 kcal per day
- Active minutes cannot exceed 1440 (24 hours)
- Heart rate must be between 30-200 bpm if provided
- Date must be valid and not in future

### Workouts
- Duration must be at least 60 seconds (1 minute minimum)
- Duration cannot exceed 86,400 seconds (24 hours maximum)
- End date must be after start date
- Calories burned must be non-negative and reasonable (<5000 per workout)
- Distance must be non-negative if provided

### Data Consistency
- MongoDB userId must match Firebase Auth UID
- All dates stored in UTC timezone
- All weights in kilograms, heights in centimeters, distances in meters
- All timestamps use ISO 8601 format in MongoDB

---

## Data Migration & Versioning

### Schema Version Tracking
```json
{
  "_id": "schema_version",
  "version": "1.0.0",
  "updatedAt": "ISODate"
}
```

### Future Schema Changes
- Add migration scripts for schema updates
- Support backward compatibility for iOS clients on older versions
- Use optional fields for new attributes to avoid breaking existing data

---

## Next Steps

1. ✅ Data model finalized
2. → Create API contracts based on this model
3. → Implement Swift models in Xcode project
4. → Create Core Data model file (.xcdatamodeld)
5. → Write data validation utilities

