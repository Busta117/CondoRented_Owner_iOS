//
//  AddEditListingViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 25/10/24.
//

import Foundation

@Observable
final class AddEditListingViewModel {
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    
    var listing: Listing
    var adminFees: [AdminFee] = []
    var admins: [Admin] = []
    
    init (dataSource: AppDataSourceProtocol, listing: Listing) {
        self.listing = listing
        self.dataSource = dataSource
        
        fetchData()
    }
    
    func admin(forId id: String) -> Admin? {
        let admin = admins.first(where: { $0.id == id })
        print(admin?.name ?? "No admin found \(id)")
        return admin
    }
    
    private func fetchData() {
        Task {
            self.admins = await dataSource.adminDataSource.fetchAll()
            self.adminFees = await dataSource.adminFeeDataSource.fetch(forListingId: listing.id)
        }
    }
}
