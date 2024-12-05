//
//  Firebase_conf.swift
//  Comunicate_watch Watch App
//
//  Created by Alvar Arias on 2024-12-05.
//

´
import Firebase

@main
struct Comunicate_watch_Watch_AppApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}