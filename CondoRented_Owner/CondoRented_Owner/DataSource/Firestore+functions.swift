//
//  Firestore+functions.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 30/11/24.
//

import Foundation
import FirebaseFirestore

extension Firestore {

    func accountCollection(_ collectionName: String, accountId: String) -> CollectionReference {
        self.collection("Account").document(accountId).collection(collectionName)
    }

    func insert<T>(_ object: T, accountId: String) async where T: CodableAndIdentifiable {
        do {
            try accountCollection(object.collectionId, accountId: accountId).document(object.id).setData(from: object)
        } catch {
            print("Error adding document: \(error)")
        }
    }

    func delete<T>(_ object: T, accountId: String) async where T: CodableAndIdentifiable {
        do {
            try await accountCollection(object.collectionId, accountId: accountId).document(object.id).delete()
        } catch {
            print("Error adding document: \(error)")
        }
    }

    func insertAtRoot<T>(_ object: T) async where T: CodableAndIdentifiable {
        do {
            try self.collection(object.collectionId).document(object.id).setData(from: object)
        } catch {
            print("Error adding document: \(error)")
        }
    }
}
