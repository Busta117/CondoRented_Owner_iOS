//
//  AppDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 16/05/24.
//

import Foundation

protocol AppDataSourceProtocol {
    var transactionDataSource: TransactionDataSourceProtocol { get }
    var listingDataSource: ListingDataSourceProtocol { get }
}

final class AppDataSource: AppDataSourceProtocol {
    let transactionDataSource: TransactionDataSourceProtocol
    let listingDataSource: ListingDataSourceProtocol
    
    init(transactionDataSource: TransactionDataSourceProtocol, 
         listingDataSource: ListingDataSourceProtocol) {
        
        self.transactionDataSource = transactionDataSource
        self.listingDataSource = listingDataSource
    }
}
