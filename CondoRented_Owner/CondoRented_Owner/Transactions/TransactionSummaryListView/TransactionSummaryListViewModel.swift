//
//  TransactionSummaryListViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 14/05/24.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
@Observable
class TransactionSummaryListViewModel {
    
    struct Output {
        var addNew: () -> Void
        var monthDetail: ([Transaction]) -> Void
    }
    
    enum Input {
        case onAppear
        case addNewTapped
        case monthDetailTapped([Transaction])
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var output: Output
    
    var isLoading = false
    var allAdminFees: [AdminFee] = []
    private var allTransactions = [Transaction]()
    var transactionPerMonth = [[Transaction]]()
    
    init(dataSource: AppDataSourceProtocol, output: Output) {
        self.dataSource = dataSource
        self.output = output
        
        registerListeners()
        fetchData()
    }
    
    func input(_ input: Input) {
        switch input {
        case .onAppear:
            fetchData()
        case .addNewTapped:
            output.addNew()
        case .monthDetailTapped(let transactions):
            output.monthDetail(transactions)
        }
    }
    
    private func fetchData(silence: Bool = false) {
        if !silence {
            isLoading = true
        }
        Task {
            self.allTransactions = await dataSource.transactionDataSource.fetchTransactions()
            self.allAdminFees = await dataSource.adminFeeDataSource.fetchAll()
            self.transactionPerMonth = TransactionHelper().splitByMonths(transactions: self.allTransactions)
            self.isLoading = false
        }
        
    }
    
    private func registerListeners() {
        dataSource.transactionDataSource.actionSubject.sink { [weak self] action in
            switch action {
            case .added:
                self?.fetchData(silence: true)
            case .removed:
                self?.fetchData(silence: true)
            case .none:
                ()
            }
        }
        .store(in: &cancellables)
    }
}
