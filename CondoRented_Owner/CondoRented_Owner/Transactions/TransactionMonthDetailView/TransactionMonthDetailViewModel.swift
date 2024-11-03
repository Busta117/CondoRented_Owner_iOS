//
//  TransactionMonthDetailViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 23/05/24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

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
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var transactionsByListing: [Listing: [Transaction]] = [:]
    var transactions: [Transaction]
    var titleMonth: String = ""
    var isLoading = false
    private var output: (Output)->()
    
    var allListings: [Listing] = []
    var allAdminFees: [AdminFee] = []
    var listings: [Listing]
    {
        Array(transactionsByListing.keys).sorted(by: { $0.title < $1.title })
    }
    
    init(dataSource: AppDataSourceProtocol, transactions: [Transaction], output: @escaping (Output)->()) {
        self.dataSource = dataSource
        self.transactions = transactions.sorted(by: {$0.date < $1.date})
        self.output = output
        self.titleMonth = transactions.first?.date.formatted(.dateTime.month(.wide).year()) ?? ""
        
        registerListeners()
        fetchData()
    }
    
    private func fetchData(silence: Bool = false) {
        if !silence {
            isLoading = true
        }
        Task {
            self.allListings = await dataSource.listingDataSource.fetchListings()
            self.allAdminFees = await dataSource.adminFeeDataSource.fetchAll()
            self.transactionsByListing = TransactionHelper.splitByListing(transactions: transactions, listings: self.allListings)
            isLoading = false
        }
    }
    
    private func registerListeners() {
        dataSource.transactionDataSource.actionSubject.sink { [weak self] action in
            switch action {
            case .added(let transaction):
                self?.fetchData(silence: true)
            case .removed:
                self?.fetchData(silence: true)
            case .none:
                ()
            }
        }
        .store(in: &cancellables)
    }
    
    func input(_ input: Input) {
        switch input {
        case .deleteTapped(let indexSet):
            
            let transToDelete = indexSet.map { transactions[$0] }
            Task {
                for tr in transToDelete {
                    await dataSource.transactionDataSource.remove(transaction: tr)
                }
                
                transactions.remove(atOffsets: indexSet)
                transactionsByListing = TransactionHelper.splitByListing(transactions: transactions, listings: allListings)
            }
            
        case .addNewTapped:
            output(.addNewTransaction)
        case .editTransaction(let transaction):
            output(.editTransaction(transaction))
        }
    }
    
    func listing(forId id: String) -> Listing? {
        allListings.first(where: {$0.id == id})
    }
    
    func expectingValue(for listing: Listing) -> (Double, Currency) {
        let value = TransactionHelper.getExpectingValue(for: transactionsByListing[listing] ?? [])
        return (value.0, value.1)
    }
    
    func percentFee(for listing: Listing) -> Double {
        return allAdminFees.filter({$0.listingId == listing.id && $0.dateFinish == nil}).first?.percent ?? 0
    }
    
    func feesToPayValue(for listing: Listing) -> (Double, Currency) {
        let value = TransactionHelper.getFeesToPayValue(for: transactionsByListing[listing] ?? [], includesExpenses: false, adminFees: allAdminFees)
        return (value.0, value.1)
    }
    
    func expensesPayedByAdmin(for listing: Listing) -> [Transaction] {
        guard let byList = transactionsByListing[listing] else { return [] }
        return byList.filter({ $0.type == .expense && $0.expensePaidByOwner != nil && !$0.expensePaidByOwner! })
    }
    
    func totalFeesToPayValue() -> (Double, Currency) {
        let value = TransactionHelper.getFeesToPayValue(for: transactions, includesExpenses: true, adminFees: allAdminFees)
        return (value.0, value.1)
    }
    
}
