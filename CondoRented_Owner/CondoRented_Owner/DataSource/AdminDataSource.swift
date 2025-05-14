//
//  ListingDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import FirebaseFirestore
import Combine

protocol AdminDataSourceProtocol {
    var adminsPublisher: AnyPublisher<[Admin], Never> { get }
    var admins: [Admin] { get }

    func fetchAll() async
    func fetch(id: String) async -> Admin?
    func save(_ admin: Admin) async
}

final class AdminDataSource: AdminDataSourceProtocol {
    private let db: Firestore
    private let adminsSubject = CurrentValueSubject<[Admin], Never>([])

    var adminsPublisher: AnyPublisher<[Admin], Never> {
        adminsSubject.eraseToAnyPublisher()
    }

    var admins: [Admin] {
        adminsSubject.value
    }

    init() {
        db = Firestore.firestore()
    }

    func fetchAll() async {
        let docRef = db.collection("Admin")

        do {
            let result = try await docRef.getDocuments()
            let fetched = try result.documents.map { try $0.data(as: Admin.self) }
            adminsSubject.send(fetched)
        } catch {
            print("Failed to fetch admins: \(error)")
        }
    }

    func fetch(id: String) async -> Admin? {
        let docRef = db.collection("Admin").document(id)
        do {
            let result = try await docRef.getDocument(as: Admin.self)
            return result
        } catch {
            print("Failed to fetch admin with id \(id): \(error)")
            return nil
        }
    }

    func save(_ admin: Admin) async {
        await db.insert(admin)
        var updated = adminsSubject.value
        updated.removeAll { $0.id == admin.id } 
        updated.append(admin)
        adminsSubject.send(updated)
    }
}
