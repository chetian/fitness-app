# Implementation Plan: AI-Driven Fitness iOS App

## Overview

**Feature:** AI-Driven Fitness iOS App with Firebase Authentication, MongoDB Backend, and Apple Watch Integration
**Estimated Effort:** Large (6-8 weeks for MVP)
**Priority:** High
**Branch:** 001-ai-fitness-app

## Technical Context

### Technology Stack

**iOS Frontend:**
- Swift 5.9+
- SwiftUI for declarative UI
- Minimum iOS version: iOS 16.0 (for latest SwiftUI features)
- Xcode 15.0+

**Authentication:**
- Firebase Authentication SDK
  - Sign in with Apple (AuthenticationServices framework)
  - Google Sign-In iOS SDK
  - Email/Password authentication
- Firebase Auth tokens stored securely in iOS Keychain

**Backend & Database:**
- MongoDB Atlas (cloud-hosted)
- Backend API: RESTful API or Firebase Functions for MongoDB operations
- Firebase Auth UID as primary key for user documents

**Health Integration:**
- HealthKit framework for Apple Watch data
- Health data types: Steps, Active Energy, Heart Rate, Workouts

**Notifications:**
- Apple Push Notification Service (APNs)
- Firebase Cloud Messaging (FCM) for notification management

**Additional Dependencies:**
- Firebase Core SDK
- FirebaseAuth
- GoogleSignIn SDK
- Charts library (Swift Charts or third-party)
- Async/Await for asynchronous operations
- Combine framework for reactive data flow

### Architecture Approach

**Pattern:** MVVM (Model-View-ViewModel) with SwiftUI
- Views: SwiftUI declarative views
- ViewModels: ObservableObject classes managing state
- Models: Codable structs for data entities
- Services: Separate service layer for Firebase, MongoDB API, HealthKit

**App Structure:**
```
FitnessApp/
├── App/
│   ├── FitnessAppApp.swift (entry point)
│   └── AppDelegate.swift (Firebase configuration)
├── Views/
│   ├── Authentication/
│   │   ├── AuthenticationView.swift
│   │   ├── EmailSignInView.swift
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── OnboardingStepView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── ActivityCardView.swift
│   │   ├── ChartView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   ├── EditProfileView.swift
├── ViewModels/
│   ├── AuthenticationViewModel.swift
│   ├── OnboardingViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── ProfileViewModel.swift
├── Models/
│   ├── User.swift
│   ├── FitnessProfile.swift
│   ├── ActivityMetrics.swift
│   ├── WorkoutData.swift
├── Services/
│   ├── AuthenticationService.swift
│   ├── DatabaseService.swift (MongoDB API client)
│   ├── HealthKitService.swift
│   ├── NotificationService.swift
├── Utilities/
│   ├── KeychainManager.swift
│   ├── NetworkManager.swift
│   ├── ColorScheme+Extensions.swift
│   ├── Constants.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Info.plist
│   └── PrivacyInfo.xcprivacy
```

### Data Flow

1. **Authentication Flow:**
   - User authenticates via Firebase (Apple/Google/Email)
   - Firebase returns Auth UID and ID token
   - ID token stored in Keychain
   - Auth UID sent to MongoDB API to fetch/create user profile

2. **Data Sync Flow:**
   - HealthKit data queried on app foreground
   - Processed fitness data sent to MongoDB via API
   - MongoDB stores user profile, fitness metrics, preferences
   - Dashboard fetches aggregated data from MongoDB

3. **Offline Support:**
   - UserDefaults for lightweight caching (last known metrics)
   - Local Core Data store for offline workout tracking (new in-scope feature)
   - Sync queue for pending MongoDB writes

## Constitution Check

This plan has been validated against the project constitution (v1.0.0):

- [x] **Platform Compliance:** 
  - Adheres to iOS HIG for navigation (tab bar), authentication patterns (Sign in with Apple priority)
  - SwiftUI native controls ensure HIG compliance
  - Privacy manifest included for HealthKit, network access, tracking domains
  - Proper Info.plist entries for all permissions (HealthKit, Notifications, Sign in with Apple)
  
