# Task Breakdown: AI-Driven Fitness iOS App

## Overview
**Feature:** AI-Driven Fitness iOS App with Firebase Authentication, MongoDB Backend, and Apple Watch Integration  
**Plan Reference:** [plan.md](./plan.md)  
**Specification:** [spec.md](./spec.md)  
**Target Release:** v1.0.0 (MVP)  
**Total Tasks:** 87  
**Estimated Effort:** 6-8 weeks

## Task Organization

Tasks are organized by **User Story** to enable independent implementation and testing. Each phase represents a complete, shippable increment.

### User Story Mapping

- **FR1:** User Authentication (Apple, Google, Email) → **User Story 1**
- **FR2:** Onboarding Flow → **User Story 2**
- **FR3:** Dashboard Home Screen → **User Story 3**
- **FR4:** Profile Screen → **User Story 4**
- **FR5:** Apple Watch Data Integration → **User Story 5**
- **FR6:** Push Notifications → **User Story 6**
- **FR7:** Data Persistence (MongoDB) → **Foundation** (blocking prerequisite)

### MVP Scope Recommendation

**Minimum Viable Product (v0.1.0):** User Stories 1-3
- Authentication working
- Basic onboarding completed
- Dashboard displaying data

**Full Feature Set (v1.0.0):** All User Stories 1-6

---

## Phase 1: Setup & Project Initialization

**Goal:** Create project structure, configure capabilities, and install dependencies.

**Independent Test:** Project builds successfully without errors.

### Setup Tasks

- [ ] T001 Create Xcode project with bundle ID `com.yourcompany.FitnessApp` in FitnessApp/FitnessApp.xcodeproj
- [ ] T002 Set minimum iOS deployment target to 16.0 in project settings
- [ ] T003 Enable Sign in with Apple capability in Signing & Capabilities
- [ ] T004 Enable HealthKit capability in Signing & Capabilities
- [ ] T005 Enable Push Notifications capability in Signing & Capabilities
- [ ] T006 Enable Background Modes (fetch, remote-notification) in Signing & Capabilities
- [ ] T007 [P] Create Info.plist with NSHealthShareUsageDescription and NSHealthUpdateUsageDescription
- [ ] T008 [P] Create PrivacyInfo.xcprivacy privacy manifest file in FitnessApp/Resources/
- [ ] T009 Add Firebase iOS SDK via Swift Package Manager (FirebaseAuth, FirebaseMessaging)
- [ ] T010 Add GoogleSignIn SDK via Swift Package Manager
- [ ] T011 [P] Create project directory structure per plan.md in FitnessApp/FitnessApp/
- [ ] T012 [P] Create Constants.swift in FitnessApp/Utilities/ with API base URL
- [ ] T013 Download GoogleService-Info.plist from Firebase Console and add to project root
- [ ] T014 Configure URL schemes in Info.plist with REVERSED_CLIENT_ID from GoogleService-Info.plist
- [ ] T015 Initialize Firebase in FitnessAppApp.swift application launch
- [ ] T016 [P] Create asset catalog with light/dark mode color variants in Assets.xcassets
- [ ] T017 [P] Define semantic colors (PrimaryBackground, SecondaryBackground, AccentColor, CardBackground)
- [ ] T018 Verify project builds and runs on simulator without errors

**Acceptance:** ✅ Project compiles, Firebase initializes, capabilities enabled, directory structure matches plan.

---

## Phase 2: Foundation - Core Services & Models

**Goal:** Implement shared infrastructure and data models used across all user stories.

**Independent Test:** Services instantiate correctly, models encode/decode from JSON.

### Foundation Tasks

