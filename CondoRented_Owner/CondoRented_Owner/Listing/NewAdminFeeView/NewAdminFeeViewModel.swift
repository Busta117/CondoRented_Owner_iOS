//
//  NewAdminFeeViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 28/12/24.
//

import Foundation

@Observable
final class NewAdminFeeViewModel {
    
    enum Output {
        case backDidSelect
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    var output: (Output) -> Void
    @ObservationIgnored
    private(set) var isEditing: Bool = false
    
    private(set) var listing: Listing
    private(set) var admins: [Admin] = []
    var adminFee: AdminFee
    var selectedAdmin: Admin? = nil
    var endDate: Date = .now
    
    var saveButtonDisabled: Bool {
        selectedAdmin == nil
    }
    
    init(dataSource: AppDataSourceProtocol,
         listing: Listing,
         adminFee: AdminFee?,
         output: @escaping (Output) -> Void) {
        
        self.dataSource = dataSource
        self.listing = listing
        self.isEditing = adminFee != nil
        self.adminFee = adminFee ?? AdminFee(listingId: listing.id ,dateStart: .now, percent: 15)
        self.output = output
        
        fetchData()
    }
    
    private func fetchData() {
        Task {
            self.admins = await dataSource.adminDataSource.fetchAll()
            if let current = self.admins.first(where: { $0.id == self.adminFee.adminId }) {
                self.selectedAdmin = current
            }
            
        }
    }
    
    func save() {
        if !isEditing {
            listing.adminFeeIds.append(adminFee.id)
        }
        guard let selectedAdmin = selectedAdmin else { return }
        adminFee.adminId = selectedAdmin.id
        
        Task {
            await dataSource.listingDataSource.save(listing)
            await dataSource.adminFeeDataSource.save(adminFee)
            await MainActor.run {
                output(.backDidSelect)
            }
        }
    }
    
    func createNewAdmin(name: String) {
        let newAdmin = Admin(name: name, feeIds: [])
        Task {
            await dataSource.adminDataSource.save(newAdmin)
            fetchData()
        }
    }
}
