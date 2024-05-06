//
//  ExpenseTransaction.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class ExpenseTransaction: Transaction {
    
    // Transaction variables
    @Attribute(.unique) var id: String
    var amountFormatted: String
    var amountMicros: Double
    var currency: Currency
    var listingId: String
    var date: Date
    
    var concept: String
    var paidByOwner: Bool
    
    init(id: String,
         amountFormatted: String,
         amountMicros: Double,
         currency: Currency,
         listingId: String,
         date: Date = .now,
         concept: String = "",
         paidByOwner: Bool = true) {
        
        self.id = id
        self.amountFormatted = amountFormatted
        self.amountMicros = amountMicros
        self.currency = currency
        self.listingId = listingId
        self.date = date
        self.concept = concept
        self.paidByOwner = paidByOwner
    }
}
