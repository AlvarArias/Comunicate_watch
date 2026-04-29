# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Comunicate_watch** is a watchOS-only chat app targeting Apple Watch. There is no paired iPhone app target — all code runs directly on the watch. The app uses SwiftUI with Firebase Auth and Firebase Realtime Database for authentication and real-time messaging.

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

**Boot the watch simulator:**
```bash
xcrun simctl boot "Apple Watch Series 9 (45mm)"
```

> **Note:** Use Apple Watch Series 7 or later simulator for QWERTY keyboard support. Earlier models only offer dictation/scribble input.

## Architecture

```
Comunicate_watch Watch App/
├── Comunicate_watchApp.swift   # @main entry point, FirebaseApp.configure()
├── ContentView.swift           # Root: routes to LoginView or HomeView based on auth state
├── LoginView.swift             # Email/password login and registration (uses Form, not ScrollView)
├── HomeView.swift              # Main screen: create invite code or join via code
├── ChatView.swift              # Real-time chat UI for an active chatId
└── Model/
    ├── AuthModel.swift         # ObservableObject — wraps FirebaseAuth (login, register, logout)
    ├── InviteModel.swift       # ObservableObject — invite code creation and joining via Realtime Database
    ├── ChatModel.swift         # ObservableObject — real-time message listener via Realtime Database
    ├── Protocols.swift         # AuthServiceProtocol, DatabaseServiceProtocol, DatabaseObserverToken
    ├── FirebaseServices.swift  # Concrete Firebase implementations of the protocols
    └── Firebase_conf.swift     # Reserved for future Firebase helpers
```

## Testing

**Run unit tests:**
```bash
xcodebuild test -project "Comunicate_watch.xcodeproj" \
  -scheme "Comunicate_watch Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm),OS=10.4' \
  ONLY_ACTIVE_ARCH=NO
```

> **Note:** The `-sdk watchsimulator` flag alone does not work for `test` — use `-destination` with `ONLY_ACTIVE_ARCH=NO` instead.

### Test architecture

All models use dependency injection via `AuthServiceProtocol` and `DatabaseServiceProtocol`. Production code passes `FirebaseAuthService()` / `FirebaseDatabaseService()` by default. Tests inject `MockAuthService` / `MockDatabaseService` from `Comunicate_watch Watch AppTests/MockServices.swift` — no Firebase connection required.

**Test coverage (14 cases in `Comunicate_watch_Watch_AppTests`):**

| Model                      | Cases                                             |
| -------------------------- | ------------------------------------------------- |
| `InviteModel.createInvite` | success, no user, database error                  |
| `InviteModel.joinInvite`   | success, expired code, own code, code uppercased  |
| `ChatModel.sendMessage`    | empty text, no user, correct path written         |
| `AuthModel`                | login success, login failure, logout              |
| General                    | chatId is deterministic                           |

## Navigation Flow

```
ContentView
├── isLoggedIn == false → LoginView
└── isLoggedIn == true  → HomeView
                              ├── Crear sala → generates 6-char invite code (expires 10 min)
                              ├── Unirse con código → resolves chatId → ChatView(chatId)
                              └── Cerrar sesión → back to LoginView
```

## Firebase Integration

**SDK:** Firebase iOS SDK 12.12.1 via SPM (`firebase-ios-sdk`)
**Products in use:** `FirebaseAuth`, `FirebaseDatabase`

> **Important:** `FirebaseFirestore` is NOT used — it lacks watchOS support due to gRPC binary dependencies. Use `FirebaseDatabase` for all data storage.

**Realtime Database structure:**

```
invites/{code}
    ownerUID: String
    expiresAt: TimeInterval   ← Unix timestamp, deleted after successful join

chats/{uid1_uid2}/messages/{autoId}
    text: String
    senderUID: String
    sentAt: TimeInterval      ← Unix timestamp
```

**chatId convention:** `[uidA, uidB].sorted().joined(separator: "_")` — always deterministic regardless of who initiates.

**GoogleService-Info.plist** must include `DATABASE_URL` key pointing to the Realtime Database URL (format: `https://comunicate-watch-default-rtdb.europe-west1.firebasedatabase.app`).

## Known Watchos Constraints

- `TextField` inside `ScrollView` does not open the text input on watchOS — always use `Form` for views with text input fields.
- `NavigationStack` requires watchOS 9.0+; use conditional view switching for watchOS 8 compatibility.
- `.foregroundStyle(.accent)` is unavailable on watchOS 8; use `.foregroundColor(.accentColor)`.

## Pending Work

1. Real-time chat messages (ChatView already has ChatModel wired — needs end-to-end testing with two users)
2. Haptic (taptic) effects on message receive
3. Apple Push Notifications (APNs)
4. Google Sign In
5. Facebook Sign In
