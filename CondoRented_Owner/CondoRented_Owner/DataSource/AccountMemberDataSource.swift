//
//  AccountMemberDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import Foundation
import FirebaseFirestore

protocol AccountMemberDataSourceProtocol {
    func fetchAccounts(forUserId userId: String) async -> [AccountMember]
}

final class AccountMemberDataSource: AccountMemberDataSourceProtocol {
    private let db: Firestore

    init() {
        self.db = Firestore.firestore()
    }

    func fetchAccounts(forUserId userId: String) async -> [AccountMember] {
        do {
            let snapshot = try await db.collection("AccountMember")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            return try snapshot.documents.map { try $0.data(as: AccountMember.self) }
        } catch {
            print("Failed to fetch account members: \(error)")
            return []
        }
    }
}