- [x] **Memory and Performance:**
  - Async/await prevents main thread blocking
  - HealthKit queries use background dispatch queues
  - Proper memory management with weak/unowned references in closures
  - Image assets optimized with asset catalog compression
  - Network requests use URLSession with appropriate timeouts
  
- [x] **Data Persistence and Privacy:**
  - Firebase Auth tokens stored in Keychain (SecItemAdd/SecItemCopyMatching)
  - HealthKit data accessed only with explicit user permission
  - Privacy manifest declares all data collection purposes
  - HTTPS for all MongoDB API communication
  - User data deletion API endpoint for GDPR compliance
  
- [x] **Error Handling and Stability:**
  - Try-catch blocks for all Firebase and network operations
  - Error enums with user-friendly messages
  - Graceful degradation when HealthKit unavailable
  - Network reachability monitoring
  - Offline mode with cached data display
  
- [x] **Build and Deployment Readiness:**
  - Separate Debug/Release configurations in Xcode project
  - Environment-specific API endpoints (dev/staging/prod)
  - Semantic versioning in Info.plist
  - CI/CD ready structure for automated testing
  - Unit test targets for ViewModels and Services

## Implementation Steps

### Phase 0: Project Setup & Configuration

#### Step 1: Xcode Project Configuration
- **Action:** Configure Xcode project with proper capabilities and dependencies
- **Files affected:**
  - `FitnessApp.xcodeproj/project.pbxproj`
  - `Info.plist`
  - `PrivacyInfo.xcprivacy` (new)
- **Tasks:**
  - Enable Sign in with Apple capability
  - Add HealthKit capability
  - Add Push Notifications capability
  - Set minimum iOS deployment target to 16.0
  - Configure bundle identifier
  - Add privacy manifest with required data usage descriptions
- **Validation:** Project builds without capability errors

#### Step 2: Firebase & Dependencies Setup
- **Action:** Integrate Firebase and third-party SDKs via Swift Package Manager
- **Files affected:**
  - `FitnessApp.xcodeproj/project.pbxproj` (SPM dependencies)
  - `FitnessAppApp.swift` (Firebase initialization)
  - `GoogleService-Info.plist` (new, from Firebase console)
- **Tasks:**
  - Add Firebase SDK packages (FirebaseAuth, FirebaseMessaging)
  - Add GoogleSignIn SDK package
  - Download and add GoogleService-Info.plist from Firebase console
  - Initialize Firebase in app launch
  - Configure Google Sign-In client ID
- **Validation:** Firebase initializes successfully, console shows no errors

#### Step 3: MongoDB API Backend Setup
- **Action:** Set up MongoDB Atlas and create REST API endpoints
- **Files affected:**
  - Backend repository (separate or serverless functions)
  - `Constants.swift` (API base URL configuration)
- **Tasks:**
  - Create MongoDB Atlas cluster
  - Define database schema and collections (users, fitness_data, workouts)
  - Create API endpoints:
    - POST /users (create user profile)
    - GET /users/:authId (fetch user by Firebase UID)
    - PUT /users/:authId (update user profile)
    - POST /fitness-data (save fitness metrics)
    - GET /fitness-data/:authId (fetch user fitness data)
  - Configure CORS for iOS app domain
  - Set up API authentication (verify Firebase ID tokens)
- **Validation:** API endpoints return expected responses via Postman/curl

### Phase 1: Authentication Implementation

#### Step 4: Authentication Service Layer
- **Action:** Create authentication service with Firebase integration
- **Files affected:**
  - `Services/AuthenticationService.swift` (new)
  - `Utilities/KeychainManager.swift` (new)
  - `Models/User.swift` (new)
- **Tasks:**
  - Implement AuthenticationService singleton
  - Add methods: signInWithApple(), signInWithGoogle(), signInWithEmail(), signOut()
  - Implement KeychainManager for token storage
  - Add authentication state observer
  - Handle Firebase Auth errors with user-friendly messages
- **Validation:** Unit tests for authentication methods pass

