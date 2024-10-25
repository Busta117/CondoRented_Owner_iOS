//
//  TransactionDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 14/05/24.
//

import Foundation
import FirebaseFirestore
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
    private let db: Firestore

    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        db = Firestore.firestore()
    }

    func add(transaction: Transaction) throws {
        modelContext.insert(transaction)
        try modelContext.save()
        
        db.insert(transaction, collection: "Transaction")
    }

    func fetchTransactions() -> [Transaction] {
        do {
            let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
            let transactions = try modelContext.fetch(descriptor)
            
            //sync with db
            
            
            for transaction in transactions {
                db.insert(transaction, collection: "Transaction")
            }
                
            
            return transactions
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func remove(transaction: Transaction) throws {
        modelContext.delete(transaction)
        try modelContext.save()
    }
}
