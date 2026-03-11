//
//  AuthManager.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import Foundation
import FirebaseAuth
import Combine

protocol AuthManagerProtocol {
    var currentUserId: String? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<String?, Never> { get }

    func signIn(email: String, password: String) async throws
    func signOut() throws
}

final class AuthManager: AuthManagerProtocol {
    private let authStateSubject = CurrentValueSubject<String?, Never>(nil)
    private var handle: AuthStateDidChangeListenerHandle?

    var currentUserId: String? {
        authStateSubject.value
    }

    var isAuthenticated: Bool {
        currentUserId != nil
    }

    var authStatePublisher: AnyPublisher<String?, Never> {
        authStateSubject.eraseToAnyPublisher()
    }

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.authStateSubject.send(user?.uid)
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