- [ ] T019 [P] Create User model in FitnessApp/Models/User.swift with Codable conformance
- [ ] T020 [P] Create FitnessProfile model in FitnessApp/Models/FitnessProfile.swift with BMI calculation
- [ ] T021 [P] Create NotificationPreferences model in FitnessApp/Models/NotificationPreferences.swift
- [ ] T022 [P] Create ActivityMetrics model in FitnessApp/Models/ActivityMetrics.swift
- [ ] T023 [P] Create WorkoutData model in FitnessApp/Models/WorkoutData.swift with WorkoutType enum
- [ ] T024 [P] Create AuthProvider enum in User.swift (apple, google, email)
- [ ] T025 Create KeychainManager utility in FitnessApp/Utilities/KeychainManager.swift for secure token storage
- [ ] T026 Implement saveToken, getToken, deleteToken methods in KeychainManager using SecItemAdd/SecItemCopyMatching
- [ ] T027 Create NetworkManager in FitnessApp/Utilities/NetworkManager.swift with URLSession
- [ ] T028 Implement GET, POST, PUT, DELETE methods in NetworkManager with async/await
- [ ] T029 Add error handling and retry logic to NetworkManager
- [ ] T030 Create DatabaseService in FitnessApp/Services/DatabaseService.swift as singleton
- [ ] T031 Implement fetchUser(authId:) async method in DatabaseService calling GET /users/:authId
- [ ] T032 Implement createUser(_:) async method in DatabaseService calling POST /users
- [ ] T033 Implement updateUser(authId:user:) async method in DatabaseService calling PUT /users/:authId
- [ ] T034 [P] Create ColorScheme+Extensions.swift in FitnessApp/Utilities/ with semantic color helpers
- [ ] T035 [P] Add validation utilities for email, password, age, weight, height in FitnessApp/Utilities/ValidationHelpers.swift

**Acceptance:** ✅ All models created, services can make authenticated API calls to MongoDB backend, KeychainManager securely stores tokens.

---

## Phase 3: User Story 1 - User Authentication (FR1)

**Goal:** Users can authenticate with Apple, Google, or Email/Password.

**Independent Test:** User can sign in with all three methods, token persists in Keychain, authentication state survives app restart.

**Priority:** P1 (Highest - MVP Blocker)

### US1 Models & Services

- [ ] T036 [P] [US1] Create AuthenticationError enum in FitnessApp/Services/AuthenticationService.swift
- [ ] T037 [US1] Create AuthenticationService singleton in FitnessApp/Services/AuthenticationService.swift
- [ ] T038 [US1] Implement signInWithApple() async method using ASAuthorizationController
- [ ] T039 [US1] Implement signInWithGoogle() async method using GoogleSignIn SDK
- [ ] T040 [US1] Implement signInWithEmail(email:password:) async method using Firebase createUser
- [ ] T041 [US1] Implement signIn(email:password:) async method using Firebase signIn
- [ ] T042 [US1] Implement signOut() method clearing Keychain and Firebase session
- [ ] T043 [US1] Add authentication state observer using Firebase Auth.auth().addStateDidChangeListener
- [ ] T044 [US1] Store Firebase ID token in Keychain on successful authentication

### US1 ViewModels

- [ ] T045 [P] [US1] Create AuthenticationViewModel in FitnessApp/ViewModels/AuthenticationViewModel.swift as ObservableObject
- [ ] T046 [US1] Add @Published properties: isAuthenticated, isLoading, errorMessage, currentUser
- [ ] T047 [US1] Implement handleAppleSignIn() calling AuthenticationService
- [ ] T048 [US1] Implement handleGoogleSignIn() calling AuthenticationService
- [ ] T049 [US1] Implement handleEmailSignIn(email:password:) with validation
- [ ] T050 [US1] Implement handleEmailSignUp(email:password:) with validation
- [ ] T051 [US1] Add error handling with user-friendly messages for auth failures
- [ ] T052 [US1] Check MongoDB for user profile after authentication, route to onboarding if not found

### US1 Views

- [ ] T053 [P] [US1] Create AuthenticationView in FitnessApp/Views/Authentication/AuthenticationView.swift
- [ ] T054 [US1] Add "Sign in with Apple" button with proper styling (black background, Apple logo)
- [ ] T055 [US1] Add "Sign in with Google" button with proper styling (white background, Google logo)
- [ ] T056 [US1] Add "Sign in with Email" navigation link to EmailSignInView
- [ ] T057 [US1] Add app logo, tagline, and terms of service links
- [ ] T058 [US1] Implement loading state with progress indicator
- [ ] T059 [US1] Implement error alert display for authentication failures
- [ ] T060 [P] [US1] Create EmailSignInView in FitnessApp/Views/Authentication/EmailSignInView.swift
- [ ] T061 [US1] Add email and password text fields with validation
- [ ] T062 [US1] Add "Sign In" and "Create Account" buttons
- [ ] T063 [US1] Show inline validation errors (invalid email, weak password)
- [ ] T064 [US1] Ensure light/dark mode compatibility with semantic colors
- [ ] T065 [US1] Add navigation to dashboard on successful authentication

