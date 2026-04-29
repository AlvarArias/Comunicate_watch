//
//  Protocols.swift
//  Comunicate_watch Watch App
//

import Foundation

typealias DatabaseObserverToken = UInt

protocol AuthServiceProtocol {
    var currentUserUID: String? { get }
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void)
    func createUser(email: String, password: String, completion: @escaping (Error?) -> Void)
    func signOut() throws
}

protocol DatabaseServiceProtocol {
    func write(at path: String, value: [String: Any], completion: @escaping (Error?) -> Void)
    func read(at path: String, completion: @escaping (Error?, [String: Any]?) -> Void)
    func delete(at path: String)
    func observe(at path: String, onChange: @escaping ([String: [String: Any]]) -> Void) -> DatabaseObserverToken
    func stopObserving(at path: String, token: DatabaseObserverToken)
    func writeAutoId(at path: String, value: [String: Any])
}
