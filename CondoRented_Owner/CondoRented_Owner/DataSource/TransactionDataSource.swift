//
//  TransactionDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 14/05/24.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

protocol TransactionDataSourceProtocol {
    var transactionsPublisher: AnyPublisher<[Transaction], Never> { get }
    var transactions: [Transaction] { get }
    func fetchTransactions() async
    func add(transaction: Transaction) async
    func remove(transaction: Transaction) async
}

final class TransactionDataSource: TransactionDataSourceProtocol {
    private let db: Firestore
    
    private let transactionsSubject = CurrentValueSubject<[Transaction], Never>([])
    var transactionsPublisher: AnyPublisher<[Transaction], Never> {
        transactionsSubject.eraseToAnyPublisher()
    }
    
    var transactions: [Transaction] {
        transactionsSubject.value
    }
    
    init() {
        db = Firestore.firestore()
    }

    func fetchTransactions() async {
        let docRef = db.collection("Transaction")
        
        do {
            let result  = try await docRef.getDocuments()
            let results = try result.documents.map({ try $0.data(as: Transaction.self) })
            transactionsSubject.send(results)
            
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
    }
    
    func add(transaction: Transaction) async {
        await db.insert(transaction)
        var updated = transactionsSubject.value
        
        if let index = updated.firstIndex(where: { $0.id == transaction.id }) {
            updated[index] = transaction
        } else {
            updated.append(transaction)
        }
        transactionsSubject.send(updated)
    }
    
    func remove(transaction: Transaction) async {
        await db.delete(transaction)
        var updated = transactionsSubject.value
        updated.removeAll { $0.id == transaction.id }
        transactionsSubject.send(updated)
        
    }
}
