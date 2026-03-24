//
//  GoogleAuthManager.swift
//  CondoRented_Owner
//

import Foundation
import GoogleSignIn

@Observable
final class GoogleAuthManager {
    static let shared = GoogleAuthManager()

    private(set) var currentUser: GIDGoogleUser?

    var isSignedIn: Bool { currentUser != nil }

    var userEmail: String? { currentUser?.profile?.email }

    private static let driveScope = "https://www.googleapis.com/auth/drive"

    private init() {}

    /// Restore previous sign-in session on app launch
    func restorePreviousSignIn() async {
        do {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            await MainActor.run { self.currentUser = user }
        } catch {
            await MainActor.run { self.currentUser = nil }
        }
    }

    /// Sign in with Google requesting Drive scope
    @MainActor
    func signIn(presenting viewController: UIViewController) async throws {
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: viewController,
            hint: nil,
            additionalScopes: [Self.driveScope]
        )
        self.currentUser = result.user
    }

    /// Sign out
    @MainActor
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.currentUser = nil
    }

    /// Get a valid access token, refreshing if needed
    func validAccessToken() async throws -> String {
        guard let user = currentUser else {
            throw GoogleAuthError.notSignedIn
        }
        let refreshedUser = try await user.refreshTokensIfNeeded()
        await MainActor.run { self.currentUser = refreshedUser }
        let token = refreshedUser.accessToken.tokenString
        return token
    }
}

enum GoogleAuthError: LocalizedError {
    case notSignedIn
    case noAccessToken

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "No hay sesion de Google activa"
        case .noAccessToken: return "No se pudo obtener el token de acceso"
        }
    }
}
