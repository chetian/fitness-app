# Research & Technical Decisions

## Overview

This document consolidates research findings and technical decisions for the AI-Driven Fitness iOS App implementation.

## Technology Decisions

### 1. Firebase Authentication vs Custom Auth Backend

**Decision:** Use Firebase Authentication

**Rationale:**
- Native iOS SDK support with Sign in with Apple and Google Sign-In integration
- Handles token refresh and session management automatically
- Built-in security features (rate limiting, anomaly detection)
- Reduces development time by 2-3 weeks compared to custom auth
- Free tier supports up to 10,000 MAU (sufficient for MVP)
- Easy migration path to Firebase Functions or custom backend later

**Alternatives Considered:**
- **Auth0:** More expensive ($23/month minimum), overkill for MVP
- **Custom backend with JWT:** Requires 2-3 weeks additional development, maintenance overhead
- **AWS Cognito:** Steeper learning curve, less iOS-native integration

**Implementation Notes:**
- Use Firebase Auth UID as primary key in MongoDB
- Store Firebase ID tokens in iOS Keychain for secure session persistence
- Token refresh handled automatically by Firebase SDK

---

### 2. MongoDB Data Access Pattern

**Decision:** REST API backend layer between iOS app and MongoDB

**Rationale:**
- Direct MongoDB connection from iOS not secure (exposes connection strings)
- Backend API allows server-side validation and business logic
- Enables future web/Android clients to share same API
- Allows integration of Firebase ID token verification for authentication
- Can implement rate limiting and caching at API layer

**Alternatives Considered:**
- **MongoDB Realm SDK:** Additional SDK overhead, limited flexibility for complex queries
- **Firebase Firestore:** Vendor lock-in, less flexible querying than MongoDB
- **GraphQL API:** Overkill for MVP, REST is simpler for fitness data CRUD operations

**Implementation Approach:**
- Node.js/Express backend or Firebase Cloud Functions
- Endpoints follow RESTful conventions
- Use Firebase Admin SDK to verify ID tokens on backend
- Response format: JSON with standard error codes

**API Authentication Flow:**
1. iOS app sends Firebase ID token in Authorization header
2. Backend verifies token with Firebase Admin SDK
3. Extract Firebase UID from verified token
4. Use UID to query/update MongoDB user documents

---

### 3. iOS Minimum Version: iOS 16.0

**Decision:** Target iOS 16.0 as minimum supported version

**Rationale:**
- Swift Charts framework available (iOS 16+) for native charting
- Latest SwiftUI features (Grid, NavigationStack improvements)
- 85%+ of active iOS devices run iOS 16+ (as of Dec 2024)
- Reduces technical debt from supporting older APIs
- HealthKit improvements in iOS 16 for background data delivery

**Alternatives Considered:**
- **iOS 15:** Broader device support but missing Swift Charts, requires third-party chart library
- **iOS 17:** Too new (only 60% adoption), excludes iPhone XR and older

**Implementation Notes:**
- Set deployment target to 16.0 in Xcode project settings
- Use @available checks for iOS 17+ features if added later
- Test on physical iPhone 11 (oldest device commonly running iOS 16)

---

### 4. SwiftUI Architecture Pattern: MVVM

**Decision:** Use MVVM (Model-View-ViewModel) with SwiftUI

**Rationale:**
- Natural fit for SwiftUI's declarative paradigm
- ObservableObject ViewModels integrate seamlessly with SwiftUI views
- Clear separation of concerns: Views (UI), ViewModels (state/logic), Models (data)
- Testable: ViewModels can be unit tested independently
- Industry standard for SwiftUI apps

**Architecture Layers:**
```
Views (SwiftUI) 
    ↓ (observes published properties)
ViewModels (ObservableObject)
    ↓ (calls methods)
Services (Singleton/Protocol)
    ↓ (makes requests)
External Systems (Firebase, MongoDB API, HealthKit)
```

**Key Patterns:**
- **Services Layer:** Separate services for Authentication, Database, HealthKit, Notifications
- **Dependency Injection:** Pass services to ViewModels for testability
- **Async/Await:** Use Swift concurrency for asynchronous operations
- **Combine:** Use @Published properties and Combine for reactive updates

