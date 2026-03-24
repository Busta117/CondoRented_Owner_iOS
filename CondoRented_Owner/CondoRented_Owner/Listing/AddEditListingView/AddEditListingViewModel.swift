//
//  AddEditListingViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 25/10/24.
//

import Foundation
import UIKit
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
    @ObservationIgnored
    private var saveCancellable: AnyCancellable?
    @ObservationIgnored
    private let saveSubject = PassthroughSubject<Void, Never>()

    var listing: Listing
    var adminFees: [AdminFee] = []
    var admins: [Admin] = []
    var allListings: [Listing] = []
    var allTransactions: [Transaction] = []
    var showExpensePicker = false
    var showDriveFolderPicker = false

    init(dataSource: AppDataSourceProtocol, listing: Listing, output: @escaping (Output) -> Void) {
        self.listing = listing.copy()
        self.dataSource = dataSource
        self.output = output

        saveCancellable = saveSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.performSave()
            }

        registerListeners()
        fetchInitialData()
    }

    func onAppear() {}

    func triggerSave() {
        saveSubject.send()
    }

    func saveImmediately() {
        performSave()
    }

    func addExpenseType(_ type: String) {
        guard !listing.expectedMonthlyExpenseTypes.contains(type) else { return }
        listing.expectedMonthlyExpenseTypes.append(type)
        triggerSave()
    }

    func removeExpenseType(_ type: String) {
        listing.expectedMonthlyExpenseTypes.removeAll { $0 == type }
        triggerSave()
    }

    var availableExpenseTypesForPicker: [(type: String, count: Int)] {
        // Collect expense titles from all transactions
        var counts: [String: Int] = [:]
        for transaction in allTransactions {
            if case .expense(let title) = transaction.type, !title.isEmpty, title != "Other" {
                counts[title, default: 0] += 1
            }
        }

        // Remove already selected
        let selected = Set(listing.expectedMonthlyExpenseTypes)
        let filtered = counts.filter { !selected.contains($0.key) }

        // Sort alphabetically first, then by frequency (most repeated on top)
        return filtered
            .sorted { lhs, rhs in
                if lhs.value != rhs.value { return lhs.value > rhs.value }
                return lhs.key < rhs.key
            }
            .map { (type: $0.key, count: $0.value) }
    }

    func selectDriveFolder() {
        if GoogleAuthManager.shared.isSignedIn {
            showDriveFolderPicker = true
        } else {
            Task { @MainActor in
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else { return }
                do {
                    try await GoogleAuthManager.shared.signIn(presenting: rootVC)
                    showDriveFolderPicker = true
                } catch {
                    // Sign-in cancelled or failed
                }
            }
        }
    }

    func admin(forId id: String) -> Admin? {
        admins.first(where: { $0.id == id })
    }

    private func performSave() {
        Task {
            await dataSource.listingDataSource.save(listing)
        }
    }

    private func fetchInitialData() {
        Task {
            await dataSource.adminDataSource.fetchAll()
            await dataSource.adminFeeDataSource.fetchAll()
            await dataSource.listingDataSource.fetchListings()
            await dataSource.transactionDataSource.fetchTransactions()
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

        dataSource.listingDataSource.listingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                self?.allListings = listings
            }
            .store(in: &cancellables)

        dataSource.transactionDataSource.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.allTransactions = transactions
            }
            .store(in: &cancellables)
    }
}
