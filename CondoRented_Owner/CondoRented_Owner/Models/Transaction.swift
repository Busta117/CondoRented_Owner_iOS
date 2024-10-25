//
//  GenericTransaction.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class Transaction: CodableAndIdentifiable {
    
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case amountFormatted
        case amountMicros
        case currency
        case listing
        case date
        case type
        case paidAmountFormatted
        case paidAmountCurrency
        case expenseConcept
        case expensePaidByOwner
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        amountFormatted = try container.decode(String.self, forKey: .amountFormatted)
        amountMicros = try container.decode(Double.self, forKey: .amountMicros)
        currency = try container.decode(Currency.self, forKey: .currency)
        listing = try container.decode(Listing.self, forKey: .listing)
        date = try container.decode(Date.self, forKey: .date)
        type = try container.decode(TransactionType.self, forKey: .type)
        paidAmountCurrency = try container.decodeIfPresent(Currency.self, forKey: .paidAmountCurrency)
        paidAmountFormatted = try container.decodeIfPresent(String.self, forKey: .paidAmountFormatted)
        expenseConcept = try container.decodeIfPresent(String.self, forKey: .expenseConcept)
        expensePaidByOwner = try container.decodeIfPresent(Bool.self, forKey: .expensePaidByOwner)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amountFormatted, forKey: .amountFormatted)
        try container.encode(amountMicros, forKey: .amountMicros)
        try container.encode(currency, forKey: .currency)
        try container.encode(listing, forKey: .listing)
        try container.encode(date, forKey: .date)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(paidAmountCurrency, forKey: .paidAmountCurrency)
        try container.encodeIfPresent(paidAmountFormatted, forKey: .paidAmountFormatted)
        try container.encodeIfPresent(expenseConcept, forKey: .expenseConcept)
        try container.encodeIfPresent(expensePaidByOwner, forKey: .expensePaidByOwner)
    }
}
