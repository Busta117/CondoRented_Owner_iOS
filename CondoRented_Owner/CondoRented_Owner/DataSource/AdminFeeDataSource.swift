//
//  AdminFeeDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import FirebaseFirestore
import Combine

protocol AdminFeeDataSourceProtocol {
    var adminFeesPublisher: AnyPublisher<[AdminFee], Never> { get }
    var adminFees: [AdminFee] { get }

    func fetchAll() async
    func fetch(id: String) async -> AdminFee?
    func fetch(forListingId listingId: String) -> [AdminFee]
    func save(_ adminFee: AdminFee) async
}

final class AdminFeeDataSource: AdminFeeDataSourceProtocol {
    private let db: Firestore
    private let adminFeesSubject = CurrentValueSubject<[AdminFee], Never>([])

    var adminFeesPublisher: AnyPublisher<[AdminFee], Never> {
        adminFeesSubject.eraseToAnyPublisher()
    }

    var adminFees: [AdminFee] {
        adminFeesSubject.value
    }

    init() {
        db = Firestore.firestore()
    }

    func fetchAll() async {
        let docRef = db.collection("AdminFee")

        do {
            let result = try await docRef.getDocuments()
            let fetched = try result.documents.map { try $0.data(as: AdminFee.self) }
            adminFeesSubject.send(fetched)
        } catch {
            print("Failed to fetch admin fees: \(error)")
        }
    }

    func fetch(id: String) async -> AdminFee? {
        let docRef = db.collection("AdminFee").document(id)
        do {
            return try await docRef.getDocument(as: AdminFee.self)
        } catch {
            print("Failed to fetch AdminFee with id \(id): \(error)")
            return nil
        }
    }

    func fetch(forListingId listingId: String) -> [AdminFee] {
        adminFees.filter { $0.listingId == listingId }
    }

    func save(_ adminFee: AdminFee) async {
        await db.insert(adminFee)
        var updated = adminFeesSubject.value
        updated.removeAll { $0.id == adminFee.id }
        updated.append(adminFee)
        adminFeesSubject.send(updated)
    }
}
