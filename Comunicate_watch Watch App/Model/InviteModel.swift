//
//  InviteModel.swift
//  Comunicate_watch Watch App
//

import Foundation

class InviteModel: ObservableObject {
    @Published var generatedCode: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false

    private let db: DatabaseServiceProtocol
    private let auth: AuthServiceProtocol

    init(db: DatabaseServiceProtocol = FirebaseDatabaseService(),
         auth: AuthServiceProtocol = FirebaseAuthService()) {
        self.db = db
        self.auth = auth
    }

    func createInvite() {
        guard let uid = auth.currentUserUID else { return }
        let code = Self.generateCode()
        let expiresAt = Date().addingTimeInterval(600).timeIntervalSince1970

        isLoading = true
        generatedCode = ""
        errorMessage = ""

        db.write(at: "invites/\(code)", value: ["ownerUID": uid, "expiresAt": expiresAt]) { [weak self] error in
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
        guard let myUID = auth.currentUserUID else { return }
        let upperCode = code.uppercased()

        isLoading = true
        errorMessage = ""

        db.read(at: "invites/\(upperCode)") { [weak self] error, data in
            DispatchQueue.main.async {
                self?.isLoading = false

                guard
                    error == nil,
                    let data = data,
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

                self?.db.delete(at: "invites/\(upperCode)")
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
