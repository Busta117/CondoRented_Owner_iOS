//
//  AccountManager.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import Foundation

protocol AccountManagerProtocol {
    var accountId: String? { get }
    func setAccountId(_ id: String)
    func clear()
}

final class AccountManager: AccountManagerProtocol {
    private static let accountIdKey = "currentAccountId"

    var accountId: String? {
        UserDefaults.standard.string(forKey: Self.accountIdKey)
    }

    func setAccountId(_ id: String) {
        UserDefaults.standard.set(id, forKey: Self.accountIdKey)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Self.accountIdKey)
    }
}
