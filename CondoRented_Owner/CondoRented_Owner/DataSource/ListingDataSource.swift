//
//  ListingDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import FirebaseFirestore
import Combine

protocol ListingDataSourceProtocol {
    var listingsPublisher: AnyPublisher<[Listing], Never> { get }
    var listings: [Listing] { get }

    func fetchListings() async
    func save(_ listing: Listing) async
}

final class ListingDataSource: ListingDataSourceProtocol {

    private let db: Firestore
    private let listingsSubject = CurrentValueSubject<[Listing], Never>([])

    var listingsPublisher: AnyPublisher<[Listing], Never> {
        listingsSubject.eraseToAnyPublisher()
    }

    var listings: [Listing] {
        listingsSubject.value
    }

    init() {
        self.db = Firestore.firestore()
    }

    func fetchListings() async {
        let docRef = db.collection("Listing")

        do {
            let result = try await docRef.getDocuments()
            let fetched = try result.documents.map { try $0.data(as: Listing.self) }
            listingsSubject.send(fetched)
        } catch {
            print("Failed to fetch listings: \(error)")
        }
    }

    func save(_ listing: Listing) async {
        await db.insert(listing)
        var updated = listingsSubject.value
        updated.append(listing)
        listingsSubject.send(updated)
    }
}
