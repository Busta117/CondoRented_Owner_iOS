//
//  ListingDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import SwiftData

protocol ListingDataSourceProtocol {
    func fetchListings() -> [Listing]
}

final class ListingDataSource: ListingDataSourceProtocol {
    private var modelContainer: ModelContainer
    private var modelContext: ModelContext
    
    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    func fetchListings() -> [Listing] {
        do {
            let descriptor = FetchDescriptor<Listing>(sortBy: [SortDescriptor(\.title)])
            return try modelContext.fetch(descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
