//
//  GenericTransaction.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class Transaction: Identifiable {
    
    enum TransactionType: Codable, CaseIterable, Hashable {
        case paid
        case expense
        case utilities
        case fixedCost
        
        var title: String {
            switch self {
            case .paid:
                return "Income"
            case .expense:
                return "Expense"
            case .utilities:
                return "Utilities"
            case .fixedCost:
                return "Fixed Cost"
            }
        }
    }
    
    @Attribute(.unique) var id: String
    var amountFormatted: String
    var amountMicros: Double
    var currency: Currency
    var listing: Listing
    var date: Date
    var type: TransactionType
    
    // when is paid
    var paidAmountFormatted: String?
    var paidAmountCurrency: Currency?
    
    // when is expense
    var expenseConcept: String?
    var expensePaidByOwner: Bool?
    
    init(id: String = UUID().uuidString, amountFormatted: String = "", amountMicros: Double = 0, currency: Currency, listing: Listing, date: Date = .now, type: TransactionType, paidAmountFormatted: String? = nil, paidAmountCurrency: Currency? = nil, expenseConcept: String? = nil, expensePaidByOwner: Bool? = nil) {
        self.id = id
        self.amountFormatted = amountFormatted
        self.amountMicros = amountMicros
        self.currency = currency
        self.listing = listing
        self.date = date
        self.type = type
        self.paidAmountFormatted = paidAmountFormatted
        self.paidAmountCurrency = paidAmountCurrency
        self.expenseConcept = expenseConcept
        self.expensePaidByOwner = expensePaidByOwner
    }
}
