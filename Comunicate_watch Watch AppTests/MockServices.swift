//
//  MockServices.swift
//  Comunicate_watch Watch AppTests
//

import Foundation
@testable import Comunicate_watch_Watch_App

class MockAuthService: AuthServiceProtocol {
    var currentUserUID: String? = "mock-uid-A"
    var signInError: Error?
    var createUserError: Error?
    var signOutCalled = false

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        completion(signInError)
    }

    func createUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        completion(createUserError)
    }

    func signOut() throws {
        signOutCalled = true
    }
}

class MockDatabaseService: DatabaseServiceProtocol {
    var writeError: Error?
    var readData: [String: Any]?
    var readError: Error?
    var writeCalled = false
    var writeAutoIdCalled = false
    var deletedPaths: [String] = []
    var lastWrittenPath: String?
    var lastWrittenValue: [String: Any]?

    func write(at path: String, value: [String: Any], completion: @escaping (Error?) -> Void) {
        writeCalled = true
        lastWrittenPath = path
        lastWrittenValue = value
        completion(writeError)
    }

    func read(at path: String, completion: @escaping (Error?, [String: Any]?) -> Void) {
        completion(readError, readData)
    }

    func delete(at path: String) {
        deletedPaths.append(path)
    }

    func observe(at path: String, onChange: @escaping ([String: [String: Any]]) -> Void) -> DatabaseObserverToken {
        return 0
    }

    func stopObserving(at path: String, token: DatabaseObserverToken) {}

    func writeAutoId(at path: String, value: [String: Any]) {
        writeAutoIdCalled = true
        lastWrittenPath = path
        lastWrittenValue = value
    }
}
