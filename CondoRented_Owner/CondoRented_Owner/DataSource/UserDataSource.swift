//
//  UserDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import Foundation
import FirebaseFirestore

protocol UserDataSourceProtocol {
    func fetch(id: String) async -> AppUser?
}

final class UserDataSource: UserDataSourceProtocol {
    private let db: Firestore

    init() {
        self.db = Firestore.firestore()
    }

    func fetch(id: String) async -> AppUser? {
        do {
            return try await db.collection("User").document(id).getDocument(as: AppUser.self)
        } catch {
            print("Failed to fetch user \(id): \(error)")
            return nil
        }
    }
}
