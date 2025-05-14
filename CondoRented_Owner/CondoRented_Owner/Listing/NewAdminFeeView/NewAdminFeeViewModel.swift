//
//  NewAdminFeeViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 28/12/24.
//

import Foundation
import Combine

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
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
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
        
        registerListeners()
        fetchInitialAdmins()
    }
    
    private func fetchInitialAdmins() {
        Task {
            await dataSource.adminDataSource.fetchAll()
        }
    }
    
    private func registerListeners() {
        dataSource.adminDataSource.adminsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] admins in
                guard let self = self else { return }
                self.admins = admins
                if self.selectedAdmin == nil,
                   let current = admins.first(where: { $0.id == self.adminFee.adminId }) {
                    self.selectedAdmin = current
                }
            }
            .store(in: &cancellables)
    }
    
    func save() {
        guard let selectedAdmin = selectedAdmin else { return }

        if !isEditing {
            listing.adminFeeIds.append(adminFee.id)
        }
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
            // Ya no necesitas volver a llamar a fetchData(); el listener lo hará por ti
        }
    }
}
