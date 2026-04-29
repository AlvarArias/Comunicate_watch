//
//  ChatModel.swift
//  Comunicate_watch Watch App
//

import Foundation

struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let senderUID: String
    let sentAt: Date
    let myUID: String?

    var isFromMe: Bool { senderUID == myUID }
}

class ChatModel: ObservableObject {
    @Published var messages: [ChatMessage] = []

    private let db: DatabaseServiceProtocol
    private let auth: AuthServiceProtocol
    private var observerToken: DatabaseObserverToken?
    let chatId: String

    init(chatId: String,
         db: DatabaseServiceProtocol = FirebaseDatabaseService(),
         auth: AuthServiceProtocol = FirebaseAuthService()) {
        self.chatId = chatId
        self.db = db
        self.auth = auth
        startListening()
    }

    deinit {
        if let token = observerToken {
            db.stopObserving(at: "chats/\(chatId)/messages", token: token)
        }
    }

    private func startListening() {
        let myUID = auth.currentUserUID
        observerToken = db.observe(at: "chats/\(chatId)/messages") { [weak self] children in
            var loaded: [ChatMessage] = []
            for (key, data) in children {
                guard
                    let text = data["text"] as? String,
                    let senderUID = data["senderUID"] as? String,
                    let sentAt = data["sentAt"] as? TimeInterval
                else { continue }
                loaded.append(ChatMessage(
                    id: key,
                    text: text,
                    senderUID: senderUID,
                    sentAt: Date(timeIntervalSince1970: sentAt),
                    myUID: myUID
                ))
            }
            // Ordenar por fecha ya que Realtime Database no garantiza orden
            loaded.sort { $0.sentAt < $1.sentAt }
            DispatchQueue.main.async {
                self?.messages = loaded
            }
        }
    }

    func sendMessage(_ text: String) {
        guard let uid = auth.currentUserUID, !text.isEmpty else { return }
        db.writeAutoId(at: "chats/\(chatId)/messages", value: [
            "text": text,
            "senderUID": uid,
            "sentAt": Date().timeIntervalSince1970
        ])
    }
}
