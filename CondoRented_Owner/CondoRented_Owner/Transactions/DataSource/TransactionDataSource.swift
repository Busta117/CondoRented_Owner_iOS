//
//  TransactionDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 14/05/24.
//

import Foundation
import SwiftData
import SwiftUI

protocol TransactionDataSourceProtocol {
    func fetchTransactions() -> [Transaction]
    func add(transaction: Transaction) throws
    func remove(transaction: Transaction) throws
}

final class TransactionDataSource: TransactionDataSourceProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }

    func add(transaction: Transaction) throws {
        modelContext.insert(transaction)
        try modelContext.save()
    }

    func fetchTransactions() -> [Transaction] {
        do {
            let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
            return try modelContext.fetch(descriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func remove(transaction: Transaction) throws {
        modelContext.delete(transaction)
        try modelContext.save()
    }
}
