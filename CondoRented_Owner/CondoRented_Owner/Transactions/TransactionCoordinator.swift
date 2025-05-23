//
//  TransactionCoordinator.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 16/05/24.
//

import Foundation
import SwiftUI

enum TransactionPage {
    case summaryList
    case addNewTransaction
    case editTransaction(Transaction)
    case monthDetail([Transaction])
}

@Observable
final class TransactionCoordinator: Hashable {
    
    static func == (lhs: TransactionCoordinator, rhs: TransactionCoordinator) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    struct Output {
        var addNew: () -> Void
        var edit: (Transaction) -> Void
        
    }
    
    @ObservationIgnored
    @Binding var navigationPath: NavigationPath
    
    @ObservationIgnored
    private var id: UUID
    @ObservationIgnored
    private var output: Output?
    @ObservationIgnored
    private var page: TransactionPage
    
    init(
        page: TransactionPage,
        navigationPath: Binding<NavigationPath>,
        output: Output? = nil
    ) {
        self.id = UUID()
        self.page = page
        self.output = output
        self._navigationPath = navigationPath
    }
    
    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self.page {
        case .summaryList:
            summaryList()
        case .addNewTransaction:
            addEditView(transaction: nil)
        case .editTransaction(let transaction):
            addEditView(transaction: transaction)
        case .monthDetail(let transactions):
            monthDetailView(with: transactions)
        }
    }
 
    @MainActor
    private func summaryList() -> some View {
        let dataSource = AppDataSource.defaultDataSource
        let vm = TransactionSummaryListViewModel(dataSource: dataSource,
                                                 output:
                .init(
                    addNew: {
                        self.push(TransactionCoordinator(page: .addNewTransaction, navigationPath: self.$navigationPath))
                    },
                    monthDetail: { transactions in
                        self.push(TransactionCoordinator(page: .monthDetail(transactions), navigationPath: self.$navigationPath))
                    },
                    backDidSelect: {}
                ))
        return TransactionSummaryListView(viewModel: vm)
    }
    
    @MainActor
    private func addEditView(transaction: Transaction?) -> some View {
        let dataSource = AppDataSource.defaultDataSource
        let vm = AddEditTransactionViewModel(transaction: transaction, dataSource: dataSource) { output in
            switch output {
            case .back:
                self.pop()
            }
        }
        return AddEditTransactionView(viewModel: vm)
    }
    
    @MainActor
    private func monthDetailView(with transactions: [Transaction]) -> some View {
        let dataSource = AppDataSource.defaultDataSource
        
        let vm = TransactionMonthDetailViewModel(dataSource: dataSource, transactions: transactions) { output in
            switch output {
            case .addNewTransaction:
                self.push(TransactionCoordinator(page: .addNewTransaction, navigationPath: self.$navigationPath))
            case .editTransaction(let transaction):
                self.push(TransactionCoordinator(page: .editTransaction(transaction), navigationPath: self.$navigationPath))
            }
        }
        return TransactionMonthDetailView(viewModel: vm)
    }
    
    
    func push(_ value: TransactionCoordinator) {
        navigationPath.append(value)
    }
    func pop() {
        navigationPath.removeLast()
    }
}
