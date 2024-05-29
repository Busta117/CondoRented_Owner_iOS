//
//  TransactionSummaryListViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 14/05/24.
//

import Foundation
import SwiftUI
import SwiftData

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
    var output: Output
    
    private var allTransactions = [Transaction]()
    var transactionPerMonth = [[Transaction]]()
    
    init(dataSource: AppDataSourceProtocol, output: Output) {
        self.dataSource = dataSource
        self.output = output
        
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
    
    private func fetchData() {
        allTransactions = dataSource.transactionDataSource.fetchTransactions()
        transactionPerMonth = TransactionHelper().splitByMonths(transactions: allTransactions)
    }
}
