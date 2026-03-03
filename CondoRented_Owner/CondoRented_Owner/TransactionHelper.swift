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
    
    static func splitByListing(transactions: [Transaction], listings: [Listing]) -> [Listing: [Transaction]] {
        var ret: [Listing: [Transaction]] = [:]
        for transaction in transactions {
            if let listing = listings.first(where: {$0.id == transaction.listingId}) {
                if ret[listing] != nil {
                    
                    ret[listing]?.append(transaction)
                } else {
                    ret[listing] = [transaction]
                }
            }
        }
        return ret
    }
    
    // TODO: busta fix this
    static func splitByType(transactions: [Transaction]) -> [TransactionType: [Transaction]] {
        var ret: [TransactionType: [Transaction]] = [:]
        
        var types = TransactionType.allCases
        
        for transaction in transactions {
            var added = false
            for type in types {
                if transaction.type == type {
                    added = true
                        if ret[transaction.type] != nil {
                            ret[transaction.type]?.append(transaction)
                        } else {
                            ret[transaction.type] = [transaction]
                        }
                        break
                }
            }
            if !added {
                ret[TransactionType.other] = [transaction]
            }
            
            
//            if ret[transaction.type] != nil {
//                ret[transaction.type]?.append(transaction)
//            } else {
//                ret[transaction.type] = [transaction]
//            }
            
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
            case .income:
                sum += transaction.amountMicros
            case .expense, .personalUse:
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
                if let paidByOwner = transaction.expensePaidByOwner, !paidByOwner {
                    () // do nothing
                } else {
                    sum += transaction.amountMicros
                }
            case .income, .personalUse:
                () // do nothing
            }
        }

        return sum
    }
    
    static func getFeesToPayValue(for transactions: [Transaction], includesExpenses: Bool = true, adminFees: [AdminFee]) -> (Double, Currency) {
        let micros = getFeeToPayMicrosValue(for: transactions, includesExpenses: includesExpenses, adminFees: adminFees)
        let currency = transactions.first?.currency ?? Currency.all.first ?? Currency(id: "COP")
        let value = micros * currency.microMultiplier
        return (value, currency)
    }
    
    static func getFeeToPayMicrosValue(for transactions: [Transaction], includesExpenses: Bool, adminFees: [AdminFee]) -> Double {
        var sum = 0.0

        for transaction in transactions {
            switch transaction.type {
            case .income:

                if let adminFee = adminFees.first(where: {
                    $0.listingId == transaction.listingId && transaction.date >= $0.dateStart && transaction.date <= ($0.dateFinish ?? Date())
                }) {
                    let percent = adminFee.percent > 1 ? (adminFee.percent / 100) : adminFee.percent
                    sum += (transaction.amountMicros * percent )
                }
            case .expense:
                if let payedByOwner = transaction.expensePaidByOwner, !payedByOwner, includesExpenses {
                    sum += transaction.amountMicros
                }
            case .personalUse:
                () // do nothing
            }
        }

        return sum
    }

    static func hasPersonalUse(in transactions: [Transaction]) -> Bool {
        transactions.contains { $0.type == .personalUse }
    }

    static func getPersonalUseAdjustment(for transactions: [Transaction], adminFees: [AdminFee]) -> (Double, Currency) {
        let currency = transactions.first?.currency ?? Currency.all.first ?? Currency(id: "COP")
        guard hasPersonalUse(in: transactions) else {
            return (0, currency)
        }

        // Find which listings have personalUse
        let personalUseListingIds = Set(
            transactions.filter { $0.type == .personalUse }.map { $0.listingId }
        )

        // Calculate adjustment per listing that has personalUse
        var totalAdjustment: Double = 0
        for listingId in personalUseListingIds {
            let listingTransactions = transactions.filter { $0.listingId == listingId }
            let (income, _) = getExpectingValue(for: listingTransactions)
            let (expenses, _) = getExpensesValue(for: listingTransactions)
            let (fees, _) = getFeesToPayValue(for: listingTransactions, adminFees: adminFees)
            let deficit = expenses + fees - income
            totalAdjustment += max(0, deficit)
        }

        return (totalAdjustment, currency)
    }
}