#### Step 5: Authentication UI
- **Action:** Build authentication screens with Firebase integration
- **Files affected:**
  - `Views/Authentication/AuthenticationView.swift` (new)
  - `Views/Authentication/EmailSignInView.swift` (new)
  - `ViewModels/AuthenticationViewModel.swift` (new)
- **Tasks:**
  - Create AuthenticationView with Apple, Google, Email buttons
  - Implement Sign in with Apple flow using AuthenticationServices
  - Implement Google Sign-In flow with GoogleSignIn SDK
  - Create email/password sign-in form with validation
  - Add loading states and error alerts
  - Implement light/dark mode compatible colors
- **Validation:** User can authenticate with all three methods

#### Step 6: MongoDB User Profile Integration
- **Action:** Connect authentication to MongoDB user profiles
- **Files affected:**
  - `Services/DatabaseService.swift` (new)
  - `Models/FitnessProfile.swift` (new)
  - `ViewModels/AuthenticationViewModel.swift`
- **Tasks:**
  - Create DatabaseService with MongoDB API client
  - On successful auth, fetch user from MongoDB by Firebase UID
  - If user doesn't exist, trigger onboarding flow
  - If user exists, navigate to dashboard
  - Store user profile locally for quick access
- **Validation:** New users see onboarding, returning users see dashboard

### Phase 2: Onboarding Flow

#### Step 7: Onboarding UI & Navigation
- **Action:** Build swipeable onboarding screens
- **Files affected:**
  - `Views/Onboarding/OnboardingContainerView.swift` (new)
  - `Views/Onboarding/OnboardingStepView.swift` (new)
  - `ViewModels/OnboardingViewModel.swift` (new)
- **Tasks:**
  - Create OnboardingContainerView with TabView for swiping
  - Build 5 onboarding steps: Welcome, Profile, Goals, HealthKit, Notifications
  - Add progress indicators and navigation buttons
  - Implement skip functionality for optional steps
  - Add form validation for profile inputs
- **Validation:** User can navigate through all onboarding screens

#### Step 8: Onboarding Data Collection
- **Action:** Collect and save user profile data to MongoDB
- **Files affected:**
  - `ViewModels/OnboardingViewModel.swift`
  - `Services/DatabaseService.swift`
  - `Models/FitnessProfile.swift`
- **Tasks:**
  - Create FitnessProfile model (name, age, weight, height, goals)
  - Collect profile data across onboarding steps
  - Request HealthKit permissions with clear purpose strings
  - Request push notification permissions
  - Save complete profile to MongoDB on finish
  - Handle save errors with retry mechanism
- **Validation:** User profile appears in MongoDB after onboarding completion

### Phase 3: Dashboard Implementation

#### Step 9: Dashboard Layout & UI
- **Action:** Build dashboard home screen with metrics display
- **Files affected:**
  - `Views/Dashboard/DashboardView.swift` (new)
  - `Views/Dashboard/ActivityCardView.swift` (new)
  - `Views/Dashboard/ChartView.swift` (new)
  - `ViewModels/DashboardViewModel.swift` (new)
- **Tasks:**
  - Create DashboardView with ScrollView layout
  - Build ActivityCardView for metrics (steps, calories, active minutes)
  - Create ChartView for weekly progress visualization
  - Add AI insights card placeholder
  - Implement pull-to-refresh
  - Add loading and empty states
  - Ensure light/dark mode compatibility
- **Validation:** Dashboard displays with proper layout in both themes

#### Step 10: HealthKit Integration
- **Action:** Query HealthKit data and display on dashboard
- **Files affected:**
  - `Services/HealthKitService.swift` (new)
  - `ViewModels/DashboardViewModel.swift`
  - `Models/ActivityMetrics.swift` (new)
  - `Models/WorkoutData.swift` (new)
- **Tasks:**
  - Create HealthKitService with permission request methods
  - Query HKQuantityTypeIdentifierStepCount for today
  - Query HKQuantityTypeIdentifierActiveEnergyBurned for today
  - Query HKQuantityTypeIdentifierHeartRate for latest reading
  - Query HKWorkoutTypeIdentifier for recent workouts
  - Process and format HealthKit data for display
  - Handle missing permissions gracefully
  - Implement background observer for real-time updates
