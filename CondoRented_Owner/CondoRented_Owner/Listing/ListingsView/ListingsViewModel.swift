//
//  ListingsViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 25/10/24.
//

import Foundation
import Combine

@Observable
final class ListingsViewModel {
    
    enum Output {
        case detail(listing: Listing)
    }
    
    @ObservationIgnored
    let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    var output: (Output) -> Void
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var listingList: [Listing] = []
    
    init(dataSource: AppDataSourceProtocol, output: @escaping (Output) -> Void) {
        self.dataSource = dataSource
        self.output = output
        
        registerListeners()
        fetchInitialData()
    }
    
    private func fetchInitialData() {
        Task {
            await dataSource.listingDataSource.fetchListings()
        }
    }
    
    private func registerListeners() {
        dataSource.listingDataSource.listingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                self?.listingList = listings
            }
            .store(in: &cancellables)
    }
    
    func didSelectListing(_ listing: Listing) {
        output(.detail(listing: listing))
    }
}
