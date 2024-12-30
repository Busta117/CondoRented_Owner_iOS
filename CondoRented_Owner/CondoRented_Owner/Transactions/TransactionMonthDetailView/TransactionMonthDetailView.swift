//
//  TransactionMonthDetailView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 23/05/24.
//

import SwiftUI


struct TransactionMonthDetailView: View {
    
    @State var viewModel: TransactionMonthDetailViewModel
    @State private var detailExpanded = false
    @State private var chartExpanded = true
    @State private var adminFeeSummaryExpanded = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var backButton : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 0) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
        }
    }
    
    var body: some View {
        ZStack {
            if !viewModel.isLoading {
                List {
                    statsSection
                    summaryMonthView
                    transactionsListSectionView
                }
                
            } else {
                VStack {
                    ZStack {
                        Color.black.opacity(0.3)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                            .padding()
                    }
                    Spacer()
                }
            }
        }
        .background(.clear)
        .navigationTitle(viewModel.titleMonth)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.input(.addNewTapped)
                }, label: {
                    Label("Add Item", systemImage: "plus")
                })
            }
        }
            
    }
    
    private var summaryMonthView: some View {
        Section(isExpanded: $adminFeeSummaryExpanded) {
            VStack {
                ForEach(viewModel.listings) { listing in
                    VStack {
                        summaryLine(for: listing)
                        ForEach(viewModel.expensesPayedByAdmin(for: listing)) { expense in
                            HStack {
                                Spacer()
                                Text(expense.expenseConcept ?? "")
                                    .font(.body)
                                    .frame(alignment: .leading)
                                
                                Text((expense.amountMicros * expense.currency.microMultiplier), format: .currency(code: expense.currency.id))
                                    .font(.body)
                                    .frame(maxWidth: 100, alignment: .trailing)
                            }
                            .padding(.bottom, 5)
                        }
                    }
                    
                }
                HStack {
                    Spacer()
                    Text("TOTAL:")
                        .font(.headline)
                        .bold()
                    
                    Text(viewModel.totalFeesToPayValue().0, format: .currency(code: viewModel.totalFeesToPayValue().1.id))
                        .font(.headline)
                }
            }
        } header: {
            HStack(spacing: 0) {
                Button {
                    adminFeeSummaryExpanded.toggle()
                } label: {
                    HStack {
                        Text("Admin fee summary")
                        Spacer()
                        Image(systemName: adminFeeSummaryExpanded ? "chevron.up" : "chevron.down")
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

            }
        
            
        }
    }
    
    private func summaryLine(for listing: Listing) -> some View {
        VStack {
            HStack {
                Text(listing.title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text(viewModel.expectingValue(for: listing).0, format: .currency(code: viewModel.expectingValue(for: listing).1.id))
                    .foregroundStyle(.secondary)
                    .font(.body)
            }
            HStack {
                Spacer()
                Text((viewModel.percentFee(for: listing) / 100), format: .percent)
                    .font(.body)
                Text(viewModel.feesToPayValue(for: listing).0, format: .currency(code: viewModel.feesToPayValue(for: listing).1.id))
                    .font(.body)
                    .frame(maxWidth: 100, alignment: .trailing)
            }
        }
    }
    
    private var transactionsListSectionView: some View {
        Section(isExpanded: $detailExpanded) {
            transactionsListView
        } header: {
            HStack(spacing: 0) {
                Button {
                    detailExpanded.toggle()
                } label: {
                    HStack {
                        Text("Month Transactions")
                        Spacer()
                        Image(systemName: detailExpanded ? "chevron.up" : "chevron.down")
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

            }
        }
    }
    
    private var transactionsListView: some View {
        ForEach(viewModel.transactions) { transaction in
            
            Button {
                viewModel.input(.editTransaction(transaction))
            } label: {
                transactionsListElement(for: transaction)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
        }
        .onDelete(perform: { indexSet in
            viewModel.input(.deleteTapped(indexSet))
        })
    }
    
    private func transactionsListElement(for transaction: Transaction) -> some View {
        VStack {
            HStack {
                Text(viewModel.listing(forId: transaction.listingId)?.title ?? "-")
                    .font(.caption)
                    .bold()
                Spacer()
                Text(transaction.date, format: .dateTime.day().month())
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack {
                    Group {
                        
                        switch transaction.type {
                        case .income:
                            Text(transaction.type.title)
                        case .expense:
                            Text("\(transaction.type.title)")
                            if let expensePaidByOwner = transaction.expensePaidByOwner, !expensePaidByOwner {
                                Text("(payed by ADMIN)")
                            }
                        }
                        
                    }
                    .font(.caption2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                Spacer()
                Text(transaction.amountMicros * transaction.currency.microMultiplier, format: .currency(code: transaction.currency.id))
                    .font(.body)
                    .foregroundStyle(transaction.type == .income ? .green : .red)
            }
        }
    }
    
    private var statsSection: some View {
        Section(isExpanded: $chartExpanded) {
            VStack {
                MonthTransactionsChartPieView(transactions: viewModel.transactions, adminFees: viewModel.allAdminFees)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                MonthDetailSummarySectionView(transactions: viewModel.transactions, adminFees: viewModel.allAdminFees)
            }
        } header: {
            HStack(spacing: 0) {
                Button {
                    chartExpanded.toggle()
                } label: {
                    HStack {
                        Text("Stats")
                        Spacer()
                        Image(systemName: chartExpanded ? "chevron.up" : "chevron.down")
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

            }
        }
        
    }
}

struct MonthDetailSummarySectionView: View {
    private var currency: Currency
    
    private var incomeValue: Double
    private var expensesValue: Double
    private var feesValue: Double
    private var balanceValue: Double {
        (incomeValue - expensesValue - feesValue)
    }
    
//    private var expensesByType: [TransactionType: [Transaction]]
    
    init(transactions: [Transaction], adminFees: [AdminFee]) {
        (incomeValue, currency) = TransactionHelper.getExpectingValue(for: transactions)
        (expensesValue, _) = TransactionHelper.getExpensesValue(for: transactions)
        (feesValue, _) = TransactionHelper.getFeesToPayValue(for: transactions, adminFees: adminFees)
        
        let onlyExpenses = transactions.filter({ transaction in
            switch transaction.type {
            case .expense:
                return (transaction.type.isOther ? (transaction.expensePaidByOwner ?? false) : true)
            case .income:
                return false
            }
        })
        
        // TODO: busta fix this
//        expensesByType = TransactionHelper.splitByType(transactions: onlyExpenses)
//        expensesByType = [:]
    }
    
//    private func expenseValue(for type: TransactionType) -> Double {
//        guard let transactions = expensesByType[type] else { return 0 }
//        var retVal: Double = 0
//        for transaction in transactions {
//            retVal += (transaction.amountMicros * transaction.currency.microMultiplier)
//        }
//        return retVal
//    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Incomes")
                    .font(.body)
                Spacer()
                Text(incomeValue, format: .currency(code: currency.id))
                    .font(.body)
            }
            HStack {
                Text("Admin fees")
                    .font(.body)
                Spacer()
                Text(feesValue, format: .currency(code: currency.id))
                    .font(.body)
            }
            HStack {
                Text("Expenses")
                    .font(.body)
                Spacer()
                Text(expensesValue, format: .currency(code: currency.id))
                    .font(.body)
            }
//            VStack(spacing: 0) {
//                ForEach(Array(expensesByType.keys), id: \.self) { expenseType in
//                    HStack {
//                        Spacer()
//                        Text(expenseType.title)
//                        Text(expenseValue(for: expenseType), format: .currency(code: currency.id))
//                    }
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//                }
//            }
            
            HStack {
                Text("Balance")
                    .font(.body)
                Spacer()
                Text(balanceValue, format: .currency(code: currency.id))
                    .font(.body)
                    .foregroundStyle(balanceValue >= 0 ? .green : .red)
            }
            .bold()
            .padding(.top, 2)
        }
    }
}

//#Preview {
//    
//    let c = Currency(id: "COP")
//    let l1 = Listing(title: "Distrio Vera", adminFees: [AdminFee(listing: nil, dateStart: .now, percent: 10)])
//    let l2 = Listing(title: "La Riviere", adminFees: [AdminFee(listing: nil, dateStart: .now, percent: 15)])
//    let t1 = Transaction(amountMicros: 2_000_000_000_000, currency: c, listing: l1, type: .paid)
//    let t2 = Transaction(amountMicros: 500_000_000_000, currency: c, listing: l1, type: .paid)
//    let t3 = Transaction(amountMicros: 70_000_000_000, currency: c, listing: l1, type: .expense, expenseConcept: "aseo", expensePaidByOwner: true)
//    let t4 = Transaction(amountMicros: 700_000_000_000, currency: c, listing: l2, type: .paid)
//    let t5 = Transaction(amountMicros: 75_000_000_000, currency: c, listing: l2, type: .expense, expenseConcept: "aseo2 dsf df", expensePaidByOwner: false)
//    let tras: [Transaction] = [t1,t2,t3, t4, t5]
//    
//    let ds = AppDataSource.defaultDataSource
//    let vm = TransactionMonthDetailViewModel(dataSource: ds, transactions: tras, output: {_ in })
//    TransactionMonthDetailView(viewModel: vm)
//}