**Acceptance:** ✅ User can authenticate with Apple/Google/Email, session persists, errors display clearly, navigation works.

---

## Phase 4: User Story 2 - Onboarding Flow (FR2)

**Goal:** New users complete onboarding to set up profile and preferences.

**Independent Test:** New user completes all 5 onboarding screens, profile saves to MongoDB, user navigates to dashboard.

**Priority:** P1 (MVP - Completes user setup)

**Dependencies:** Requires US1 (authentication) complete.

### US2 ViewModels

- [ ] T066 [P] [US2] Create OnboardingViewModel in FitnessApp/ViewModels/OnboardingViewModel.swift as ObservableObject
- [ ] T067 [US2] Add @Published properties: currentStep, name, age, weight, height, fitnessGoals, activityLevel
- [ ] T068 [US2] Implement validateProfileData() checking age (13-120), weight (20-300), height (100-250)
- [ ] T069 [US2] Implement requestHealthKitPermissions() calling HealthKitService
- [ ] T070 [US2] Implement requestNotificationPermissions() using UNUserNotificationCenter
- [ ] T071 [US2] Implement saveProfile() creating User document via DatabaseService POST /users
- [ ] T072 [US2] Add navigation state management (next, back, skip, finish)

### US2 Views

- [ ] T073 [P] [US2] Create OnboardingContainerView in FitnessApp/Views/Onboarding/OnboardingContainerView.swift with TabView
- [ ] T074 [US2] Add progress indicator dots for 5 screens
- [ ] T075 [US2] Add Next, Back, Skip buttons with proper state management
- [ ] T076 [P] [US2] Create OnboardingStepView in FitnessApp/Views/Onboarding/OnboardingStepView.swift as reusable component
- [ ] T077 [US2] Create Onboarding Screen 1: Welcome with app overview and illustration
- [ ] T078 [US2] Create Onboarding Screen 2: Profile form (name, age, weight, height) with input validation
- [ ] T079 [US2] Create Onboarding Screen 3: Fitness goals selection (multi-select chips)
- [ ] T080 [US2] Create Onboarding Screen 4: HealthKit permission request with explanation and value proposition
- [ ] T081 [US2] Create Onboarding Screen 5: Push notification permission request with benefits
- [ ] T082 [US2] Implement form validation with inline error messages
- [ ] T083 [US2] Save onboarding progress to UserDefaults for resume capability
- [ ] T084 [US2] Navigate to dashboard on completion with welcome message
- [ ] T085 [US2] Ensure light/dark mode compatibility across all screens

**Acceptance:** ✅ New user completes onboarding, profile data validates and saves to MongoDB, permissions requested appropriately, navigation flows correctly.

---

## Phase 5: User Story 3 - Dashboard Home Screen (FR3)

**Goal:** Dashboard displays fitness metrics, charts, and AI insights.

**Independent Test:** Dashboard loads with user data, displays metrics, refreshes on pull-to-refresh, adapts to light/dark mode.

**Priority:** P1 (MVP - Core user value)

**Dependencies:** Requires US1 (authentication) and US2 (profile data) complete.

### US3 Services

