//
//  Comunicate_watch_Watch_AppTests.swift
//  Comunicate_watch Watch AppTests
//
//  Created by Alvar Arias on 2024-12-05.
//

import XCTest
@testable import Comunicate_watch_Watch_App

final class Comunicate_watch_Watch_AppTests: XCTestCase {

    // MARK: - InviteModel: createInvite

    func testCreateInvite_success() {
        let auth = MockAuthService()
        auth.currentUserUID = "uid-owner"
        let db = MockDatabaseService()
        let model = InviteModel(db: db, auth: auth)

        model.createInvite()

        let expectation = expectation(description: "createInvite completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(model.generatedCode.isEmpty)
            XCTAssertEqual(model.generatedCode.count, 6)
            XCTAssertFalse(model.isLoading)
            XCTAssertTrue(model.errorMessage.isEmpty)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testCreateInvite_noUser_doesNotWriteToDatabase() {
        let auth = MockAuthService()
        auth.currentUserUID = nil
        let db = MockDatabaseService()
        let model = InviteModel(db: db, auth: auth)

        model.createInvite()

        XCTAssertFalse(db.writeCalled)
        XCTAssertTrue(model.generatedCode.isEmpty)
    }

    func testCreateInvite_databaseError_setsErrorMessage() {
        let auth = MockAuthService()
        let db = MockDatabaseService()
        db.writeError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        let model = InviteModel(db: db, auth: auth)

        model.createInvite()

        let expectation = expectation(description: "error set")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(model.errorMessage, "Network error")
            XCTAssertTrue(model.generatedCode.isEmpty)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    // MARK: - InviteModel: joinInvite

    func testJoinInvite_success_returnsChatId() {
        let auth = MockAuthService()
        auth.currentUserUID = "uid-B"
        let db = MockDatabaseService()
        db.readData = [
            "ownerUID": "uid-A",
            "expiresAt": Date().addingTimeInterval(300).timeIntervalSince1970
        ]
        let model = InviteModel(db: db, auth: auth)

        let expectation = expectation(description: "join completes")
        var resultChatId: String?
        model.joinInvite(code: "ABC123") { chatId in
            resultChatId = chatId
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        let expected = ["uid-A", "uid-B"].sorted().joined(separator: "_")
        XCTAssertEqual(resultChatId, expected)
        XCTAssertFalse(db.deletedPaths.isEmpty)
    }

    func testJoinInvite_expiredCode_setsError() {
        let auth = MockAuthService()
        auth.currentUserUID = "uid-B"
        let db = MockDatabaseService()
        db.readData = [
            "ownerUID": "uid-A",
            "expiresAt": Date().addingTimeInterval(-60).timeIntervalSince1970
        ]
        let model = InviteModel(db: db, auth: auth)

        let expectation = expectation(description: "expired")
        model.joinInvite(code: "EXPIRE") { chatId in
            XCTAssertNil(chatId)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertEqual(model.errorMessage, "Código inválido o expirado")
    }

    func testJoinInvite_ownCode_setsError() {
        let auth = MockAuthService()
        auth.currentUserUID = "uid-A"
        let db = MockDatabaseService()
        db.readData = [
            "ownerUID": "uid-A",
            "expiresAt": Date().addingTimeInterval(300).timeIntervalSince1970
        ]
        let model = InviteModel(db: db, auth: auth)

        let expectation = expectation(description: "own code")
        model.joinInvite(code: "MYSELF") { chatId in
            XCTAssertNil(chatId)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertEqual(model.errorMessage, "No puedes unirte a tu propio código")
    }

    func testJoinInvite_codeIsUppercased() {
        let auth = MockAuthService()
        auth.currentUserUID = "uid-B"
        let db = MockDatabaseService()
        db.readData = [
            "ownerUID": "uid-A",
            "expiresAt": Date().addingTimeInterval(300).timeIntervalSince1970
        ]
        let model = InviteModel(db: db, auth: auth)

        let expectation = expectation(description: "uppercase")
        model.joinInvite(code: "abc123") { _ in expectation.fulfill() }
        waitForExpectations(timeout: 1)

        XCTAssertTrue(db.deletedPaths.first?.contains("ABC123") ?? false)
    }

    // MARK: - ChatId determinism

    func testChatId_isDeterministic() {
        let a = "uid-alpha"
        let b = "uid-beta"
        let chatIdAB = [a, b].sorted().joined(separator: "_")
        let chatIdBA = [b, a].sorted().joined(separator: "_")
        XCTAssertEqual(chatIdAB, chatIdBA)
    }

    // MARK: - ChatModel: sendMessage

    func testSendMessage_empty_doesNotWrite() {
        let auth = MockAuthService()
        let db = MockDatabaseService()
        let model = ChatModel(chatId: "test-chat", db: db, auth: auth)

        model.sendMessage("")

        XCTAssertFalse(db.writeAutoIdCalled)
    }

    func testSendMessage_noUser_doesNotWrite() {
        let auth = MockAuthService()
        auth.currentUserUID = nil
        let db = MockDatabaseService()
        let model = ChatModel(chatId: "test-chat", db: db, auth: auth)

        model.sendMessage("Hola")

        XCTAssertFalse(db.writeAutoIdCalled)
    }

    func testSendMessage_validMessage_writesToCorrectPath() {
        let auth = MockAuthService()
        auth.currentUserUID = "uid-sender"
        let db = MockDatabaseService()
        let model = ChatModel(chatId: "room-123", db: db, auth: auth)

        model.sendMessage("Hola mundo")

        XCTAssertTrue(db.writeAutoIdCalled)
        XCTAssertEqual(db.lastWrittenPath, "chats/room-123/messages")
        XCTAssertEqual(db.lastWrittenValue?["text"] as? String, "Hola mundo")
        XCTAssertEqual(db.lastWrittenValue?["senderUID"] as? String, "uid-sender")
    }

    // MARK: - AuthModel

    func testLogin_success_setsIsLoggedIn() {
        let auth = MockAuthService()
        let model = AuthModel(auth: auth)
        model.isLoggedIn = false

        model.login(email: "test@test.com", password: "pass")

        let expectation = expectation(description: "login")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(model.isLoggedIn)
            XCTAssertTrue(model.errorMessage.isEmpty)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testLogin_failure_setsErrorMessage() {
        let auth = MockAuthService()
        auth.currentUserUID = nil
        auth.signInError = NSError(domain: "auth", code: 17009,
                                   userInfo: [NSLocalizedDescriptionKey: "Contraseña incorrecta"])
        let model = AuthModel(auth: auth)

        model.login(email: "test@test.com", password: "wrong")

        let expectation = expectation(description: "login error")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(model.isLoggedIn)
            XCTAssertFalse(model.errorMessage.isEmpty)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testLogout_clearsLoginState() {
        let auth = MockAuthService()
        let model = AuthModel(auth: auth)
        model.isLoggedIn = true

        model.logout()

        XCTAssertFalse(model.isLoggedIn)
        XCTAssertTrue(auth.signOutCalled)
    }
}
