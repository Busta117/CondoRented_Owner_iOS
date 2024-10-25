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
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    private let db: Firestore
    
    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        db = Firestore.firestore()
    }
    
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
    
    
    func fetchListingsLocal() async -> [Listing] {
        do {
            let descriptor = FetchDescriptor<Listing>(sortBy: [SortDescriptor(\.title)])
            let listings = try modelContext?.fetch(descriptor) ?? []
            
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
                db.insert(l, collection: "Listing")
            }
        }
    }
    
}
