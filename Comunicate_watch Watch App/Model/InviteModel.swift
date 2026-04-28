//
//  InviteModel.swift
//  Comunicate_watch Watch App
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class InviteModel: ObservableObject {
    @Published var generatedCode: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    private let db = Database.database().reference()

    func createInvite() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let code = Self.generateCode()
        let expiresAt = Date().addingTimeInterval(600).timeIntervalSince1970

        isLoading = true
        generatedCode = ""
        errorMessage = ""

        db.child("invites").child(code).setValue([
            "ownerUID": uid,
            "expiresAt": expiresAt
        ]) { [weak self] error, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.generatedCode = code
                }
            }
        }
    }

    func joinInvite(code: String, completion: @escaping (String?) -> Void) {
        guard let myUID = Auth.auth().currentUser?.uid else { return }
        let upperCode = code.uppercased()

        isLoading = true
        errorMessage = ""

        db.child("invites").child(upperCode).getData { [weak self] error, snapshot in
            DispatchQueue.main.async {
                self?.isLoading = false

                guard
                    error == nil,
                    let data = snapshot?.value as? [String: Any],
                    let ownerUID = data["ownerUID"] as? String,
                    let expiresAt = data["expiresAt"] as? TimeInterval,
                    Date(timeIntervalSince1970: expiresAt) > Date()
                else {
                    self?.errorMessage = "Código inválido o expirado"
                    completion(nil)
                    return
                }

                guard ownerUID != myUID else {
                    self?.errorMessage = "No puedes unirte a tu propio código"
                    completion(nil)
                    return
                }

                self?.db.child("invites").child(upperCode).removeValue()
                let chatId = [myUID, ownerUID].sorted().joined(separator: "_")
                completion(chatId)
            }
        }
    }

    private static func generateCode() -> String {
        // Sin caracteres ambiguos (0, O, 1, I)
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
