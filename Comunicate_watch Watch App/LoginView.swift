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
        ScrollView {
            VStack(spacing: 8) {
                Text(isRegistering ? "Crear cuenta" : "Iniciar sesión")
                    .font(.headline)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)

                SecureField("Contraseña", text: $password)
                    .textContentType(isRegistering ? .newPassword : .password)

                if !authModel.errorMessage.isEmpty {
                    Text(authModel.errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button(isRegistering ? "Crear cuenta" : "Entrar") {
                    if isRegistering {
                        authModel.register(email: email, password: password)
                    } else {
                        authModel.login(email: email, password: password)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty)

                Button(isRegistering ? "Ya tengo cuenta" : "Crear cuenta") {
                    isRegistering.toggle()
                    authModel.errorMessage = ""
                }
                .font(.footnote)
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthModel())
}