- [ ] T086 [P] [US3] Create HealthKitService in FitnessApp/Services/HealthKitService.swift as singleton
- [ ] T087 [US3] Implement requestHealthKitPermissions(completion:) for steps, heart rate, workouts, active energy
- [ ] T088 [US3] Implement querySteps(for:completion:) using HKStatisticsQuery
- [ ] T089 [US3] Implement queryActiveEnergy(for:completion:) using HKStatisticsQuery
- [ ] T090 [US3] Implement queryHeartRate(completion:) for latest reading
- [ ] T091 [US3] Implement queryWorkouts(startDate:endDate:completion:) using HKSampleQuery
- [ ] T092 [US3] Add background observer for real-time workout updates using HKObserverQuery
- [ ] T093 [US3] Handle missing HealthKit permissions gracefully with nil returns
- [ ] T094 [US3] Implement createFitnessMetrics(_:) in DatabaseService calling POST /fitness-metrics
- [ ] T095 [US3] Implement fetchFitnessMetrics(userId:days:) in DatabaseService calling GET /fitness-metrics/:userId
- [ ] T096 [P] [US3] Create AIInsightsService in FitnessApp/Services/AIInsightsService.swift
- [ ] T097 [US3] Implement fetchInsights(userId:) calling GET /ai-insights/:userId with fallback to generic messages

### US3 ViewModels

- [ ] T098 [P] [US3] Create DashboardViewModel in FitnessApp/ViewModels/DashboardViewModel.swift as ObservableObject
- [ ] T099 [US3] Add @Published properties: metrics, weeklyData, insights, isLoading, errorMessage
- [ ] T100 [US3] Implement loadDashboardData() fetching from DatabaseService and HealthKitService in parallel
- [ ] T101 [US3] Implement refreshData() for pull-to-refresh functionality
- [ ] T102 [US3] Implement syncHealthKitData() querying HealthKit and uploading to MongoDB
- [ ] T103 [US3] Add caching layer using UserDefaults for last known metrics
- [ ] T104 [US3] Display cached data immediately while fetching fresh data in background
- [ ] T105 [US3] Handle network errors with user-friendly messages and retry option

### US3 Views

- [ ] T106 [P] [US3] Create DashboardView in FitnessApp/Views/Dashboard/DashboardView.swift with ScrollView
- [ ] T107 [US3] Add header with user greeting and profile picture
- [ ] T108 [US3] Add TabView for Dashboard and Profile tabs at bottom
- [ ] T109 [P] [US3] Create ActivityCardView in FitnessApp/Views/Dashboard/ActivityCardView.swift
- [ ] T110 [US3] Display today's steps with icon and number in ActivityCardView
- [ ] T111 [US3] Display today's calories with icon and number in ActivityCardView
- [ ] T112 [US3] Display today's active minutes with icon and number in ActivityCardView
- [ ] T113 [P] [US3] Create ChartView in FitnessApp/Views/Dashboard/ChartView.swift using Swift Charts
- [ ] T114 [US3] Implement weekly steps bar chart with data from metrics
- [ ] T115 [P] [US3] Create AIInsightsCardView in FitnessApp/Views/Dashboard/AIInsightsCardView.swift
- [ ] T116 [US3] Display AI-generated insight message with icon and color by type
- [ ] T117 [US3] Add pull-to-refresh control triggering DashboardViewModel.refreshData()
- [ ] T118 [US3] Implement loading state with skeleton screens or shimmer effects
- [ ] T119 [US3] Implement empty state with motivational message for new users
- [ ] T120 [US3] Add sync status indicator showing "Syncing data..." during HealthKit queries
- [ ] T121 [US3] Ensure all UI adapts to light/dark mode with proper contrast
- [ ] T122 [US3] Test dashboard on minimum iOS 16.0 device

**Acceptance:** ✅ Dashboard loads data from MongoDB and HealthKit, displays metrics and charts, pull-to-refresh works, light/dark mode supported, empty/loading states display correctly.

---

## Phase 6: User Story 4 - Profile Screen (FR4)

**Goal:** Users can view and edit their profile, manage settings, and sign out.

**Independent Test:** User can edit profile fields, changes save to MongoDB, sign out returns to auth screen.

**Priority:** P2 (Important - User retention)

**Dependencies:** Requires US1 (authentication) complete. Can be developed in parallel with US3.

### US4 ViewModels