**Example Structure:**
```swift
// View
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    var body: some View { /* UI */ }
}

// ViewModel
class DashboardViewModel: ObservableObject {
    @Published var metrics: ActivityMetrics?
    private let databaseService: DatabaseService
    private let healthKitService: HealthKitService
    
    func loadData() async { /* fetch from services */ }
}

// Service
class DatabaseService {
    func fetchUserMetrics(authId: String) async throws -> ActivityMetrics { /* API call */ }
}
```

---

### 5. HealthKit Data Access Strategy

**Decision:** Query HealthKit on-demand with background observer for real-time updates

**Rationale:**
- On-demand queries on app foreground ensure fresh data without battery drain
- Background observers notify app of new workouts even when app is closed
- HKObserverQuery allows background delivery for time-sensitive updates
- Balances data freshness with battery efficiency

**Data Types to Query:**
- **Steps:** HKQuantityTypeIdentifierStepCount (daily sum)
- **Active Energy:** HKQuantityTypeIdentifierActiveEnergyBurned (daily sum)
- **Heart Rate:** HKQuantityTypeIdentifierHeartRate (latest reading)
- **Workouts:** HKWorkoutTypeIdentifier (last 7 days)

**Query Approach:**
```swift
// Foreground query: Fetch today's steps
let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
let startOfDay = Calendar.current.startOfDay(for: Date())
let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
let query = HKStatisticsQuery(quantityType: stepsType, 
                               quantitySamplePredicate: predicate,
                               options: .cumulativeSum) { query, result, error in
    // Process result
}

// Background observer: Get notified of new workouts
let workoutType = HKObjectType.workoutType()
let observerQuery = HKObserverQuery(sampleType: workoutType, predicate: nil) { query, completionHandler, error in
    // Trigger background fetch of new workouts
    completionHandler()
}
```

**Permission Strategy:**
- Request during onboarding with clear explanation
- Graceful degradation: Show manual entry option if denied
- Request minimal data types needed (avoid requesting unnecessary permissions)

---

### 6. Light/Dark Mode Implementation

**Decision:** Use SwiftUI semantic colors with asset catalog

**Rationale:**
- SwiftUI automatically adapts to system appearance
- Asset catalog allows defining color variants for light/dark modes
- Semantic colors (primary, secondary, background) ensure HIG compliance
- No manual theme switching code needed

**Implementation:**
```swift
// Define colors in Assets.xcassets with Any/Dark variants
Color("PrimaryBackground") // Asset catalog color
Color.primary              // System semantic color
Color.secondary            // System secondary text color

// Semantic color usage
struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Welcome").foregroundColor(.primary)
            Text("Subtitle").foregroundColor(.secondary)
        }
        .background(Color("PrimaryBackground"))
    }
}
```

**Color Palette:**
- **PrimaryBackground:** White (light) / Black (dark)
- **SecondaryBackground:** Light gray / Dark gray
- **AccentColor:** App brand color (same in both modes, with adjusted saturation)
- **CardBackground:** Off-white / Dark gray with slight transparency
- **Text:** System `.primary` and `.secondary` for automatic adaptation

**Testing:**
- Test all screens in both modes during development
- Use Xcode Environment Overrides to toggle appearance
- Verify contrast ratios meet WCAG AA (4.5:1 for text)

---

### 7. Offline Workout Tracking with Core Data

**Decision:** Use Core Data for local offline workout storage

**Rationale:**
- Native iOS framework, no external dependencies
- Efficient for storing and querying structured workout data
- Supports background saves and automatic merging
- Easy sync queue implementation with `synced` flag
- Better performance than JSON file storage for querying

**Core Data Model:**
```
Workout Entity:
- id: UUID (primary key)
- type: String (e.g., "Running", "Cycling", "Strength")
- duration: Double (seconds)
- distance: Double? (meters, optional)
- calories: Int
- startDate: Date
- endDate: Date
- notes: String?
- synced: Bool (false until uploaded to MongoDB)
- createdAt: Date
- updatedAt: Date
```

**Sync Strategy:**
1. User creates workout while offline → Save to Core Data with `synced = false`
2. On app foreground with network → Query Core Data for workouts where `synced = false`
3. Upload each workout to MongoDB API
4. On successful upload → Update `synced = true` in Core Data
5. Optional: Delete synced workouts older than 30 days to save space

