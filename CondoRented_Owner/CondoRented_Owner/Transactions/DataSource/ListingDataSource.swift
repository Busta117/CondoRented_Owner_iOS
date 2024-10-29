//
//  ListingDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import FirebaseFirestore
import SwiftData

protocol ListingDataSourceProtocol {
    func fetchListings() async -> [Listing]
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
    
    
    @MainActor
    func fetchListingsLocal() async -> [Listing] {
        var modelContainer: ModelContainer? = ModelContainer.sharedModelContainer
        var modelContext: ModelContext? = modelContainer?.mainContext
        
        do {
            let descriptor = FetchDescriptor<Listing>(sortBy: [SortDescriptor(\.title)])
            var listings = try modelContext?.fetch(descriptor) ?? []
            
            listings = listings.map({ listing in
                listing.adminFeeIds = listing.adminFees?.map({$0.id}) ?? []
                return listing
            })
            
            return listings
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func firebaseSaveAll() {
        Task {
            let ls = await fetchListingsLocal()
            let db = Firestore.firestore()
            for l in ls {
                await db.insert(l)
            }
        }
    }
    
}
