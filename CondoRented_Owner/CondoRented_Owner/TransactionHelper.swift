//
//  TransactionHelper.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 7/05/24.
//

import UIKit

protocol TransactionHelperProtocol {
    func splitByMonths(transactions: [Transaction]) -> [[Transaction]]
}

struct TransactionHelper: TransactionHelperProtocol {
    func splitByMonths(transactions: [Transaction]) -> [[Transaction]] {
        let dic = Dictionary(grouping: transactions) { transaction -> DateComponents in
            let date = Calendar.current.dateComponents([.year, .month], from: transaction.date)
            return date
        }
        var arr = [[Transaction]]()
        for (_, value) in dic {
            arr.append(value)
        }
        return arr.sorted(by: {$0.first!.date > $1.first!.date}) // oldest first
    }
    
    static func splitByListing(transactions: [Transaction]) -> [Listing: [Transaction]] {
        var ret: [Listing: [Transaction]] = [:]
        for transaction in transactions {
            if ret[transaction.listing] != nil {
                ret[transaction.listing]?.append(transaction)
            } else {
                ret[transaction.listing] = [transaction]
            }
            
        }
        return ret
    }
    
    static func splitByType(transactions: [Transaction]) -> [Transaction.TransactionType: [Transaction]] {
        var ret: [Transaction.TransactionType: [Transaction]] = [:]
        for transaction in transactions {
            if ret[transaction.type] != nil {
                ret[transaction.type]?.append(transaction)
            } else {
                ret[transaction.type] = [transaction]
            }
            
        }
        return ret
    }
    
    static func getExpectingValue(for transactions: [Transaction]) -> (Double, Currency) {
        let micros = getExpectingMicrosValue(for: transactions)
        let currency = transactions.first?.currency ?? Currency.all.first ?? Currency(id: "COP")
        let value = micros * currency.microMultiplier
        return (value, currency)
    }
    
    static func getExpectingMicrosValue(for transactions: [Transaction]) -> Double {
        var sum = 0.0
        
        for transaction in transactions {
            switch transaction.type {
            case .paid:
                sum += transaction.amountMicros
            case .expense, .utilities, .fixedCost:
                () // do nothing
            }
        }
        
        return sum
    }
    
    static func getExpensesValue(for transactions: [Transaction]) -> (Double, Currency) {
        let micros = getExpensesMicrosValue(for: transactions)
        let currency = transactions.first?.currency ?? Currency.all.first ?? Currency(id: "COP")
        let value = micros * currency.microMultiplier
        return (value, currency)
    }
    
    static func getExpensesMicrosValue(for transactions: [Transaction]) -> Double {
        var sum = 0.0
        
        for transaction in transactions {
            switch transaction.type {
            case .expense:
                if let paidByOwner = transaction.expensePaidByOwner, paidByOwner {
                    sum += transaction.amountMicros
                }
            case .utilities, .fixedCost:
                sum += transaction.amountMicros
            case .paid:
                () // do nothing
            }
        }
        
        return sum
    }
    
    static func getFeesToPayValue(for transactions: [Transaction], includesExpenses: Bool = true) -> (Double, Currency) {
        let micros = getFeeToPayMicrosValue(for: transactions, includesExpenses: includesExpenses)
        let currency = transactions.first?.currency ?? Currency.all.first ?? Currency(id: "COP")
        let value = micros * currency.microMultiplier
        return (value, currency)
    }
    
    static func getFeeToPayMicrosValue(for transactions: [Transaction], includesExpenses: Bool) -> Double {
        var sum = 0.0
        
        for transaction in transactions {
            switch transaction.type {
            case .paid:
                if let adminFee = transaction.listing.adminFees?.first(where: { $0.dateFinish == nil }) {
                    let percent = adminFee.percent > 1 ? (adminFee.percent / 100) : adminFee.percent
                    sum += (transaction.amountMicros * percent )
                }
            case .expense:
                if let payedByOwner = transaction.expensePaidByOwner, !payedByOwner, includesExpenses {
                    sum += transaction.amountMicros
                }
            case .fixedCost, .utilities:
                () // do nothing
            }
        }
        
        return sum
    }
}
