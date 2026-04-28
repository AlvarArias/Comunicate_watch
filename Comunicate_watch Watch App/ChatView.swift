//
//  ChatView.swift
//  Comunicate_watch Watch App
//

import SwiftUI

struct ChatView: View {
    @StateObject private var chatModel: ChatModel
    @State private var newMessage = ""

    init(chatId: String) {
        _chatModel = StateObject(wrappedValue: ChatModel(chatId: chatId))
    }

    var body: some View {
        VStack(spacing: 0) {
            messageList
            inputBar
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(chatModel.messages) { message in
                        HStack {
                            if message.isFromMe { Spacer(minLength: 24) }
                            Text(message.text)
                                .font(.footnote)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(message.isFromMe ? Color.accentColor : Color.secondary.opacity(0.25))
                                .foregroundStyle(message.isFromMe ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            if !message.isFromMe { Spacer(minLength: 24) }
                        }
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
            }
            .onChange(of: chatModel.messages.count) { _ in
                if let last = chatModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 4) {
            TextField("Mensaje", text: $newMessage)
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title3)
            }
            .disabled(newMessage.isEmpty)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        chatModel.sendMessage(newMessage)
        newMessage = ""
    }
}

#Preview {
    ChatView(chatId: "preview_chat")
}
