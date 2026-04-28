//
//  HomeView.swift
//  Comunicate_watch Watch App
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authModel: AuthModel
    @StateObject private var inviteModel = InviteModel()

    @State private var joinCode = ""
    @State private var showJoinField = false
    @State private var activeChatId: String?
    @State private var showError = false

    var body: some View {
        if let chatId = activeChatId {
            ChatView(chatId: chatId)
        } else {
            mainContent
                .onChange(of: inviteModel.errorMessage) { msg in
                    if !msg.isEmpty { showError = true }
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK") { inviteModel.errorMessage = "" }
                } message: {
                    Text(inviteModel.errorMessage)
                }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                createSection
                Divider()
                joinSection

                Divider()

                Button("Cerrar sesión") {
                    authModel.logout()
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    private var createSection: some View {
        VStack(spacing: 6) {
            if inviteModel.generatedCode.isEmpty {
                Button(action: { inviteModel.createInvite() }) {
                    if inviteModel.isLoading {
                        ProgressView()
                    } else {
                        Label("Crear sala", systemImage: "plus.circle")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(inviteModel.isLoading)
            } else {
                VStack(spacing: 4) {
                    Text("Tu código")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(inviteModel.generatedCode)
                        .font(.title2.bold())
                        .foregroundColor(.accentColor)
                    Text("Expira en 10 min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Button("Nuevo código") {
                        inviteModel.createInvite()
                    }
                    .font(.footnote)
                }
            }
        }
    }

    private var joinSection: some View {
        VStack(spacing: 8) {
            if showJoinField {
                TextField("Código (6 letras)", text: $joinCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                Button("Unirse") {
                    inviteModel.joinInvite(code: joinCode) { chatId in
                        if let id = chatId {
                            activeChatId = id
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(joinCode.count < 6 || inviteModel.isLoading)
            } else {
                Button(action: { showJoinField = true }) {
                    Label("Unirse con código", systemImage: "person.badge.plus")
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthModel())
}
