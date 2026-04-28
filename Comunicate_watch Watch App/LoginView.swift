//
//  LoginView.swift
//  Comunicate_watch Watch App
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authModel: AuthModel

    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()

                SecureField("Contraseña", text: $password)
                    .textContentType(isRegistering ? .newPassword : .password)
            }

            if !authModel.errorMessage.isEmpty {
                Section {
                    Text(authModel.errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button(isRegistering ? "Crear cuenta" : "Entrar") {
                    if isRegistering {
                        authModel.register(email: email, password: password)
                    } else {
                        authModel.login(email: email, password: password)
                    }
                }
                .disabled(email.isEmpty || password.isEmpty)

                Button(isRegistering ? "Ya tengo cuenta" : "Crear cuenta") {
                    isRegistering.toggle()
                    authModel.errorMessage = ""
                }
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(isRegistering ? "Crear cuenta" : "Iniciar sesión")
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthModel())
}
