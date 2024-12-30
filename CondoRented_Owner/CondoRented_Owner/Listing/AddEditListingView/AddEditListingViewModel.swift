//
//  AddEditListingViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 25/10/24.
//

import Foundation

@Observable
final class AddEditListingViewModel {
    
    enum Output {
        case backDidSelect
        case addNewAdminFeeDidSelect
        case editAdminFeeDidSelect(AdminFee)
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    var output: (Output) -> Void
    
    var listing: Listing
    var adminFees: [AdminFee] = []
    var admins: [Admin] = []
    
    init (dataSource: AppDataSourceProtocol, listing: Listing, output: @escaping (Output) -> Void) {
        self.listing = listing
        self.dataSource = dataSource
        self.output = output
    }
    
    func admin(forId id: String) -> Admin? {
        let admin = admins.first(where: { $0.id == id })
        print(admin?.name ?? "No admin found \(id)")
        return admin
    }
    
    func onAppear() {
        fetchData()
    }
    
    private func fetchData() {
        Task {
            self.admins = await dataSource.adminDataSource.fetchAll()
            self.adminFees = await dataSource.adminFeeDataSource.fetch(forListingId: listing.id).sorted(by: { $0.dateStart > $1.dateStart })
        }
    }
}
