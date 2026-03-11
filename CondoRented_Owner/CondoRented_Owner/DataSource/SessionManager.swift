//
//  SessionManager.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import Foundation
import Combine

enum SessionState {
    case loading
    case unauthenticated
    case authenticated
}

@MainActor
final class SessionManager: ObservableObject {
    @Published var state: SessionState = .loading
    @Published var currentUser: AppUser?
    @Published var accounts: [AccountMember] = []
    @Published var activeAccountId: String?
    @Published private(set) var appDataSource: AppDataSource?

    private let authManager: AuthManagerProtocol
    private let userDataSource: UserDataSourceProtocol
    private let accountMemberDataSource: AccountMemberDataSourceProtocol
    private let accountManager: AccountManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authManager: AuthManagerProtocol = AuthManager(),
         userDataSource: UserDataSourceProtocol = UserDataSource(),
         accountMemberDataSource: AccountMemberDataSourceProtocol = AccountMemberDataSource(),
         accountManager: AccountManagerProtocol = AccountManager()) {

        self.authManager = authManager
        self.userDataSource = userDataSource
        self.accountMemberDataSource = accountMemberDataSource
        self.accountManager = accountManager

        authManager.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userId in
                Task { await self?.handleAuthChange(userId: userId) }
            }
            .store(in: &cancellables)
    }

    private func handleAuthChange(userId: String?) async {
        guard let userId else {
            state = .unauthenticated
            currentUser = nil
            accounts = []
            activeAccountId = nil
            appDataSource = nil
            return
        }

        state = .loading
        currentUser = await userDataSource.fetch(id: userId)
        accounts = await accountMemberDataSource.fetchAccounts(forUserId: userId)

        if let saved = accountManager.accountId,
           accounts.contains(where: { $0.accountId == saved }) {
            activeAccountId = saved
        } else if let first = accounts.first {
            activeAccountId = first.accountId
            accountManager.setAccountId(first.accountId)
        }

        if let accountId = activeAccountId {
            buildDataSource(accountId: accountId)
        }

        state = .authenticated
    }

    func switchAccount(to accountId: String) {
        activeAccountId = accountId
        accountManager.setAccountId(accountId)
        buildDataSource(accountId: accountId)
    }

    private func buildDataSource(accountId: String) {
        appDataSource = AppDataSource(
            transactionDataSource: TransactionDataSource(accountId: accountId),
            listingDataSource: ListingDataSource(accountId: accountId),
            adminDataSource: AdminDataSource(accountId: accountId),
            adminFeeDataSource: AdminFeeDataSource(accountId: accountId)
        )
    }

    func signIn(email: String, password: String) async throws {
        try await authManager.signIn(email: email, password: password)
    }

    func signOut() {
        try? authManager.signOut()
        accountManager.clear()
    }
}
