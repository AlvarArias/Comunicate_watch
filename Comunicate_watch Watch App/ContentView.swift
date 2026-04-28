//
//  ContentView.swift
//  Comunicate_watch Watch App
//
//  Created by Alvar Arias on 2024-12-05.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthModel

    var body: some View {
        if authModel.isLoggedIn {
            ChatView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthModel())
}
