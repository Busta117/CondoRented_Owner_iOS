//
//  AddEditListingViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 25/10/24.
//

import Foundation
import Combine

@Observable
final class AddEditListingViewModel {
    
    enum Output {
        case backDidSelect
        case addNewAdminFeeDidSelect
        case editAdminFeeDidSelect(AdminFee)
        case seeTransactionsDidSelect
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    var output: (Output) -> Void
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var listing: Listing
    var adminFees: [AdminFee] = []
    var admins: [Admin] = []
    
    init(dataSource: AppDataSourceProtocol, listing: Listing, output: @escaping (Output) -> Void) {
        self.listing = listing
        self.dataSource = dataSource
        self.output = output

        registerListeners()
        fetchInitialData()
    }
    
    func onAppear() {
        // Ya no necesitas llamar a fetchData manualmente si ya tienes registerListeners()
    }

    func admin(forId id: String) -> Admin? {
        admins.first(where: { $0.id == id })
    }

    private func fetchInitialData() {
        Task {
            await dataSource.adminDataSource.fetchAll()
            await dataSource.adminFeeDataSource.fetchAll() // usamos todos, filtramos localmente
        }
    }

    private func registerListeners() {
        dataSource.adminDataSource.adminsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] admins in
                self?.admins = admins
            }
            .store(in: &cancellables)

        dataSource.adminFeeDataSource.adminFeesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allFees in
                self?.adminFees = allFees
                    .filter { $0.listingId == self?.listing.id }
                    .sorted { $0.dateStart > $1.dateStart }
            }
            .store(in: &cancellables)
    }
}
