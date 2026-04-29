//
//  AuthModel.swift
//  Comunicate_watch Watch App
//

import SwiftUI

class AuthModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""

    private let auth: AuthServiceProtocol

    init(auth: AuthServiceProtocol = FirebaseAuthService()) {
        self.auth = auth
        isLoggedIn = auth.currentUserUID != nil
    }

    func login(email: String, password: String) {
        auth.signIn(email: email, password: password) { [weak self] error in
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
        auth.createUser(email: email, password: password) { [weak self] error in
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
        try? auth.signOut()
        isLoggedIn = false
    }
}
