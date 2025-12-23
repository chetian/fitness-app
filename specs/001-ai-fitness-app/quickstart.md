# Quickstart Guide: AI-Driven Fitness iOS App

## Overview

This guide will help you get the AI-Driven Fitness iOS App running locally for development.

## Prerequisites

### Required Software
- **macOS** 13.0 (Ventura) or later
- **Xcode** 15.0 or later ([Download](https://developer.apple.com/xcode/))
- **iOS Simulator** or physical iOS device running iOS 16.0+
- **CocoaPods** or **Swift Package Manager** (SPM recommended)
- **Node.js** 18+ and npm (for backend API if running locally)
- **Git** for version control

### Required Accounts
- **Apple Developer Account** (for device testing, HealthKit, Sign in with Apple)
- **Firebase Account** ([console.firebase.google.com](https://console.firebase.google.com))
- **Google Cloud Account** (for Google Sign-In credentials)
- **MongoDB Atlas Account** ([mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas))

---

## Step 1: Clone Repository

```bash
git clone <repository-url>
cd fitness/FitnessApp
```

---

## Step 2: Firebase Setup

### 2.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" and follow the wizard
3. Name your project: `FitnessApp` (or your preferred name)
4. Enable Google Analytics (optional)

### 2.2 Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. Enter iOS bundle ID: `com.yourcompany.FitnessApp` (match your Xcode project)
3. Download `GoogleService-Info.plist`
4. Add `GoogleService-Info.plist` to your Xcode project root

### 2.3 Enable Authentication Providers

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google**:
   - Download OAuth client config from Google Cloud Console
   - Add `REVERSED_CLIENT_ID` to Info.plist URL schemes
4. Enable **Apple**:
   - Follow Firebase instructions to configure Apple Sign-In
   - Add Sign in with Apple capability in Xcode

### 2.4 Install Firebase SDK

Add Firebase packages via Swift Package Manager in Xcode:

```
File → Add Package Dependencies
```

Add:
- `https://github.com/firebase/firebase-ios-sdk`
  - Select: FirebaseAuth, FirebaseMessaging

---

## Step 3: Configure Xcode Project

### 3.1 Open Project

```bash
cd FitnessApp
open FitnessApp.xcodeproj
```

### 3.2 Configure Capabilities

1. Select **FitnessApp** target
2. Go to **Signing & Capabilities**
3. Add capabilities:
   - **Sign in with Apple**
   - **Push Notifications**
   - **HealthKit**
   - **Background Modes** → Background fetch, Remote notifications

### 3.3 Update Info.plist

Add required permission descriptions:

```xml
<key>NSHealthShareUsageDescription</key>
<string>FitnessApp needs access to your health data to display your fitness metrics and provide personalized insights.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>FitnessApp wants to save your workout data to the Health app.</string>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3.4 Configure URL Schemes

Add Google Sign-In URL scheme (get from `GoogleService-Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 3.5 Set Bundle Identifier

1. Select **FitnessApp** target
2. Under **General** → **Identity**
3. Set **Bundle Identifier**: `com.yourcompany.FitnessApp`

---

## Step 4: MongoDB Atlas Setup

### 4.1 Create Cluster

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free M0 cluster
3. Choose a cloud provider and region
4. Name your cluster: `FitnessApp`

### 4.2 Create Database and Collections

1. Click **Browse Collections** → **Add My Own Data**
2. Database name: `fitness_app`
3. Create collections:
   - `users`
   - `fitness_metrics`
   - `workouts`

### 4.3 Configure Network Access

1. Go to **Network Access**
2. Add IP address: `0.0.0.0/0` (allow all for development)
3. ⚠️ For production, whitelist specific IPs only

### 4.4 Create Database User

1. Go to **Database Access**
2. Add new database user
3. Username: `fitnessapp_user`
4. Password: Generate secure password
5. Permissions: Read and write to any database

### 4.5 Get Connection String

1. Click **Connect** on your cluster
2. Choose **Connect your application**
3. Copy connection string:
   ```
   mongodb+srv://fitnessapp_user:<password>@cluster0.xxxxx.mongodb.net/fitness_app
   ```

---

## Step 5: Backend API Setup (Optional - Local Development)

If running the backend API locally:

### 5.1 Clone Backend Repository

```bash
cd ../
git clone <backend-repository-url>
cd fitness-api
```

### 5.2 Install Dependencies

```bash
npm install
```

### 5.3 Configure Environment Variables

Create `.env` file:

```env
PORT=3000
MONGODB_URI=mongodb+srv://fitnessapp_user:<password>@cluster0.xxxxx.mongodb.net/fitness_app
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
NODE_ENV=development
```

### 5.4 Start Backend Server

```bash
npm run dev
```

Server should start on `http://localhost:3000`

### 5.5 Update iOS App API Base URL

In `Constants.swift`:

```swift
struct Constants {
    static let apiBaseURL = "http://localhost:3000/v1" // Development
    // static let apiBaseURL = "https://api.fitnessapp.com/v1" // Production
}
```

---

## Step 6: Build and Run iOS App

### 6.1 Select Simulator or Device

In Xcode toolbar:
- Click device selector
- Choose **iPhone 15 Pro** simulator or your physical device

### 6.2 Build the Project

```bash
# Via Xcode: Cmd + B
# Or via command line:
xcodebuild -scheme FitnessApp -sdk iphonesimulator -configuration Debug clean build
```

### 6.3 Run the App

```bash
# Via Xcode: Cmd + R
# Or click the Play button
```

---

## Step 7: Test Authentication

### 7.1 Test Email/Password Sign-In

1. Launch app → Authentication screen
2. Tap "Sign in with Email"
3. Create account with email and password
4. Complete onboarding flow

### 7.2 Test Sign in with Apple

1. On authentication screen, tap "Sign in with Apple"
2. Use your Apple ID credentials
3. ⚠️ Requires physical device or simulator signed in to Apple ID

### 7.3 Test Google Sign-In

1. Tap "Sign in with Google"
2. Follow Google OAuth flow
3. Grant permissions

---

## Step 8: Test HealthKit Integration

### 8.1 Grant HealthKit Permissions

1. Complete authentication
2. During onboarding, grant HealthKit permissions
3. Choose data types: Steps, Heart Rate, Workouts, Active Energy

### 8.2 Add Sample Health Data (Simulator)

If using simulator without real health data:

1. Open Health app on simulator
2. Tap "Browse" → "Activity"
3. Manually add sample data for testing
4. Return to FitnessApp and pull to refresh

### 8.3 Test Apple Watch Sync (Physical Device)

1. Pair Apple Watch with iPhone
2. Complete a workout on Apple Watch
3. Open FitnessApp
4. Dashboard should display synced workout data

---

## Step 9: Test Push Notifications

### 9.1 Configure APNs Certificates

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Certificates, IDs & Profiles → Keys
3. Create new APNs Auth Key
4. Download `.p8` file
5. Upload to Firebase Console → Project Settings → Cloud Messaging

### 9.2 Test Notification Delivery

1. Complete onboarding and grant notification permissions
2. Get device token (printed in Xcode console)
3. Send test notification from Firebase Console:
   - Cloud Messaging → Send test message
   - Paste device token
   - Send notification

---

## Step 10: Verify MongoDB Data

### 10.1 Check User Creation

1. Sign in to MongoDB Atlas
2. Browse Collections → `users`
3. Verify your user document was created with correct fields

### 10.2 Check Fitness Metrics

1. Sync HealthKit data in app
2. Check `fitness_metrics` collection
3. Verify metrics for today's date

---

## Common Issues & Troubleshooting

### Issue: Firebase authentication fails

**Solution:**
- Verify `GoogleService-Info.plist` is in project root
- Check bundle identifier matches Firebase console
- Ensure authentication providers are enabled in Firebase

### Issue: HealthKit permissions not requesting

**Solution:**
- Verify HealthKit capability is enabled in Xcode
- Check `Info.plist` has `NSHealthShareUsageDescription`
- Clean build folder: `Product → Clean Build Folder`

### Issue: MongoDB connection fails

**Solution:**
- Verify connection string is correct
- Check network access allows your IP
- Ensure database user credentials are correct
- Verify backend API is running

### Issue: Google Sign-In not working

**Solution:**
- Verify `REVERSED_CLIENT_ID` is in Info.plist URL schemes
- Check Google Sign-In is enabled in Firebase
- Ensure GoogleSignIn SDK is properly installed

### Issue: Build errors with Swift packages

**Solution:**
```bash
# Reset package cache
File → Packages → Reset Package Caches
# Update to latest packages
File → Packages → Update to Latest Package Versions
```

---

## Running Tests

### Unit Tests

```bash
# Via Xcode: Cmd + U
# Or command line:
xcodebuild test -scheme FitnessApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### UI Tests

```bash
xcodebuild test -scheme FitnessAppUITests -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## Development Workflow

### 1. Daily Development

```bash
git checkout 001-ai-fitness-app
git pull origin 001-ai-fitness-app
# Make changes
xcodebuild clean build
# Run and test
```

### 2. Running Backend API

```bash
cd fitness-api
npm run dev
# API runs on http://localhost:3000
```

### 3. Testing on Physical Device

1. Connect iPhone via USB
2. Select device in Xcode
3. Trust computer on iPhone if prompted
4. Run app (Cmd + R)

### 4. Debugging

- **Console logs:** View in Xcode console (Cmd + Shift + C)
- **Network requests:** Use Charles Proxy or Xcode Network Profiler
- **Memory leaks:** Instruments → Leaks template
- **Performance:** Instruments → Time Profiler

---

## Environment Configuration

### Development

```swift
// Constants.swift
#if DEBUG
static let apiBaseURL = "http://localhost:3000/v1"
static let enableLogging = true
#else
static let apiBaseURL = "https://api.fitnessapp.com/v1"
static let enableLogging = false
#endif
```

### Staging

- Use separate Firebase project for staging
- Point to staging MongoDB cluster
- Use staging API URL

### Production

- Use production Firebase project
- Production MongoDB Atlas cluster
- Enable SSL pinning for API calls

---

## Next Steps

1. ✅ Environment setup complete
2. → Start implementing authentication flow
3. → Build onboarding screens
4. → Implement dashboard with HealthKit integration
5. → Connect to MongoDB backend API
6. → Add push notifications
7. → Implement offline workout tracking

---

## Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)
- [API Specification](./contracts/api-spec.yaml)
- [Data Model](./data-model.md)
- [Implementation Plan](./plan.md)

---

**Ready to code!** 🚀