- **Validation:** Dashboard shows HealthKit metrics after permission grant

#### Step 11: MongoDB Data Sync
- **Action:** Sync fitness data between app and MongoDB
- **Files affected:**
  - `Services/DatabaseService.swift`
  - `ViewModels/DashboardViewModel.swift`
- **Tasks:**
  - Implement API call to save fitness metrics to MongoDB
  - Implement API call to fetch historical data
  - Add automatic sync on app foreground
  - Implement manual sync on pull-to-refresh
  - Cache latest data locally with UserDefaults
  - Handle network failures with retry logic
  - Display last sync timestamp
- **Validation:** Fitness data syncs to MongoDB and persists across sessions

### Phase 4: Profile & Settings

#### Step 12: Profile Screen Implementation
- **Action:** Build user profile screen with edit capabilities
- **Files affected:**
  - `Views/Profile/ProfileView.swift` (new)
  - `Views/Profile/EditProfileView.swift` (new)
  - `ViewModels/ProfileViewModel.swift` (new)
- **Tasks:**
  - Create ProfileView with user info display
  - Show profile picture, name, email, auth provider
  - Add sectioned list for settings (Personal Info, App Settings, About)
  - Implement EditProfileView for updating fitness profile
  - Add sign-out button with confirmation alert
  - Implement notification preferences toggles
  - Ensure light/dark mode compatibility
- **Validation:** User can view and edit profile, changes reflect immediately

#### Step 13: Profile Data Persistence
- **Action:** Save profile updates to MongoDB
- **Files affected:**
  - `ViewModels/ProfileViewModel.swift`
  - `Services/DatabaseService.swift`
- **Tasks:**
  - Implement PUT API call for profile updates
  - Validate input data (weight, height, age ranges)
  - Show loading indicator during save
  - Display success/error messages
  - Update local cache on successful save
  - Trigger dashboard refresh if goals changed
- **Validation:** Profile changes persist in MongoDB and update dashboard

### Phase 5: Push Notifications

#### Step 14: Push Notification Setup
- **Action:** Configure APNs and FCM for push notifications
- **Files affected:**
  - `Services/NotificationService.swift` (new)
  - `FitnessAppApp.swift`
  - `AppDelegate.swift` (new, for notification delegate)
- **Tasks:**
  - Configure APNs certificates in Apple Developer portal
  - Set up FCM in Firebase console
  - Implement NotificationService for permission requests
  - Register device token with Firebase
  - Send device token to MongoDB backend for storage
  - Implement UNUserNotificationCenterDelegate for handling notifications
  - Handle notification taps to navigate to appropriate screen
- **Validation:** Device receives test notification from Firebase console

#### Step 15: Notification Preferences
- **Action:** Allow users to customize notification settings
- **Files affected:**
  - `Views/Profile/NotificationSettingsView.swift` (new)
  - `ViewModels/ProfileViewModel.swift`
  - `Services/DatabaseService.swift`
- **Tasks:**
  - Create NotificationSettingsView with toggles
  - Save notification preferences to MongoDB
  - Implement notification frequency options (daily, weekly, off)
  - Add notification type preferences (reminders, achievements, insights)
  - Sync preferences with backend notification scheduler
- **Validation:** Notification preferences save and control notification delivery

### Phase 6: Offline Workout Tracking

#### Step 16: Core Data Setup for Offline Storage
- **Action:** Implement Core Data for offline workout tracking
- **Files affected:**
  - `FitnessApp.xcdatamodeld` (new, Core Data model)
  - `Services/CoreDataService.swift` (new)
  - `Models/OfflineWorkout.swift` (new)
- **Tasks:**
  - Create Core Data model with Workout entity
  - Add attributes: id, type, duration, calories, date, synced
  - Implement CoreDataService for CRUD operations
  - Create manual workout entry UI
  - Save workouts locally when offline
  - Display offline workouts on dashboard
  - Implement sync queue for pending uploads
