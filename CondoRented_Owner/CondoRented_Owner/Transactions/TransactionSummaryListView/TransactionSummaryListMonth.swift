//
//  TransactionSummaryListMonth.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 6/05/24.
//

import SwiftUI



struct TransactionSummaryListMonth: View {
    
    enum MonthType {
        case current
        case last
        case past
    }
    
    var monthType: MonthType
    var transactions: [Transaction]
    
    var wonValue: Double
    var wonCurrency: Currency
    
    var spendValue: Double
    var spendCurrency: Currency
    
    var feesValue: Double
    var feesCurrency: Currency
    
    var monthBalanceValue: Double {
        (wonValue - spendValue - feesValue)
    }
    
    init(transactions: [Transaction], adminFees: [AdminFee]) {
        self.transactions = transactions
        
        // month type
        if let trans = transactions.first {
            let currentDate = Date.now
            let monthDate = trans.date
            
            var calender = Calendar.current
            calender.timeZone = TimeZone.current
            
            let currentResult = calender.dateComponents([.year, .month], from: currentDate)
            let monthResult = calender.dateComponents([.year, .month], from: monthDate)
            
            if currentResult.month == monthResult.month && currentResult.year == monthResult.year {
                monthType = .current
            } else if currentResult.month == ((monthResult.month ?? 0) - 1) && currentResult.year == monthResult.year {
                monthType = .last
            } else {
                monthType = .past
            }
        } else {
            monthType = .past
        }
        
        (wonValue, wonCurrency) = TransactionHelper.getExpectingValue(for: transactions)
        
        (spendValue, spendCurrency) = TransactionHelper.getExpensesValue(for: transactions)
        
        (feesValue, feesCurrency) = TransactionHelper.getFeesToPayValue(for: transactions, adminFees: adminFees)
    }
    
    private var monthTitle: String {
        if let transaction = transactions.first {
            return transaction.date.formatted(.dateTime.month().year())
        }
        return "-"
    }
    
    private var wonTitle: String {
        switch monthType {
        case .current:
            "You're expecting"
        case .last, .past:
            "You made"
        }
    }
    
    private var spendTitle: String {
        switch monthType {
        case .current:
            "You've spent"
        case .last, .past:
            "You spend"
        }
    }
    
    private var feesTitle: String {
        switch monthType {
        case .current:
            "Approximate admin fees"
        case .last, .past:
            "Paid admin fees"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if monthType == .current {
                Circle()
                    .frame(width: 10)
                    .padding(.bottom, -10)   
                    .foregroundStyle(.green)
            }
            Text(monthTitle)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text(wonTitle)
                    .font(.body)
                Spacer()
                Text(wonValue, format: .currency(code: wonCurrency.id))
                    .font(.body)
                    .bold()
            }
            
            HStack {
                Text(spendTitle)
                    .font(.body)
                Spacer()
                Text(spendValue, format: .currency(code: spendCurrency.id))
                    .font(.body)
                    .bold()
            }
            
            HStack {
                Text(feesTitle)
                    .font(.body)
                Spacer()
                Text(feesValue, format: .currency(code: feesCurrency.id))
                    .font(.body)
                    .bold()
            }
            
            HStack {
                Text("Month balance")
                    .font(.body)
                Spacer()
                Text(monthBalanceValue, format: .currency(code: wonCurrency.id))
                    .font(.body)
                    .bold()
                    .foregroundStyle(monthBalanceValue >= 0 ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    let container = ModelContainer.sharedInMemoryModelContainer
//    let listing = Listing(id: "1", title: "Distrito Vera",adminFees: [AdminFee(listing: nil, dateStart: .now, percent: 10)])
//    
//    let t1 = Transaction(amountMicros: 2000000000000, currency: Currency(id: "COP"), listing: listing, date: .now, type: .paid)
//    let t2 = Transaction(amountMicros: 1000000000000, currency: Currency(id: "COP"), listing: listing, type: .expense)
//    container.mainContext.insert(listing)
//    container.mainContext.insert(t1)
//    container.mainContext.insert(t2)
//    
//    return TransactionSummaryListMonth(transactions: [t1,t2])
//}
