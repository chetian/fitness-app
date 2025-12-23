# FitnessApp Development Guidelines

Auto-generated from all feature plans. Last updated: [DATE]

**Constitution Version:** 1.0.0

## Project Overview

**Platform:** iOS (SwiftUI)
**Minimum iOS Version:** [From project configuration]
**Language:** Swift
**Architecture:** [To be defined based on features]

## Constitutional Principles

All development MUST adhere to the five core principles defined in `.specify/memory/constitution.md`:

1. **Platform Compliance** - iOS HIG and App Store guidelines
2. **Memory and Performance** - Efficient resource usage
3. **Data Persistence and Privacy** - Safe data handling
4. **Error Handling and Stability** - Graceful error handling
5. **Build and Deployment Readiness** - Releasable state

## Active Technologies

- Swift 5.x
- SwiftUI
- Xcode [version]
[ADDITIONAL TECHNOLOGIES FROM PLANS]

## Project Structure

```text
FitnessApp/
├── FitnessApp/
│   ├── FitnessAppApp.swift       # App entry point
│   ├── ContentView.swift          # Main view
│   └── Assets.xcassets/           # Asset catalog
└── FitnessApp.xcodeproj/
```

[ADDITIONAL STRUCTURE FROM PLANS]

## Common Commands

```bash
# Build for simulator
xcodebuild -scheme FitnessApp -sdk iphonesimulator -configuration Debug

# Run tests
xcodebuild test -scheme FitnessApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Archive for distribution
xcodebuild archive -scheme FitnessApp -archivePath ./build/FitnessApp.xcarchive
```

## Code Style

### Swift Conventions
- Follow Swift API Design Guidelines
- Use SwiftUI declarative patterns
- Prefer value types (structs) over reference types (classes)
- Use `@State`, `@Binding`, `@ObservedObject` appropriately for state management
- Handle errors with proper `do-catch` blocks or `Result` types
- Document public APIs with Swift documentation comments (`///`)

### Memory Management
- Avoid retain cycles by using `[weak self]` or `[unowned self]` in closures
- Properly manage view lifecycle
- Respond to memory warnings

## Recent Changes

[LAST 3 FEATURES AND WHAT THEY ADDED]

## Constitutional Compliance Checklist

Before any release, verify:
- [ ] iOS HIG compliance validated
- [ ] Memory profiling completed (no leaks)
- [ ] Privacy manifest updated
- [ ] Error handling tested
- [ ] Version numbers incremented

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