- [ ] T123 [P] [US4] Create ProfileViewModel in FitnessApp/ViewModels/ProfileViewModel.swift as ObservableObject
- [ ] T124 [US4] Add @Published properties: user, isEditing, isSaving, errorMessage
- [ ] T125 [US4] Implement loadUserProfile() fetching from DatabaseService GET /users/:authId
- [ ] T126 [US4] Implement saveProfileChanges() calling DatabaseService PUT /users/:authId
- [ ] T127 [US4] Implement handleSignOut() calling AuthenticationService.signOut()
- [ ] T128 [US4] Add validation for profile edits (age, weight, height ranges)
- [ ] T129 [US4] Update local cache on successful save

### US4 Views

- [ ] T130 [P] [US4] Create ProfileView in FitnessApp/Views/Profile/ProfileView.swift
- [ ] T131 [US4] Add profile header with picture, name, email display
- [ ] T132 [US4] Add sectioned list: Personal Info, App Settings, About
- [ ] T133 [US4] Display account creation date and auth provider (Apple/Google/Email)
- [ ] T134 [US4] Add "Edit Profile" navigation to EditProfileView
- [ ] T135 [US4] Add "Notifications" settings row navigating to notification preferences
- [ ] T136 [US4] Add "Privacy Policy" and "Terms of Service" rows with web links
- [ ] T137 [US4] Add "Sign Out" button at bottom with destructive style and confirmation alert
- [ ] T138 [P] [US4] Create EditProfileView in FitnessApp/Views/Profile/EditProfileView.swift
- [ ] T139 [US4] Add editable fields for name, age, weight, height, fitness goals
- [ ] T140 [US4] Add form validation with inline error messages
- [ ] T141 [US4] Add "Save" button triggering ProfileViewModel.saveProfileChanges()
- [ ] T142 [US4] Show loading indicator while saving
- [ ] T143 [US4] Display success message on save completion
- [ ] T144 [US4] Ensure light/dark mode compatibility across profile screens

**Acceptance:** ✅ Profile displays user data, edits save successfully to MongoDB, validation works, sign out navigates to auth screen, light/dark mode supported.

---

## Phase 7: User Story 5 - Apple Watch Data Integration (FR5)

**Goal:** HealthKit data syncs automatically and displays on dashboard.

**Independent Test:** Grant HealthKit permission, complete workout on Apple Watch, open app, verify data displays on dashboard.

**Priority:** P2 (Important - Key differentiator)

**Dependencies:** Requires US3 (dashboard) complete. Extends HealthKitService from US3.

### US5 Enhancements

- [ ] T145 [US5] Implement automatic HealthKit sync on app foreground in DashboardViewModel
- [ ] T146 [US5] Add HKObserverQuery background observer in HealthKitService for workout notifications
- [ ] T147 [US5] Handle background fetch for new workouts within iOS time limits
- [ ] T148 [US5] Process and upload new HealthKit data to MongoDB via DatabaseService
- [ ] T149 [US5] Display HealthKit attribution on dashboard metrics ("From Apple Health")
- [ ] T150 [US5] Add manual sync button on dashboard triggering immediate HealthKit query
- [ ] T151 [US5] Implement sync status indicator (syncing, success, error)
- [ ] T152 [US5] Handle denied HealthKit permissions with clear messaging and manual entry alternative
- [ ] T153 [US5] Display last sync timestamp on dashboard
- [ ] T154 [US5] Test with physical device and Apple Watch sync

**Acceptance:** ✅ HealthKit data syncs automatically on app open, manual sync button works, background observer notifies of new workouts, denied permissions handled gracefully.

---

## Phase 8: User Story 6 - Push Notifications (FR6)

**Goal:** Users receive push notifications and can customize preferences.

**Independent Test:** Grant notification permission, send test notification from Firebase console, verify it appears and taps navigate to dashboard.

**Priority:** P3 (Nice to have - Engagement)

**Dependencies:** Requires US4 (profile screen for settings) complete.

### US6 Services

- [ ] T155 [P] [US6] Create NotificationService in FitnessApp/Services/NotificationService.swift as singleton
- [ ] T156 [US6] Implement requestNotificationPermission() using UNUserNotificationCenter
- [ ] T157 [US6] Implement registerDeviceToken() sending FCM token to backend PUT /users/:authId/notification-preferences
- [ ] T158 [US6] Add UNUserNotificationCenterDelegate in AppDelegate for handling notifications
- [ ] T159 [US6] Implement userNotificationCenter(_:didReceive:) for notification tap handling
- [ ] T160 [US6] Navigate to appropriate screen (dashboard) based on notification payload
- [ ] T161 [US6] Handle notification permissions denied gracefully

