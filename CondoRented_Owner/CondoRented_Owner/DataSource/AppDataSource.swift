//
//  AppDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 16/05/24.
//

import Foundation
import SwiftUI
import Combine

protocol AppDataSourceProtocol {
    var transactionDataSource: TransactionDataSourceProtocol { get }
    var listingDataSource: ListingDataSourceProtocol { get }
    var adminDataSource: AdminDataSourceProtocol { get }
    var adminFeeDataSource: AdminFeeDataSourceProtocol { get }
}

final class AppDataSource: AppDataSourceProtocol {
    let transactionDataSource: TransactionDataSourceProtocol
    let listingDataSource: ListingDataSourceProtocol
    let adminDataSource: AdminDataSourceProtocol
    let adminFeeDataSource: AdminFeeDataSourceProtocol
    
    init(transactionDataSource: TransactionDataSourceProtocol, 
         listingDataSource: ListingDataSourceProtocol,
         adminDataSource: AdminDataSourceProtocol,
         adminFeeDataSource: AdminFeeDataSourceProtocol) {
        
        self.transactionDataSource = transactionDataSource
        self.listingDataSource = listingDataSource
        self.adminDataSource = adminDataSource
        self.adminFeeDataSource = adminFeeDataSource
    }
    
    static var defaultDataSource: AppDataSource = {
        return AppDataSource(transactionDataSource: TransactionDataSource(),
                             listingDataSource: ListingDataSource(),
                             adminDataSource: AdminDataSource(),
                             adminFeeDataSource: AdminFeeDataSource())
    }()
}
