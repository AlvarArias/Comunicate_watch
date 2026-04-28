//
//  AuthModel.swift
//  Comunicate_watch Watch App
//

import SwiftUI
import FirebaseAuth

class AuthModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""

    init() {
        isLoggedIn = Auth.auth().currentUser != nil
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isLoggedIn = true
                    self?.errorMessage = ""
                }
            }
        }
    }

    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isLoggedIn = true
                    self?.errorMessage = ""
                }
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        isLoggedIn = false
    }
}