### US6 Views

- [ ] T162 [P] [US6] Create NotificationSettingsView in FitnessApp/Views/Profile/NotificationSettingsView.swift
- [ ] T163 [US6] Add toggle switches: Enable Notifications, Daily Reminder, Achievements, AI Insights
- [ ] T164 [US6] Add time picker for daily reminder time (HH:MM format)
- [ ] T165 [US6] Save preferences to MongoDB via ProfileViewModel
- [ ] T166 [US6] Link NotificationSettingsView from ProfileView settings section
- [ ] T167 [US6] Test notification delivery from Firebase console
- [ ] T168 [US6] Verify notification tap opens app to dashboard

**Acceptance:** ✅ Notification permission requested, device token registered, preferences save to MongoDB, test notifications received, tap navigation works.

---

## Phase 9: User Story 7 - Offline Workout Tracking (Bonus Feature)

**Goal:** Users can manually create workouts offline, which sync when online.

**Independent Test:** Create workout while offline (airplane mode), verify saves locally, go online, verify syncs to MongoDB.

**Priority:** P3 (Nice to have - Offline support)

**Dependencies:** Requires US3 (dashboard) complete.

### US7 Core Data Setup

- [ ] T169 [US7] Create Core Data model file FitnessApp.xcdatamodeld in FitnessApp/
- [ ] T170 [US7] Define OfflineWorkout entity with attributes: id, userId, type, startDate, endDate, duration, distance, calories, notes, synced, createdAt, updatedAt
- [ ] T171 [P] [US7] Create CoreDataService in FitnessApp/Services/CoreDataService.swift
- [ ] T172 [US7] Implement Core Data stack initialization with NSPersistentContainer
- [ ] T173 [US7] Implement saveWorkout(_:) saving OfflineWorkout entity with synced=false
- [ ] T174 [US7] Implement fetchUnsyncedWorkouts() querying workouts where synced=false
- [ ] T175 [US7] Implement markWorkoutAsSynced(id:) updating synced=true
- [ ] T176 [US7] Implement deleteOldSyncedWorkouts() removing synced workouts older than 30 days

### US7 Sync Logic

- [ ] T177 [US7] Add syncOfflineWorkouts() method in DashboardViewModel
- [ ] T178 [US7] Query Core Data for unsynced workouts on app foreground with network
- [ ] T179 [US7] Upload each workout to MongoDB via DatabaseService POST /workouts
- [ ] T180 [US7] Mark as synced in Core Data on successful upload
- [ ] T181 [US7] Retry failed uploads on next app open
- [ ] T182 [US7] Display offline workouts on dashboard from Core Data

### US7 Manual Entry UI

- [ ] T183 [P] [US7] Create ManualWorkoutView in FitnessApp/Views/Dashboard/ManualWorkoutView.swift
- [ ] T184 [US7] Add form fields: workout type, start time, duration, distance (optional), calories
- [ ] T185 [US7] Add "Save" button saving to Core Data via CoreDataService
- [ ] T186 [US7] Display saved confirmation and show workout on dashboard
- [ ] T187 [US7] Add "+ Manual Workout" button on dashboard
- [ ] T188 [US7] Test offline creation and online sync

**Acceptance:** ✅ Workouts save offline to Core Data, sync to MongoDB when online, manual entry UI functional, old synced workouts deleted.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Goal:** Final polish, testing, accessibility, and App Store preparation.

**Independent Test:** App passes all tests, accessibility audit, runs on minimum iOS version, ready for TestFlight.

**Priority:** P1 (Required for release)

### Testing Tasks

