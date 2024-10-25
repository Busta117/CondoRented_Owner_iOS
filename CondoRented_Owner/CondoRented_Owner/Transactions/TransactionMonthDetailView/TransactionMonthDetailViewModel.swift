//
//  TransactionMonthDetailViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 23/05/24.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class TransactionMonthDetailViewModel {
    
    enum Input {
        case addNewTapped
        case deleteTapped(IndexSet)
        case editTransaction(Transaction)
    }
    
    enum Output {
        case addNewTransaction
        case editTransaction(Transaction)
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    
    var transactionsByListing: [Listing: [Transaction]] = [:]
    var transactions: [Transaction]
    var titleMonth: String = ""
    private var output: (Output)->()
    
    var allListings: [Listing] = []
    var listings: [Listing]
    {
        Array(transactionsByListing.keys).sorted(by: { $0.title < $1.title })
    }
    
    init(dataSource: AppDataSourceProtocol, transactions: [Transaction], output: @escaping (Output)->()) {
        self.dataSource = dataSource
        self.transactions = transactions
        self.output = output
        self.titleMonth = transactions.first?.date.formatted(.dateTime.month(.wide).year()) ?? ""
        
        fetchData()
    }
    
    private func fetchData() {
        Task {
            self.allListings = await dataSource.listingDataSource.fetchListings()
            self.transactionsByListing = TransactionHelper.splitByListing(transactions: transactions, listings: self.allListings)
        }
    }
    
    func input(_ input: Input) {
        switch input {
        case .deleteTapped(let indexSet):
            
            let transToDelete = indexSet.map { transactions[$0] }
            transToDelete.forEach { tr in
                try? dataSource.transactionDataSource.remove(transaction: tr)
            }
            transactions.remove(atOffsets: indexSet)
            transactionsByListing = TransactionHelper.splitByListing(transactions: transactions, listings: allListings)
            
        case .addNewTapped:
            output(.addNewTransaction)
        case .editTransaction(let transaction):
            output(.editTransaction(transaction))
        }
    }
    
    func expectingValue(for listing: Listing) -> (Double, Currency) {
        let value = TransactionHelper.getExpectingValue(for: transactionsByListing[listing] ?? [])
        return (value.0, value.1)
    }
    
    func percentFee(for listing: Listing) -> Double {
        return listing.adminFees?.filter({ $0.dateFinish == nil }).first?.percent ?? 0
    }
    
    func feesToPayValue(for listing: Listing) -> (Double, Currency) {
        let value = TransactionHelper.getFeesToPayValue(for: transactionsByListing[listing] ?? [], includesExpenses: false)
        return (value.0, value.1)
    }
    
    func expensesPayedByAdmin(for listing: Listing) -> [Transaction] {
        guard let byList = transactionsByListing[listing] else { return [] }
        return byList.filter({ $0.type == .expense && $0.expensePaidByOwner != nil && !$0.expensePaidByOwner! })
    }
    
    func totalFeesToPayValue() -> (Double, Currency) {
        let value = TransactionHelper.getFeesToPayValue(for: transactions, includesExpenses: true)
        return (value.0, value.1)
    }
    
}
