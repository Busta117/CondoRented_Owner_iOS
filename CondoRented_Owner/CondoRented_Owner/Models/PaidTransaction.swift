//
//  PaidTransaction.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class PaidTransaction: Transaction {

    // Transaction variables
    @Attribute(.unique) var id: String
    var amountFormatted: String
    var amountMicros: Double
    var currency: Currency
    var listingId: String
    var date: Date
    
    var paidAmountFormatted: String
    var paidAmountCurrency: Currency
    var transactionStatus: String
    
    init(id: String, 
         amountFormatted: String,
         amountMicros: Double,
         currency: Currency,
         listingId: String,
         date: Date,
         paidAmountFormatted: String,
         paidAmountCurrency: Currency,
         transactionStatus: String) {
        
        self.id = id
        self.amountFormatted = amountFormatted
        self.amountMicros = amountMicros
        self.currency = currency
        self.listingId = listingId
        self.date = date
        self.paidAmountFormatted = paidAmountFormatted
        self.paidAmountCurrency = paidAmountCurrency
        self.transactionStatus = transactionStatus
    }
    
}

