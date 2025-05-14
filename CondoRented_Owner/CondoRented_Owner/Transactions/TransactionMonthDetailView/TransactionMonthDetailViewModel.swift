//
//  TransactionMonthDetailViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 23/05/24.
//

import Foundation
import SwiftUI
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
    @ObservationIgnored
    private let output: (Output) -> Void
    @ObservationIgnored
    private let transactionDateMonthReference: Date
    @ObservationIgnored
    var selectedListingId: String?

    var transactionsByListing: [Listing: [Transaction]] = [:]
    var transactions: [Transaction] = []
    var titleMonth: String = ""

    var allListings: [Listing] = []
    var allAdminFees: [AdminFee] = []

    var listings: [Listing] {
        Array(transactionsByListing.keys).sorted { $0.title < $1.title }
    }
    var selectedListing: Listing? {
        allListings.first { $0.id == selectedListingId }
    }

    init(dataSource: AppDataSourceProtocol, transactions: [Transaction], selectedListingId: String? = nil, output: @escaping (Output) -> Void) {
        self.dataSource = dataSource
        self.output = output
        self.transactionDateMonthReference = transactions.first?.date ?? .now
        self.titleMonth = transactions.first?.date.formatted(.dateTime.month(.wide).year()) ?? ""
        
        self.transactions = dataSource.transactionDataSource.transactions
            .filter { Calendar.current.isDate($0.date, equalTo: self.transactionDateMonthReference, toGranularity: .month) }
            .sorted { $0.date < $1.date }
        
        if let selectedListingId = selectedListingId {
            self.selectedListingId = selectedListingId
            self.transactions = self.transactions.filter { $0.listingId == selectedListingId }
        }

        registerListeners()
        fetchInitialData()
    }

    private func fetchInitialData() {
        Task {
            await dataSource.listingDataSource.fetchListings()
            await dataSource.adminFeeDataSource.fetchAll()
        }
    }

    private func updateTransactionsByListing() {
        transactionsByListing = TransactionHelper.splitByListing(transactions: transactions, listings: allListings)
    }

    private func registerListeners() {
        
        dataSource.transactionDataSource.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                guard let self else { return }
                var filtered = transactions
                    .filter { Calendar.current.isDate($0.date, equalTo: self.transactionDateMonthReference, toGranularity: .month) }
                    .sorted { $0.date < $1.date }
                
                if let selectedListingId {
                    filtered = filtered.filter { $0.listingId == selectedListingId }
                }
                
                self.transactions = filtered
                self.updateTransactionsByListing()
            }
            .store(in: &cancellables)
        
        // Reactivo a cambios en listings
        dataSource.listingDataSource.listingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                self?.allListings = listings
                self?.updateTransactionsByListing()
            }
            .store(in: &cancellables)

        // Reactivo a cambios en admin fees
        dataSource.adminFeeDataSource.adminFeesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fees in
                self?.allAdminFees = fees
            }
            .store(in: &cancellables)
    }

    func input(_ input: Input) {
        switch input {
        case .addNewTapped:
            output(.addNewTransaction)

        case .editTransaction(let transaction):
            output(.editTransaction(transaction))

        case .deleteTapped(let indexSet):
            let toDelete = indexSet.map { transactions[$0] }
            Task {
                for transaction in toDelete {
                    await dataSource.transactionDataSource.remove(transaction: transaction)
                }
                transactions.remove(atOffsets: indexSet)
                updateTransactionsByListing()
            }
        }
    }

    func listing(forId id: String) -> Listing? {
        allListings.first { $0.id == id }
    }

    func expectingValue(for listing: Listing) -> (Double, Currency) {
        TransactionHelper.getExpectingValue(for: transactionsByListing[listing] ?? [])
    }

    func percentFee(for listing: Listing) -> Double {
        let relevantFees = transactions.compactMap { transaction in
            allAdminFees.first {
                $0.listingId == listing.id &&
                $0.dateStart <= transaction.date &&
                ($0.dateFinish ?? .distantFuture) >= transaction.date
            }
        }
        return relevantFees.first?.percent ?? 0
    }

    func feesToPayValue(for listing: Listing) -> (Double, Currency) {
        TransactionHelper.getFeesToPayValue(
            for: transactionsByListing[listing] ?? [],
            includesExpenses: false,
            adminFees: allAdminFees
        )
    }

    func expensesPayedByAdmin(for listing: Listing) -> [Transaction] {
        guard let byListing = transactionsByListing[listing] else { return [] }
        return byListing.filter {
            if case .expense = $0.type,
               let paidByOwner = $0.expensePaidByOwner,
               !paidByOwner {
                return true
            }
            return false
        }
    }

    func totalFeesToPayValue() -> (Double, Currency) {
        TransactionHelper.getFeesToPayValue(
            for: transactions,
            includesExpenses: true,
            adminFees: allAdminFees
        )
    }
}
