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
    func fetchListings() -> [Listing]
}

final class ListingDataSource: ListingDataSourceProtocol {
    private var modelContainer: ModelContainer
    private var modelContext: ModelContext
    private let db: Firestore
    
    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        db = Firestore.firestore()
    }
    
    func fetchListings() -> [Listing] {
        do {
            let descriptor = FetchDescriptor<Listing>(sortBy: [SortDescriptor(\.title)])
            let listings = try modelContext.fetch(descriptor)
            
            //sync with db
            for listing in listings {
                db.insert(listing, collection: "Listing")
            }
            
            return listings
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
