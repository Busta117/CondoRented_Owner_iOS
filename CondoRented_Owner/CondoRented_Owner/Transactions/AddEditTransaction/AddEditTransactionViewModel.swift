//
//  AddEditTransactionViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class AddEditTransactionViewModel {
    
    enum Output {
        case back
    }
    
    enum Input {
        case saveTapped
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    var transaction: Transaction?
    @ObservationIgnored
    var output: (Output)->()
    
    var allCurrencies = [Currency]()
    
    var loading: Bool = true
    var amount: Double = 0
    var isAmountCorrect: Bool {
        if amount > 0 {
            return true
        }
        return false
    }
    
    var currency: Currency = Currency(id: "COP")
    var listing: Listing? = nil
    var date: Date = .now
    var type: Transaction.TransactionType? = nil
    
    // when is paid
    var paidAmountFormatted: String? = nil
    var paidAmountCurrency: Currency? = nil
    
    // when is expense
    var expenseConcept: String? = nil
    var expensePaidByOwner: Bool = true
    
    var allListing: [Listing] = []
    
    init(transaction: Transaction? = nil,
         dataSource: AppDataSourceProtocol,
         output: @escaping (Output)->()) {
        self.transaction = transaction
        self.dataSource = dataSource
        self.output = output
        
        fetchData()
    }
    
    func fetchData() {
        Task {
            allListing = await dataSource.listingDataSource.fetchListings()
            
            allCurrencies = Currency.all
            self.currency = Currency.all.first ?? Currency(id: "COP")
            
            onDoneLoaded()
        }
    }
    
    func onDoneLoaded() {
        
        // edit mode
        if let transaction = transaction {
            self.amount = transaction.amountMicros * transaction.currency.microMultiplier
            self.currency = transaction.currency
            self.listing = allListing.first(where: {$0.id == transaction.listingId})
            self.date = transaction.date
            self.type = transaction.type
            self.expenseConcept = transaction.expenseConcept
            self.expensePaidByOwner = transaction.expensePaidByOwner ?? true
        }
        
        loading = false
    }
    
    var navigationTitle: String {
        if transaction == nil {
            return "New transaction"
        }
        return "Edit transaction"
    }
    
    var canSave: Bool {
        if isAmountCorrect &&
            listing != nil &&
            type != nil {
            return true
        }
        return false
    }
    
    func input(_ input: Input) {
        switch input {
        case .saveTapped:
            loading = true
            guard let listing = listing, let type = type else {
                return
            }
            
            let microAmount = amount / currency.microMultiplier
            
            let expenseConcept = (type == .expense || type == .fixedCost) ? (expenseConcept ?? "other") : nil
            let expensePaidByOwner = (type == .expense) ? expensePaidByOwner : nil
            
            let newTransaction = Transaction(id: transaction?.id ?? UUID().uuidString, amountFormatted: "",
                                             amountMicros: microAmount,
                                             currency: currency,
                                             listingId: listing.id,
                                             date: date,
                                             type: type,
                                             paidAmountFormatted: nil,
                                             paidAmountCurrency: nil,
                                             expenseConcept: expenseConcept,
                                             expensePaidByOwner: expensePaidByOwner)
            
            Task {
                await dataSource.transactionDataSource.add(transaction: newTransaction)
                loading = false
                output(.back)
            }
        }
    }
}
