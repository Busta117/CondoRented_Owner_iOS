//
//  Currency.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class Currency {
    @Attribute(.unique) var id: String
    var microMultiplier: Double
    
    init(id: String, microMultiplier: Double? = 0.000001) {
        self.id = id
        self.microMultiplier = microMultiplier ?? 0.000001
    }
}

extension Currency {
    
    static private(set) var all = [Currency]()
    
    @MainActor
    static func loadAll() {
        let container = ModelContainer.sharedModelContainer
        let modelContext = container.mainContext
        let descriptor = FetchDescriptor<Currency>(sortBy: [SortDescriptor(\.id, order: .forward)])
        do {
            all = try modelContext.fetch(descriptor)
        } catch {
            all = []
        }
    }
}
