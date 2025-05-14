//
//  AddEditTransactionViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import SwiftUI
import Combine

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
    var output: (Output) -> Void
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var allCurrencies: [Currency] = []
    var allListing: [Listing] = []

    var loading: Bool = true
    
    var amount: Double = 0
    var currency: Currency = Currency(id: "COP")
    var listing: Listing? = nil
    var date: Date = .now
    var type: TransactionType? = nil

    var paidAmountFormatted: String? = nil
    var paidAmountCurrency: Currency? = nil
    var expenseConcept: String? = nil
    var expensePaidByOwner: Bool = true

    init(transaction: Transaction? = nil,
         dataSource: AppDataSourceProtocol,
         output: @escaping (Output) -> Void) {
        self.transaction = transaction
        self.dataSource = dataSource
        self.output = output
        
        registerListeners()
        fetchInitialData()
    }
    
    private func fetchInitialData() {
        Task {
            await dataSource.listingDataSource.fetchListings()
            await MainActor.run {
                self.allCurrencies = Currency.all
                self.currency = Currency.all.first ?? Currency(id: "COP")
                self.onDoneLoaded()
            }
        }
    }

    private func registerListeners() {
        dataSource.listingDataSource.listingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                guard let self else { return }
                self.allListing = listings
                if self.transaction != nil {
                    self.onDoneLoaded() // Actualiza si ya estabas editando
                }
            }
            .store(in: &cancellables)
    }

    private func onDoneLoaded() {
        guard let transaction = transaction else {
            loading = false
            return
        }

        self.amount = transaction.amountMicros * transaction.currency.microMultiplier
        self.currency = transaction.currency
        self.listing = allListing.first(where: { $0.id == transaction.listingId })
        self.date = transaction.date
        self.type = transaction.type
        self.expenseConcept = transaction.expenseConcept
        self.expensePaidByOwner = transaction.expensePaidByOwner ?? true
        self.loading = false
    }
    
    var navigationTitle: String {
        transaction == nil ? "New transaction" : "Edit transaction"
    }
    
    var isAmountCorrect: Bool {
        amount > 0
    }
    
    var canSave: Bool {
        isAmountCorrect && listing != nil && type != nil
    }
    
    func input(_ input: Input) {
        switch input {
        case .saveTapped:
            saveTransaction()
        }
    }
    
    private func saveTransaction() {
        loading = true
        
        guard let listing = listing, let type = type else {
            return
        }
        
        let microAmount = amount / currency.microMultiplier
        
        let expenseConceptFixed: String? = {
            return switch type {
            case .expense(let title):
                type.isOther ? expenseConcept : title
            default:
                nil
            }
        }()
        
        let expensePaidByOwnerFixed: Bool? = {
            if case .expense = type {
                return expensePaidByOwner
            }
            return nil
        }()
        
        let newTransaction = Transaction(
            id: transaction?.id ?? UUID().uuidString,
            amountFormatted: "",
            amountMicros: microAmount,
            currency: currency,
            listingId: listing.id,
            date: date,
            type: type,
            paidAmountFormatted: nil,
            paidAmountCurrency: nil,
            expenseConcept: expenseConceptFixed,
            expensePaidByOwner: expensePaidByOwnerFixed
        )
        
        Task {
            await dataSource.transactionDataSource.add(transaction: newTransaction)
            await MainActor.run {
                self.loading = false
                self.output(.back)
            }
        }
    }
}
