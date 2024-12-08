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

enum TransactionAction {
    case added(Transaction)
    case removed(Transaction)
}

protocol TransactionDataSourceProtocol {
    var actionSubject: CurrentValueSubject<TransactionAction?, Never> { get }
    func fetchTransactions() async -> [Transaction]
    func add(transaction: Transaction) async
    func remove(transaction: Transaction) async
}

final class TransactionDataSource: TransactionDataSourceProtocol {
    let actionSubject = CurrentValueSubject<TransactionAction?, Never>(nil)
    
    private let db: Firestore
    
    init() {
        db = Firestore.firestore()
    }

    func add(transaction: Transaction) async {
        await db.insert(transaction)
        actionSubject.send(.added(transaction))
    }
    
    func remove(transaction: Transaction) async {
        await db.delete(transaction)
        actionSubject.send(.removed(transaction))
    }
    
    func fetchTransactions() async -> [Transaction] {
        let docRef = db.collection("Transaction")
        
        do {
            let result  = try await docRef.getDocuments()
            let results = try result.documents.map({ try $0.data(as: Transaction.self) })
            
            return results
            
        } catch {
            print(error)
            return []
        }
    }
}
