//
//  TransactionProtocol.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation

protocol Transaction {
    var id: String { get set}
    var amountFormatted: String { get set}
    var amountMicros: Double { get set}
    var currency: Currency { get set}
    var listingId: String { get set}
    var date: Date { get set}
}
