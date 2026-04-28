//
//  Comunicate_watchApp.swift
//  Comunicate_watch Watch App
//
//  Created by Alvar Arias on 2024-12-05.
//

import SwiftUI
import Firebase

@main
struct Comunicate_watch_Watch_AppApp: App {

    @StateObject private var authModel = AuthModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authModel)
        }
    }
}