- **Validation:** Workouts save offline and sync when connection restored

### Phase 7: AI Insights Integration

#### Step 17: AI Insights Display
- **Action:** Integrate AI-generated fitness insights on dashboard
- **Files affected:**
  - `Services/AIInsightsService.swift` (new)
  - `ViewModels/DashboardViewModel.swift`
  - `Views/Dashboard/AIInsightsCardView.swift` (new)
- **Tasks:**
  - Create AIInsightsService (calls backend AI endpoint or uses local heuristics)
  - Fetch insights based on user data and activity trends
  - Display insights in dedicated card on dashboard
  - Implement fallback generic messages if AI unavailable
  - Cache previous insights for offline viewing
  - Add refresh mechanism for updated insights
- **Validation:** Dashboard shows relevant AI insights based on user activity

### Phase 8: Testing & Polish

#### Step 18: Comprehensive Testing
- **Action:** Implement unit tests, UI tests, and integration tests
- **Files affected:**
  - `FitnessAppTests/` (new test target)
  - `FitnessAppUITests/` (new UI test target)
- **Tasks:**
  - Unit tests for all ViewModels (authentication, onboarding, dashboard, profile)
  - Unit tests for all Services (authentication, database, HealthKit, notifications)
  - UI tests for critical flows (authentication, onboarding, dashboard navigation)
  - Integration tests for end-to-end flows
  - Test error scenarios (network failures, denied permissions)
  - Test light/dark mode on all screens
  - Memory leak detection with Instruments
- **Validation:** All tests pass with >80% code coverage

#### Step 19: Accessibility & Polish
- **Action:** Ensure accessibility compliance and UI polish
- **Files affected:** All view files
- **Tasks:**
  - Add VoiceOver labels and hints to all interactive elements
  - Ensure Dynamic Type support for all text
  - Verify color contrast ratios meet WCAG AA standards
  - Test with VoiceOver enabled
  - Polish animations and transitions
  - Optimize image assets
  - Review and refine empty states and error messages
- **Validation:** App passes accessibility audit, UI feels polished

#### Step 20: App Store Preparation
- **Action:** Prepare for App Store submission
- **Files affected:**
  - `Info.plist`
  - `PrivacyInfo.xcprivacy`
  - `Assets.xcassets/AppIcon`
  - App Store metadata (external)
- **Tasks:**
  - Create app icons for all sizes
  - Write App Store description and screenshots
  - Complete privacy manifest with all data usage
  - Test on minimum supported iOS version
  - Create release build and test on TestFlight
  - Perform pre-submission App Store Review checklist
- **Validation:** App successfully uploads to TestFlight

## Testing Strategy

### Unit Tests
- [x] AuthenticationService: Test sign-in methods, token storage, error handling
- [x] DatabaseService: Test API calls, response parsing, error handling
- [x] HealthKitService: Test permission requests, data queries, background observers
- [x] NotificationService: Test permission requests, token registration
- [x] AuthenticationViewModel: Test authentication flows, state management
- [x] DashboardViewModel: Test data fetching, HealthKit sync, refresh logic
- [x] ProfileViewModel: Test profile updates, validation, save operations
- [x] OnboardingViewModel: Test data collection, validation, save flow

### UI Tests
- [x] Authentication flow: Test Apple, Google, Email sign-in
- [x] Onboarding flow: Test all screens, navigation, skip functionality
- [x] Dashboard navigation: Test tab switching, pull-to-refresh
- [x] Profile editing: Test form input, save confirmation
- [x] Dark mode: Test all screens in both light and dark themes

### Integration Tests
- [x] End-to-end new user flow: Auth → Onboarding → Dashboard
- [x] End-to-end returning user flow: Auth → Dashboard with synced data
- [x] HealthKit sync: Grant permission → View data on dashboard
- [x] Profile update: Edit profile → Save → See updates on dashboard

