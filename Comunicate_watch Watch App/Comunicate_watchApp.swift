//
//  Comunicate_watchApp.swift
//  Comunicate_watch Watch App
//
//  Created by Alvar Arias on 2024-12-05.
//

import SwiftUI
//import Firebase

@main
struct Comunicate_watch_Watch_AppApp: App {

    /*
    init() {
        FirebaseApp.configure()
        print("Firebase configured")
    }*/
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("ContentView appeared")
                }
        }
        
    }
                          
}

