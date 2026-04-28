//
//  ChatView.swift
//  Comunicate_watch Watch App
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var authModel: AuthModel
    @State private var messages: [String] = []
    @State private var newMessage = ""

    var body: some View {
        VStack {
            List(messages, id: \.self) { message in
                Text(message)
                    .font(.footnote)
            }

            HStack {
                TextField("Mensaje", text: $newMessage)
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                }
                .disabled(newMessage.isEmpty)
            }
            .padding(.horizontal)

            Button("Cerrar sesión") {
                authModel.logout()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        messages.append(newMessage)
        newMessage = ""
        // Firestore integration pendiente
    }
}

#Preview {
    ChatView()
        .environmentObject(AuthModel())
}
