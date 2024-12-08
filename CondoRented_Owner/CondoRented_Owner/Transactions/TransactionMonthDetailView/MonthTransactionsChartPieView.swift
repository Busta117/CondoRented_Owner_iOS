//
//  MonthTransactionsChartPieView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 28/05/24.
//

import SwiftUI
import Charts

struct MonthTransactionsChartPieView: View {
    
    private var transactions: [Transaction] = []
    private var chartData: [ChartDataSource]
    private var adminFees: [AdminFee]
    
    init(transactions: [Transaction], adminFees: [AdminFee]) {
        self.transactions = transactions
        self.adminFees = adminFees
        
        var tmp: [ChartDataSource] = [.init(transactionType: .expenses, value: 0),
                                      .init(transactionType: .incomes, value: 0)]
        
        for transaction in transactions {
            switch transaction.type {
            case .income:
                tmp[1].value += transaction.amountMicros
            case .expense:
                tmp[0].value += transaction.amountMicros
            }
        }
        let fees: (Double, Currency) = TransactionHelper.getFeesToPayValue(for: transactions, includesExpenses: false, adminFees: adminFees)
        if fees.0 > 0 {
            tmp.append(ChartDataSource(transactionType: .fees, value: (fees.0 / fees.1.microMultiplier)))
        }
        chartData = tmp
    }
    
    var body: some View {
        Chart(chartData) { product in
            SectorMark(
                angle: .value(
                    Text(verbatim: product.title),
                    product.value
                )
            )
            .foregroundStyle(
                by: .value(
                    Text(verbatim: product.title),
                    product.title
                )
            )
        }
        .scaledToFit()
        .chartLegend(position: .bottom, alignment: .center)
    }
}

private class ChartDataSource: Identifiable {
    enum TransactionType: String {
        case expenses
        case incomes
        case fees
    }
    let id = UUID()
    let transactionType: TransactionType
    var value: Double = 0
    var title: String {
        transactionType.rawValue
    }
    init(transactionType: TransactionType, value: Double) {
        self.transactionType = transactionType
        self.value = value
    }
    
}

#Preview {
    return MonthTransactionsChartPieView(transactions: [], adminFees: [])
}
