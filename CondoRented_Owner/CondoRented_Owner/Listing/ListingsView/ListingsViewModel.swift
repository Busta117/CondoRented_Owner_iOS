//
//  ListingsViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 25/10/24.
//

import Foundation

@Observable
final class ListingsViewModel {
    
    @ObservationIgnored
    let dataSource: AppDataSourceProtocol
    
    var listingList: [Listing] = []
    
    init (dataSource: AppDataSource) {
        self.dataSource = dataSource
        
        fetchData()
    }
    
    private func fetchData() {
        Task {
            self.listingList = await dataSource.listingDataSource.fetchListings()
        }
    }
}
