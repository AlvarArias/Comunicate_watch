# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Comunicate_watch** is a watchOS-only chat app targeting Apple Watch. There is no paired iPhone app target — all code runs directly on the watch. The app uses SwiftUI and is planned to integrate Firebase Firestore for real-time messaging.

- Swift 5.0 · watchOS 8.0+ deployment target
- Scheme: `Comunicate_watch Watch App`
- Bundle ID: `se.alvararias.Comunicate-watch`

## Build & Test Commands

All commands must be run from the project root (the folder containing `Comunicate_watch.xcodeproj`).

**Build (simulator):**
```bash
xcodebuild -project "Comunicate_watch.xcodeproj" \
  -scheme "Comunicate_watch Watch App" \
  -sdk watchsimulator \
  -configuration Debug \
  build
```

**Run unit tests:**
```bash
xcodebuild -project "Comunicate_watch.xcodeproj" \
  -scheme "Comunicate_watch Watch App" \
  -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  test
```

**Run a single test:**
```bash
xcodebuild -project "Comunicate_watch.xcodeproj" \
  -scheme "Comunicate_watch Watch App" \
  -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' \
  -only-testing:Comunicate_watch_Watch_AppTests/Comunicate_watch_Watch_AppTests/testExample \
  test
```

**Boot the watch simulator:**
```bash
xcrun simctl boot "Apple Watch Series 9 (45mm)"
```

## Architecture

The app has a flat structure with a single source target:

```
Comunicate_watch Watch App/
├── Comunicate_watchApp.swift   # @main entry point, FirebaseApp.configure() goes here
├── ContentView.swift           # Root view — chat UI (message list + send field)
└── Model/
    └── Firebase_conf.swift     # Placeholder for Firebase configuration helpers
```

**Data flow (current):** `ContentView` holds `@State var messages: [String]` locally. `sendMessage()` appends to that array. The real Firestore implementation is commented out inline — both the write (`db.collection("messages").addDocument`) and the real-time listener (`addSnapshotListener`) exist as comments in `ContentView.swift` and just need to be uncommented once the Firebase SDK is added.

**Firebase integration status:** The SDK is not yet installed (no `Podfile` or `Package.swift`). `import Firebase` and `FirebaseApp.configure()` are commented out in `Comunicate_watchApp.swift`. `Firebase_conf.swift` is empty and reserved for Firestore helper logic.

## Pending Work (README-WORK.md)

1. Add Firebase SDK via SPM and wire up Firestore for real-time messages
2. Haptic (taptic) effects on message receive
3. Apple Push Notifications (APNs)
4. Google Sign In
5. Facebook Sign In
