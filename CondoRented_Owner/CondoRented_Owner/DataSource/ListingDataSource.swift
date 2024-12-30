//
//  ListingDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import FirebaseFirestore


protocol ListingDataSourceProtocol {
    func fetchListings() async -> [Listing]
    func save(_ listing: Listing) async
}

final class ListingDataSource: ListingDataSourceProtocol {
    
    private let db: Firestore
    
    init() {
        db = Firestore.firestore()
    }
    
    func fetchListings() async -> [Listing] {
        let docRef = db.collection("Listing")
        
        do {
            let result  = try await docRef.getDocuments()
            let results = try result.documents.map({ try $0.data(as: Listing.self) })
            
            return results
            
        } catch {
            print(error)
            return []
        }
    }
    
    func save(_ listing: Listing) async {
        await db.insert(listing)
    }
    
}