**Alternatives Considered:**
- **UserDefaults:** Not suitable for complex data, limited storage
- **JSON files:** Manual serialization, poor query performance
- **Realm:** External dependency, overkill for simple workout storage

---

### 8. Push Notification Architecture

**Decision:** Use Firebase Cloud Messaging (FCM) with APNs backend

**Rationale:**
- FCM abstracts APNs complexity (token management, payload formatting)
- Cross-platform support if Android app added later
- FCM provides analytics and notification scheduling
- Integrates with Firebase Auth for user targeting

**Notification Flow:**
1. iOS app requests notification permission (UNUserNotificationCenter)
2. App receives APNs device token
3. Firebase SDK automatically registers token with FCM
4. Backend sends notification via FCM API with Firebase UID targeting
5. FCM routes to APNs which delivers to device

**Notification Types:**
- **Daily Reminder:** "Time for your workout! 💪" (scheduled locally)
- **Achievement:** "New milestone: 10,000 steps! 🎉" (triggered by backend)
- **AI Insight:** "You're 25% more active this week!" (scheduled from backend)

**Implementation:**
```swift
// Request permission
let center = UNUserNotificationCenter.current()
let granted = await center.requestAuthorization(options: [.alert, .sound, .badge])

// Handle notification tap
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) {
        // Navigate to appropriate screen based on notification type
    }
}
```

---

## Best Practices

### Error Handling

**Pattern:** Use Result type and custom error enums

```swift
enum DatabaseError: LocalizedError {
    case networkFailure
    case unauthorized
    case dataCorrupted
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .networkFailure: return "Connection failed. Check your network and try again."
        case .unauthorized: return "Session expired. Please sign in again."
        case .dataCorrupted: return "Data format error. Please contact support."
        case .serverError(let msg): return msg
        }
    }
}

// Usage
func fetchUserData() async throws -> User {
    do {
        let response = try await networkManager.get("/users/\(authId)")
        return try JSONDecoder().decode(User.self, from: response)
    } catch {
        throw DatabaseError.networkFailure
    }
}
```

---

### Memory Management

**Key Patterns:**
- Use `[weak self]` in closures that might outlive the object
- Properly invalidate HealthKit observers on view dismiss
- Cancel network tasks on view disappear
- Use `@MainActor` for ViewModel properties that update UI

```swift
class DashboardViewModel: ObservableObject {
    @Published var metrics: ActivityMetrics?
    private var observerQuery: HKObserverQuery?
    
    deinit {
        // Clean up HealthKit observer
        if let query = observerQuery {
            healthKitService.stopQuery(query)
        }
    }
}
```

---

### Security Best Practices

1. **Never store sensitive data in UserDefaults**
   - Use Keychain for Firebase tokens
   - Use Keychain for any user credentials

2. **Validate all API responses**
   - Don't trust backend data blindly
   - Validate data types and ranges before display

3. **Use HTTPS for all network requests**
   - Enforce App Transport Security (ATS)
   - Pin SSL certificates for production API

4. **Sanitize user inputs**
   - Validate email format, password strength
   - Prevent SQL injection in backend (use parameterized queries)

5. **Implement proper logout**
   - Clear Keychain tokens
   - Clear cached user data
   - Revoke Firebase session

---

## Open Questions Resolved

### Q: Should we use SwiftUI or UIKit?
**Resolved:** SwiftUI - Faster development, modern, HIG-compliant by default

### Q: How to handle AI insights generation?
**Resolved:** Backend API endpoint that analyzes user data and returns insights. Fallback to generic messages if AI unavailable.

### Q: Local vs Remote notification scheduling?
**Resolved:** Hybrid approach - Daily reminders scheduled locally, achievement notifications sent from backend

### Q: How much data to cache locally?
**Resolved:** Cache last 7 days of dashboard metrics, last sync timestamp, user profile

### Q: Minimum iOS version?
**Resolved:** iOS 16.0 for Swift Charts and latest SwiftUI features

---

## Next Steps

1. ✅ All technical decisions finalized
2. → Create detailed data model (`data-model.md`)
3. → Define API contracts (`contracts/api-spec.yaml`)
4. → Generate quickstart guide (`quickstart.md`)
5. → Update agent context with technologies

