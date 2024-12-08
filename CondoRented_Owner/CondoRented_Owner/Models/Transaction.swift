//
//  GenericTransaction.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation

struct Transaction: CodableAndIdentifiable, Hashable {
    private(set) var collectionId = "Transaction"
    
    var id: String
    var amountFormatted: String
    var amountMicros: Double
    var currency: Currency
    var date: Date
    var type: TransactionType
    
    var listingId: String = ""
    
    // when is paid
    var paidAmountFormatted: String?
    var paidAmountCurrency: Currency?
    
    // when is expense
    var expenseConcept: String?
    var expensePaidByOwner: Bool?
    
    init(id: String = UUID().uuidString, amountFormatted: String = "", amountMicros: Double = 0, currency: Currency, listingId: String, date: Date = .now, type: TransactionType, paidAmountFormatted: String? = nil, paidAmountCurrency: Currency? = nil, expenseConcept: String? = nil, expensePaidByOwner: Bool? = nil) {
        self.id = id
        self.amountFormatted = amountFormatted
        self.amountMicros = amountMicros
        self.currency = currency
        self.date = date
        self.type = type
        self.paidAmountFormatted = paidAmountFormatted
        self.paidAmountCurrency = paidAmountCurrency
        self.expenseConcept = expenseConcept
        self.expensePaidByOwner = expensePaidByOwner
        self.listingId = listingId
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case amountFormatted
        case amountMicros
        case currency
        case listingId
        case date
        case type = "typeValue"
        case paidAmountFormatted
        case paidAmountCurrency
        case expenseConcept
        case expensePaidByOwner
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        amountFormatted = try container.decode(String.self, forKey: .amountFormatted)
        amountMicros = try container.decode(Double.self, forKey: .amountMicros)
        currency = try container.decode(Currency.self, forKey: .currency)
        listingId = try container.decode(String.self, forKey: .listingId)
        date = try container.decode(Date.self, forKey: .date)
        paidAmountCurrency = try container.decodeIfPresent(Currency.self, forKey: .paidAmountCurrency)
        paidAmountFormatted = try container.decodeIfPresent(String.self, forKey: .paidAmountFormatted)
        expenseConcept = try container.decodeIfPresent(String.self, forKey: .expenseConcept)
        expensePaidByOwner = try container.decodeIfPresent(Bool.self, forKey: .expensePaidByOwner)
        
        let typeStr = try container.decode(String.self, forKey: .type)
        type = try TransactionType(rawValue: typeStr, concept: expenseConcept)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amountFormatted, forKey: .amountFormatted)
        try container.encode(amountMicros, forKey: .amountMicros)
        try container.encode(currency, forKey: .currency)
        try container.encode(listingId, forKey: .listingId)
        try container.encode(date, forKey: .date)
        try container.encode(type.rawValue, forKey: .type)
        try container.encodeIfPresent(paidAmountCurrency, forKey: .paidAmountCurrency)
        try container.encodeIfPresent(paidAmountFormatted, forKey: .paidAmountFormatted)
        try container.encodeIfPresent(expenseConcept, forKey: .expenseConcept)
        try container.encodeIfPresent(expensePaidByOwner, forKey: .expensePaidByOwner)
    }
}