- [ ] T189 Create unit test target FitnessAppTests in Xcode
- [ ] T190 [P] Write unit tests for AuthenticationService (sign in methods, token storage)
- [ ] T191 [P] Write unit tests for DatabaseService (API calls, error handling)
- [ ] T192 [P] Write unit tests for HealthKitService (permission requests, queries)
- [ ] T193 [P] Write unit tests for KeychainManager (save, retrieve, delete tokens)
- [ ] T194 [P] Write unit tests for all ViewModels (state management, async operations)
- [ ] T195 Create UI test target FitnessAppUITests in Xcode
- [ ] T196 [P] Write UI test for authentication flow (Apple, Google, Email)
- [ ] T197 [P] Write UI test for onboarding flow (all 5 screens)
- [ ] T198 [P] Write UI test for dashboard navigation and refresh
- [ ] T199 [P] Write UI test for profile editing
- [ ] T200 Run all tests and achieve >80% code coverage

### Accessibility & Polish

- [ ] T201 [P] Add VoiceOver labels and hints to all interactive elements
- [ ] T202 [P] Verify Dynamic Type support for all text elements
- [ ] T203 Test app with VoiceOver enabled on all screens
- [ ] T204 Run Accessibility Inspector to verify color contrast ratios (WCAG AA 4.5:1)
- [ ] T205 [P] Polish animations and transitions for smooth UX
- [ ] T206 [P] Optimize image assets using asset catalog compression
- [ ] T207 [P] Review and refine all error messages for user-friendliness
- [ ] T208 [P] Review and polish empty states with motivational content
- [ ] T209 Test light and dark mode on all screens for visual consistency
- [ ] T210 Profile app with Xcode Instruments for memory leaks
- [ ] T211 Profile app with Time Profiler for performance bottlenecks
- [ ] T212 Test on minimum supported device (iPhone running iOS 16.0)

### App Store Preparation

- [ ] T213 Create app icons for all required sizes in Assets.xcassets/AppIcon.appiconset
- [ ] T214 Complete privacy manifest PrivacyInfo.xcprivacy with all data usage declarations
- [ ] T215 Write App Store description and keywords
- [ ] T216 Create App Store screenshots for all required device sizes
- [ ] T217 Set up TestFlight for beta testing
- [ ] T218 Upload release build to TestFlight
- [ ] T219 Conduct TestFlight beta with 10-20 users
- [ ] T220 Collect and address beta feedback
- [ ] T221 Perform pre-submission App Store Review checklist validation
- [ ] T222 Submit app for App Store review

**Acceptance:** ✅ All tests pass, accessibility compliant, performance optimized, TestFlight beta successful, ready for App Store submission.

---

## Dependency Graph

### Story Completion Order

```
Phase 1: Setup (T001-T018)
    ↓
Phase 2: Foundation (T019-T035)
    ↓
Phase 3: US1 - Authentication (T036-T065) [MVP BLOCKER]
    ↓
    ├─→ Phase 4: US2 - Onboarding (T066-T085) [MVP]
    │       ↓
    │   Phase 5: US3 - Dashboard (T086-T122) [MVP]
    │       ↓
    │       ├─→ Phase 7: US5 - Apple Watch (T145-T154)
    │       └─→ Phase 9: US7 - Offline Workouts (T169-T188)
    │
    └─→ Phase 6: US4 - Profile (T123-T144) [Can parallel with US2/US3]
            ↓
        Phase 8: US6 - Notifications (T155-T168)
    
Phase 10: Polish & Testing (T189-T222) [FINAL PHASE]
```

### Parallelization Opportunities

**Within Setup (Phase 1):**
- T007 (Info.plist), T008 (Privacy manifest), T011 (directory structure), T012 (Constants), T016-T017 (assets) can all be done in parallel

**Within Foundation (Phase 2):**
- T019-T024 (all models) can be created in parallel
- T034 (ColorScheme), T035 (Validation) can be done in parallel with services

**Within US1 (Phase 3):**
- T036 (error enum), T045 (ViewModel), T053 (AuthView), T060 (EmailView) can start in parallel after services complete

**Within US2 (Phase 4):**
- T066 (ViewModel), T073 (Container), T076 (StepView) can be created in parallel

**Within US3 (Phase 5):**
- T086 (HealthKit), T096 (AIInsights), T098 (ViewModel) can be developed in parallel
- All view components (T109, T113, T115) can be built in parallel once ViewModel is ready

