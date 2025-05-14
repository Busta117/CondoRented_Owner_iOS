//
//  TransactionSummaryListViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 14/05/24.
//

import Foundation
import SwiftUI

import Combine

@MainActor
@Observable
class TransactionSummaryListViewModel {
    
    struct Output {
        var addNew: () -> Void
        var monthDetail: ([Transaction]) -> Void
        var backDidSelect: (() -> Void)?
        
        init(addNew: @escaping () -> Void, monthDetail: @escaping ([Transaction]) -> Void, backDidSelect: (() -> Void)? = nil) {
            self.addNew = addNew
            self.monthDetail = monthDetail
            self.backDidSelect = backDidSelect
        }
    }
    
    enum Input {
        case onAppear
        case addNewTapped
        case monthDetailTapped([Transaction])
        case backDidSelect
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var selectedListing: Listing? {
        dataSource.listingDataSource.listings.first(where: { $0.id == selectedListingId })
    }
    
    var output: Output
    
    var isLoading = false
    var allAdminFees: [AdminFee] = []
    private var allTransactions: [Transaction] = []
    var transactionPerMonth: [[Transaction]] = []
    var selectedListingId: String?
    
    var summarySelectedTab = 0
    
    init(dataSource: AppDataSourceProtocol, selectedListingId: String? = nil, output: Output) {
        self.dataSource = dataSource
        self.output = output
        self.selectedListingId = selectedListingId
        registerListeners()
        fetchInitialData()
    }
    
    func input(_ input: Input) {
        switch input {
        case .onAppear:
            // Ya no hace falta volver a fetch si ya te suscribiste
            break
        case .addNewTapped:
            output.addNew()
        case .monthDetailTapped(let transactions):
            output.monthDetail(transactions)
        case .backDidSelect:
            output.backDidSelect?()
        }
    }
    
    private func fetchInitialData() {
        isLoading = true
        Task {
            await dataSource.transactionDataSource.fetchTransactions()
            await dataSource.adminFeeDataSource.fetchAll()
            isLoading = false
        }
    }
    
    private func registerListeners() {
        // Observa transacciones
        dataSource.transactionDataSource.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                guard let self = self else { return }
                
                if let selectedListingId = self.selectedListingId {
                    self.allTransactions = transactions.filter { $0.listingId == selectedListingId }
                } else {
                    self.allTransactions = transactions
                }
                
                self.transactionPerMonth = TransactionHelper().splitByMonths(transactions: self.allTransactions)
            }
            .store(in: &cancellables)
        
        // Observa admin fees
        dataSource.adminFeeDataSource.adminFeesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fees in
                self?.allAdminFees = fees
            }
            .store(in: &cancellables)
    }
    
    // MARK: - global summary methods
    
    func gloabalBalance(monthsAgo: Int) -> Double {
        var incomeValue: Double = 0
        var expenseValue: Double = 0
        var feesValue: Double = 0
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthsAgoDate = calendar.date(byAdding: .month, value: -monthsAgo, to: now),
              let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: monthsAgoDate)) else {
            return 0
        }
        
        let transactions = transactionPerMonth.filter { items in
            guard let item = items.first else { return false }
            return item.date >= startDate && item.date <= now
        }
        
        let transactionsFixed = transactions.flatMap({$0})
        
        (incomeValue, _) = TransactionHelper.getExpectingValue(for: transactionsFixed)
        (expenseValue, _) = TransactionHelper.getExpensesValue(for: transactionsFixed)
        
        return incomeValue - expenseValue
    }
}
