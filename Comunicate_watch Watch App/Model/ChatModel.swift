//
//  ChatModel.swift
//  Comunicate_watch Watch App
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let senderUID: String
    let sentAt: Date

    var isFromMe: Bool {
        senderUID == Auth.auth().currentUser?.uid
    }
}

class ChatModel: ObservableObject {
    @Published var messages: [ChatMessage] = []

    private let db = Database.database().reference()
    private var handle: DatabaseHandle?
    private var messagesRef: DatabaseReference?
    let chatId: String

    init(chatId: String) {
        self.chatId = chatId
        startListening()
    }

    deinit {
        if let handle, let ref = messagesRef {
            ref.removeObserver(withHandle: handle)
        }
    }

    private func startListening() {
        let ref = db.child("chats").child(chatId).child("messages")
        messagesRef = ref
        handle = ref.observe(.value) { [weak self] snapshot in
            var loaded: [ChatMessage] = []
            for child in snapshot.children {
                guard
                    let snap = child as? DataSnapshot,
                    let data = snap.value as? [String: Any],
                    let text = data["text"] as? String,
                    let senderUID = data["senderUID"] as? String,
                    let sentAt = data["sentAt"] as? TimeInterval
                else { continue }
                loaded.append(ChatMessage(
                    id: snap.key,
                    text: text,
                    senderUID: senderUID,
                    sentAt: Date(timeIntervalSince1970: sentAt)
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
        guard let uid = Auth.auth().currentUser?.uid, !text.isEmpty else { return }
        db.child("chats").child(chatId).child("messages").childByAutoId().setValue([
            "text": text,
            "senderUID": uid,
            "sentAt": Date().timeIntervalSince1970
        ])
    }
}
