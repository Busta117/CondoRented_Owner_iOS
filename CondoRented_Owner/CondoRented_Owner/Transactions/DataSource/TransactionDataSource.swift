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
    private var modelContainer: ModelContainer? = nil
    private var modelContext: ModelContext? = nil
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

    func add(transaction: Transaction) throws {
        guard let modelContext = modelContext else { return }
        
        modelContext.insert(transaction)
        try modelContext.save()
        
        db.insert(transaction, collection: "Transaction")
    }

    func fetchTransactions() -> [Transaction] {
        guard let modelContext = modelContext else { return [] }
        do {
            let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
            let transactions = try modelContext.fetch(descriptor)
            
            //sync with db
//            for transaction in transactions {
//                db.insert(transaction, collection: "Transaction")
//            }
                
            
            return transactions
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func firebaseSaveAll() {
        Task {
            let ls = fetchTransactions()
            let db = Firestore.firestore()
            for l in ls {
                db.insert(l, collection: "Transaction")
            }
        }
        
    }
    
    func remove(transaction: Transaction) throws {
        guard let modelContext = modelContext else { return }
        
        modelContext.delete(transaction)
        try modelContext.save()
    }
}