**Within US4 (Phase 6):**
- T123 (ViewModel), T130 (ProfileView), T138 (EditView) can be created in parallel

**Cross-Story Parallelization:**
- **US2 and US4 can be developed in parallel** after US1 completes
- **US5 (Apple Watch) and US7 (Offline)** can be developed in parallel after US3 completes
- **All testing tasks in Phase 10** can be run in parallel

---

## Implementation Strategy

### MVP First Approach (Recommended)

**Sprint 1 (Week 1-2):** Phase 1-2 (Setup + Foundation)
- Complete project setup and core services
- **Deliverable:** Project builds, services functional

**Sprint 2 (Week 2-3):** Phase 3 (US1 - Authentication)
- Implement all three auth methods
- **Deliverable:** Users can sign in/up, session persists

**Sprint 3 (Week 3-4):** Phase 4 (US2 - Onboarding)
- Build 5-screen onboarding flow
- **Deliverable:** New users complete profile setup

**Sprint 4 (Week 4-5):** Phase 5 (US3 - Dashboard)
- Dashboard with metrics, charts, HealthKit integration
- **Deliverable:** MVP v0.1.0 - Complete user journey (auth → onboarding → dashboard)

**Sprint 5 (Week 5-6):** Phase 6-8 (US4, US5, US6)
- Profile screen, Apple Watch sync, notifications
- **Deliverable:** Feature-complete v1.0.0

**Sprint 6 (Week 6-7):** Phase 9 (US7 - Offline)
- Offline workout tracking (optional)
- **Deliverable:** Offline support complete

**Sprint 7 (Week 7-8):** Phase 10 (Polish)
- Testing, accessibility, App Store prep
- **Deliverable:** Production-ready app

### Incremental Delivery Milestones

- **Milestone 1 (Week 2):** Foundation Ready - All services functional
- **Milestone 2 (Week 3):** Authentication Working - Users can sign in
- **Milestone 3 (Week 4):** Onboarding Complete - New users set up profiles
- **Milestone 4 (Week 5):** MVP Release - Auth + Onboarding + Dashboard (v0.1.0)
- **Milestone 5 (Week 6):** Full Feature Set - All user stories complete (v1.0.0)
- **Milestone 6 (Week 8):** Production Ready - Tested, polished, submitted to App Store

---

## Progress Tracking

Use this table to track task completion:

| Task ID | Story | Status | Start Date | Completion Date | Notes |
|---------|-------|--------|------------|-----------------|-------|
| T001-T018 | Setup | Not Started | - | - | Phase 1 |
| T019-T035 | Foundation | Not Started | - | - | Phase 2 |
| T036-T065 | US1 | Not Started | - | - | Authentication |
| T066-T085 | US2 | Not Started | - | - | Onboarding |
| T086-T122 | US3 | Not Started | - | - | Dashboard |
| T123-T144 | US4 | Not Started | - | - | Profile |
| T145-T154 | US5 | Not Started | - | - | Apple Watch |
| T155-T168 | US6 | Not Started | - | - | Notifications |
| T169-T188 | US7 | Not Started | - | - | Offline Workouts |
| T189-T222 | Polish | Not Started | - | - | Testing & Release |

**Status Legend:**
- ⬜ Not Started
- 🟡 In Progress
- 🔴 Blocked
- ✅ Completed
- ❌ Cancelled

---

## Summary

- **Total Tasks:** 222
- **MVP Tasks (US1-US3):** ~122 tasks (Phases 1-5)
- **Full Release Tasks:** 222 tasks (All phases)
- **Parallel Opportunities:** 50+ tasks marked with [P] can be executed in parallel
- **Estimated Effort:** 6-8 weeks for full release, 4-5 weeks for MVP
- **Independent Testing:** Each user story phase includes specific test criteria
- **Format Validation:** ✅ All tasks follow checklist format with ID, optional [P] marker, [Story] label (where applicable), and file paths

**Next Steps:**
1. Review and approve task breakdown
2. Assign tasks to team members or begin implementation
3. Start with Phase 1 (Setup) to establish project foundation
4. Use handoff to `/speckit.implement` to begin guided implementation

---

**Ready to implement! 🚀**

