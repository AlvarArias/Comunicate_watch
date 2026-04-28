# Comunicate Watch

A watchOS-only real-time chat app for Apple Watch. Two users connect via a short invite code and chat directly — no iPhone required.

## Features

- Email/password authentication (Firebase Auth)
- Create a 6-character invite code (expires in 10 minutes)
- Join a friend's room by entering their code
- Real-time messaging via Firebase Realtime Database
- Messages auto-scroll and are color-coded by sender

## Requirements

- Xcode 14+
- watchOS 8.0+ deployment target
- Apple Watch Series 7 or later (for QWERTY keyboard in simulator)
- Firebase project with Auth and Realtime Database enabled

## Setup

1. Clone the repo
2. Open `Comunicate_watch.xcodeproj` in Xcode
3. Replace `GoogleService-Info.plist` with your own from the [Firebase Console](https://console.firebase.google.com). Make sure it includes the `DATABASE_URL` key pointing to your Realtime Database.
4. In the Firebase Console, enable **Email/Password** sign-in under Authentication.
5. Build and run on the `Comunicate_watch Watch App` scheme.

## Architecture

```
Comunicate_watch Watch App/
├── Comunicate_watchApp.swift   # Entry point — FirebaseApp.configure()
├── ContentView.swift           # Routes to LoginView or HomeView based on auth state
├── LoginView.swift             # Email/password login and registration
├── HomeView.swift              # Create or join a chat room via invite code
├── ChatView.swift              # Real-time chat UI
└── Model/
    ├── AuthModel.swift         # Firebase Auth wrapper (login, register, logout)
    ├── InviteModel.swift       # Invite code creation and resolution
    └── ChatModel.swift         # Real-time message listener
```

## How It Works

```
User A                         User B
  │                               │
  ├─ Taps "Crear sala"            │
  ├─ Gets code: e.g. "X7KP2M"    │
  │                               ├─ Taps "Unirse con código"
  │                               ├─ Enters "X7KP2M"
  │                               │
  └──────── chatId = sortedUIDs joined ──────────┘
                      │
               ChatView opens for both
```

The `chatId` is deterministic: `[uidA, uidB].sorted().joined(separator: "_")`. This means both users always resolve to the same chat room regardless of who initiated.

## Firebase Database Structure

```
invites/{code}
    ownerUID: String
    expiresAt: TimeInterval     ← deleted after successful join

chats/{uid1_uid2}/messages/{autoId}
    text: String
    senderUID: String
    sentAt: TimeInterval
```

## Tech Stack

- SwiftUI (watchOS)
- Firebase iOS SDK 12.x (via Swift Package Manager)
  - FirebaseAuth
  - FirebaseDatabase

> **Note:** FirebaseFirestore is NOT used — its gRPC binary dependencies lack watchOS support. FirebaseDatabase is used for all data storage.

## Roadmap

- [ ] End-to-end chat testing with two simultaneous users
- [ ] Haptic feedback on message receive
- [ ] Apple Push Notifications (APNs)
- [ ] Google Sign In
- [ ] Facebook Sign In

## License

MIT
