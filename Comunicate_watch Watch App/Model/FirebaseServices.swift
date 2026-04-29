//
//  FirebaseServices.swift
//  Comunicate_watch Watch App
//

import FirebaseAuth
import FirebaseDatabase

class FirebaseAuthService: AuthServiceProtocol {
    var currentUserUID: String? {
        Auth.auth().currentUser?.uid
    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in completion(error) }
    }

    func createUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in completion(error) }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}

class FirebaseDatabaseService: DatabaseServiceProtocol {
    private let db = Database.database().reference()

    func write(at path: String, value: [String: Any], completion: @escaping (Error?) -> Void) {
        ref(path).setValue(value) { error, _ in completion(error) }
    }

    func read(at path: String, completion: @escaping (Error?, [String: Any]?) -> Void) {
        ref(path).getData { error, snapshot in
            completion(error, snapshot?.value as? [String: Any])
        }
    }

    func delete(at path: String) {
        ref(path).removeValue()
    }

    func observe(at path: String, onChange: @escaping ([String: [String: Any]]) -> Void) -> DatabaseObserverToken {
        return ref(path).observe(.value) { snapshot in
            var result: [String: [String: Any]] = [:]
            for child in snapshot.children {
                guard let snap = child as? DataSnapshot,
                      let data = snap.value as? [String: Any] else { continue }
                result[snap.key] = data
            }
            onChange(result)
        }
    }

    func stopObserving(at path: String, token: DatabaseObserverToken) {
        ref(path).removeObserver(withHandle: token)
    }

    func writeAutoId(at path: String, value: [String: Any]) {
        ref(path).childByAutoId().setValue(value)
    }

    private func ref(_ path: String) -> DatabaseReference {
        path.split(separator: "/").reduce(db) { $0.child(String($1)) }
    }
}