### Manual Testing
- [x] Test on physical device with actual Apple Watch
- [x] Test network failure scenarios at each sync point
- [x] Test app backgrounding and foregrounding
- [x] Test push notification delivery and tap handling
- [x] Memory profiling with Xcode Instruments
- [x] Performance profiling on minimum supported device

### Beta Testing
- [x] TestFlight beta with 10-20 users
- [x] Collect feedback on onboarding clarity
- [x] Monitor crash reports and analytics
- [x] Iterate on UI/UX based on feedback

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Firebase Auth SDK breaking changes | Low | High | Pin specific SDK version, monitor Firebase release notes, test updates in dev environment first |
| MongoDB API latency affecting UX | Medium | Medium | Implement aggressive caching, show cached data immediately with refresh indicator, optimize API queries with indexes |
| HealthKit permission denial rate high | Medium | High | Clearly explain value proposition before requesting, provide manual entry alternative, show example benefits |
| Google Sign-In SDK configuration complexity | Low | Medium | Follow official documentation carefully, test early in development, have fallback to email/password |
| App Store rejection for privacy issues | Low | Critical | Complete privacy manifest thoroughly, test all permission flows, conduct pre-submission privacy audit |
| Memory leaks in HealthKit observers | Medium | High | Use weak references in closures, implement proper observer cleanup, profile with Instruments regularly |
| Dark mode contrast issues | Low | Low | Use semantic colors from asset catalog, test all screens in both modes, use accessibility inspector |
| Backend API unavailability | Low | High | Implement circuit breaker pattern, show cached data, display clear error messages with retry |
| SwiftUI performance on older devices | Medium | Medium | Test on minimum supported iOS version (16.0), optimize view hierarchies, profile with Instruments |
| Offline workout sync conflicts | Medium | Medium | Implement conflict resolution strategy (last-write-wins or timestamp-based), show sync status clearly |

## Rollback Plan

If critical issues arise post-deployment:

### Immediate Actions (within 1 hour)
1. **Monitor:** Check Firebase Analytics and Crashlytics for error spikes
2. **Assess:** Determine if issue is client-side (app) or server-side (API/Firebase)
3. **Communicate:** Post status update on social media/website if widespread issue

### Short-term Mitigation (1-24 hours)
1. **Backend issues:** Roll back MongoDB API or Firebase Functions to previous stable version
2. **Client issues:** 
   - If authentication broken: Disable affected auth provider on Firebase console temporarily
   - If crash on launch: Submit hotfix build to App Store with expedited review request
   - If HealthKit sync broken: Disable HealthKit queries via remote config flag
3. **Data issues:** Restore MongoDB from backup if data corruption detected

### Fallback Approach (1-3 days)
1. **Revert app version:** If hotfix not possible, remove current version from App Store temporarily
2. **Force update:** Implement force update mechanism for future versions to prevent usage of broken build
3. **Notify users:** Send push notification explaining issue and expected resolution time

### Long-term Recovery (3-7 days)
1. **Root cause analysis:** Conduct thorough investigation of what caused the issue
2. **Fix validation:** Implement additional tests to catch similar issues
3. **Gradual rollout:** Re-release fix to 10% → 50% → 100% of users via phased release
4. **Post-mortem:** Document incident, share learnings with team, update runbooks

### Communication Plan
- **Status page:** Update status on website (if available)
- **Push notifications:** Send in-app notification for critical issues
- **Social media:** Post updates on Twitter/Instagram
- **Email:** Send email to beta users and early adopters
- **In-app message:** Display banner in app explaining known issues and ETA for fix

## Approval Checklist

- [ ] Product Owner: Reviewed and approved feature scope and implementation approach
- [ ] Technical Lead: Validated architecture, technology choices, and constitutional compliance
- [ ] Security Review: Confirmed authentication flow, data encryption, and privacy compliance
- [ ] Constitutional Compliance: All 5 principles validated and addressed in implementation
- [ ] Dependencies Confirmed: Firebase project created, MongoDB Atlas provisioned, Apple Developer account ready

---

**Plan Status:** Ready for Task Breakdown
**Next Step:** Run `/speckit.tasks` to break down into actionable tasks
