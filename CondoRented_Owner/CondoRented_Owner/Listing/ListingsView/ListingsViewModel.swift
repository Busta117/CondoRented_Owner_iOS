//
//  ListingsViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 25/10/24.
//

import Foundation

@Observable
final class ListingsViewModel {
    
    enum Output {
        case detail(listing: Listing)
    }
    
    @ObservationIgnored
    let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    var output: (Output)->()
    
    var listingList: [Listing] = []
    
    init (dataSource: AppDataSource, output: @escaping (Output)->()) {
        self.dataSource = dataSource
        self.output = output
        fetchData()
    }
    
    private func fetchData() {
        Task {
            self.listingList = await dataSource.listingDataSource.fetchListings()
        }
    }
}
