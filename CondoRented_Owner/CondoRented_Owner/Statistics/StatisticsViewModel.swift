//
//  StatisticsViewModel.swift
//  CondoRented_Owner
//
//  Created on 2026-03-06.
//

import Foundation
import SwiftUI
import Combine

// MARK: - StatisticsGranularity

enum StatisticsGranularity: String, CaseIterable, Identifiable {
    case month
    case quarter
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .month: return "Month"
        case .quarter: return "Quarter"
        case .year: return "Year"
        }
    }

    var monthsCount: Int {
        switch self {
        case .month: return 1
        case .quarter: return 3
        case .year: return 12
        }
    }
}

// MARK: - StatisticsViewModel

@MainActor
@Observable
class StatisticsViewModel {

    // MARK: - Nested Types

    enum Input {
        case listingChanged(String?)
        case granularityChanged(StatisticsGranularity)
        case periodForward
        case periodBackward
    }

    struct BarChartEntry: Identifiable {
        let id = UUID()
        let label: String
        let sortDate: Date
        let income: Double
        let expenses: Double
        let fees: Double
        let hasPersonalUse: Bool
    }

    struct PieChartEntry: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let color: Color
    }

    struct PersonalUseEntry: Identifiable {
        let id = UUID()
        let listingTitle: String
        let balanceWithPersonalUse: Double
        let balanceWithoutPersonalUse: Double
    }

    // MARK: - Filter State

    var selectedListingId: String?
    var granularity: StatisticsGranularity = .month
    var referenceDate: Date = Date()

    // MARK: - Data from Publishers

    var allListings: [Listing] = []
    var allAdminFees: [AdminFee] = []
    private var allTransactions: [Transaction] = []

    // MARK: - Loading

    var isLoading = false

    // MARK: - Private

    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(dataSource: AppDataSourceProtocol) {
        self.dataSource = dataSource
        registerListeners()
        fetchInitialData()
    }

    // MARK: - Input Handling

    func input(_ input: Input) {
        switch input {
        case .listingChanged(let listingId):
            selectedListingId = listingId
        case .granularityChanged(let newGranularity):
            granularity = newGranularity
        case .periodForward:
            referenceDate = Calendar.current.date(
                byAdding: .month,
                value: granularity.monthsCount,
                to: referenceDate
            ) ?? referenceDate
        case .periodBackward:
            referenceDate = Calendar.current.date(
                byAdding: .month,
                value: -granularity.monthsCount,
                to: referenceDate
            ) ?? referenceDate
        }
    }

    // MARK: - Period Calculations

    var periodStart: Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: referenceDate)
        let firstOfMonth = calendar.date(from: comps) ?? referenceDate

        switch granularity {
        case .month:
            return firstOfMonth
        case .quarter:
            let month = comps.month ?? 1
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            var quarterComps = DateComponents()
            quarterComps.year = comps.year
            quarterComps.month = quarterStartMonth
            quarterComps.day = 1
            return calendar.date(from: quarterComps) ?? firstOfMonth
        case .year:
            var yearComps = DateComponents()
            yearComps.year = comps.year
            yearComps.month = 1
            yearComps.day = 1
            return calendar.date(from: yearComps) ?? firstOfMonth
        }
    }

    var periodEnd: Date {
        let calendar = Calendar.current
        guard let end = calendar.date(byAdding: .month, value: granularity.monthsCount, to: periodStart),
              let lastMoment = calendar.date(byAdding: .second, value: -1, to: end) else {
            return periodStart
        }
        return lastMoment
    }

    var previousPeriodStart: Date {
        Calendar.current.date(
            byAdding: .month,
            value: -granularity.monthsCount,
            to: periodStart
        ) ?? periodStart
    }

    var periodTitle: String {
        let formatter = DateFormatter()
        switch granularity {
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: periodStart)
        case .quarter:
            let calendar = Calendar.current
            let month = calendar.component(.month, from: periodStart)
            let quarterNumber = ((month - 1) / 3) + 1
            let year = calendar.component(.year, from: periodStart)
            return "Q\(quarterNumber) \(year)"
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: periodStart)
        }
    }

    // MARK: - Filtered Transactions

    var filteredTransactions: [Transaction] {
        allTransactions.filter { transaction in
            let inPeriod = transaction.date >= periodStart && transaction.date <= periodEnd
            if let listingId = selectedListingId {
                return inPeriod && transaction.listingId == listingId
            }
            return inPeriod
        }
    }

    var previousPeriodTransactions: [Transaction] {
        let previousEnd = Calendar.current.date(
            byAdding: .second,
            value: -1,
            to: periodStart
        ) ?? periodStart

        return allTransactions.filter { transaction in
            let inPeriod = transaction.date >= previousPeriodStart && transaction.date <= previousEnd
            if let listingId = selectedListingId {
                return inPeriod && transaction.listingId == listingId
            }
            return inPeriod
        }
    }

    // MARK: - KPI Calculations

    var currency: Currency {
        filteredTransactions.first?.currency ?? Currency.all.first ?? Currency(id: "COP")
    }

    var currentIncome: Double {
        let (value, _) = TransactionHelper.getExpectingValue(for: filteredTransactions)
        return value
    }

    var currentExpenses: Double {
        let (value, _) = TransactionHelper.getExpensesValue(for: filteredTransactions)
        return value
    }

    var currentFees: Double {
        let (value, _) = TransactionHelper.getFeesToPayValue(for: filteredTransactions, adminFees: allAdminFees)
        return value
    }

    var currentBalance: Double {
        currentIncome - currentExpenses - currentFees
    }

    var previousBalance: Double {
        let (income, _) = TransactionHelper.getExpectingValue(for: previousPeriodTransactions)
        let (expenses, _) = TransactionHelper.getExpensesValue(for: previousPeriodTransactions)
        let (fees, _) = TransactionHelper.getFeesToPayValue(for: previousPeriodTransactions, adminFees: allAdminFees)
        return income - expenses - fees
    }

    var netMarginPercent: Double {
        guard currentIncome > 0 else { return 0 }
        return (currentBalance / currentIncome) * 100
    }

    var vsPreviousPeriodPercent: Double {
        guard previousBalance != 0 else { return 0 }
        return ((currentBalance - previousBalance) / abs(previousBalance)) * 100
    }

    // MARK: - ROI (annualized, based on property value)

    var annualizedROI: Double? {
        let totalPropertyValue: Double
        if let listingId = selectedListingId {
            guard let listing = allListings.first(where: { $0.id == listingId }),
                  let value = listing.propertyValue, value > 0 else { return nil }
            totalPropertyValue = value
        } else {
            let values = allListings.compactMap { $0.propertyValue }
            guard !values.isEmpty else { return nil }
            totalPropertyValue = values.reduce(0, +)
        }

        let cal = Calendar.current
        let endDate = periodEnd
        guard let twelveMonthsAgo = cal.date(byAdding: .month, value: -12, to: periodEnd),
              let startDate = cal.date(from: cal.dateComponents([.year, .month], from: twelveMonthsAgo)) else {
            return nil
        }

        var last12 = allTransactions.filter { $0.date >= startDate && $0.date <= endDate }
        if let listingId = selectedListingId {
            last12 = last12.filter { $0.listingId == listingId }
        }

        let (income, _) = TransactionHelper.getExpectingValue(for: last12)
        let (expenses, _) = TransactionHelper.getExpensesValue(for: last12)
        let (fees, _) = TransactionHelper.getFeesToPayValue(for: last12, adminFees: allAdminFees)
        let annualProfit = income - expenses - fees

        return (annualProfit / totalPropertyValue) * 100
    }

    // MARK: - Bar Chart Data

    var barChartData: [BarChartEntry] {
        let calendar = Calendar.current

        switch granularity {
        case .month:
            // Group by listing
            let byListing = TransactionHelper.splitByListing(
                transactions: filteredTransactions,
                listings: allListings
            )
            return byListing.map { (listing, transactions) in
                let (income, _) = TransactionHelper.getExpectingValue(for: transactions)
                let (expenses, _) = TransactionHelper.getExpensesValue(for: transactions)
                let (fees, _) = TransactionHelper.getFeesToPayValue(for: transactions, adminFees: allAdminFees)
                let hasPersonal = TransactionHelper.hasPersonalUse(in: transactions)
                return BarChartEntry(
                    label: listing.title,
                    sortDate: transactions.first?.date ?? .now,
                    income: income,
                    expenses: expenses,
                    fees: fees,
                    hasPersonalUse: hasPersonal
                )
            }.sorted { $0.label < $1.label }

        case .quarter, .year:
            // Group by month
            let grouped = Dictionary(grouping: filteredTransactions) { transaction -> DateComponents in
                calendar.dateComponents([.year, .month], from: transaction.date)
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"

            return grouped.map { (comps, transactions) in
                let date = calendar.date(from: comps) ?? Date()
                let (income, _) = TransactionHelper.getExpectingValue(for: transactions)
                let (expenses, _) = TransactionHelper.getExpensesValue(for: transactions)
                let (fees, _) = TransactionHelper.getFeesToPayValue(for: transactions, adminFees: allAdminFees)
                let hasPersonal = TransactionHelper.hasPersonalUse(in: transactions)
                return BarChartEntry(
                    label: formatter.string(from: date),
                    sortDate: date,
                    income: income,
                    expenses: expenses,
                    fees: fees,
                    hasPersonalUse: hasPersonal
                )
            }.sorted { $0.sortDate < $1.sortDate }
        }
    }

    // MARK: - Pie Chart Data

    var pieChartData: [PieChartEntry] {
        let expenseTransactions = filteredTransactions.filter {
            switch $0.type {
            case .expense: return true
            default: return false
            }
        }

        let grouped = Dictionary(grouping: expenseTransactions) { $0.type.title }

        let colors: [Color] = [.red, .orange, .yellow, .purple, .pink, .brown, .cyan, .mint, .indigo, .teal]

        return grouped.enumerated().map { (index, element) in
            let (label, transactions) = element
            let (value, _) = TransactionHelper.getExpensesValue(for: transactions)
            let color = colors[index % colors.count]
            return PieChartEntry(label: label, value: value, color: color)
        }.sorted { $0.value > $1.value }
    }

    // MARK: - Personal Use

    var hasPersonalUse: Bool {
        TransactionHelper.hasPersonalUse(in: filteredTransactions)
    }

    var personalUseEntries: [PersonalUseEntry] {
        let personalUseListingIds = Set(
            filteredTransactions
                .filter { $0.type == .personalUse }
                .map { $0.listingId }
        )

        guard !personalUseListingIds.isEmpty else { return [] }

        return personalUseListingIds.compactMap { listingId in
            guard let listing = allListings.first(where: { $0.id == listingId }) else { return nil }

            let listingTransactions = filteredTransactions.filter { $0.listingId == listingId }
            let nonPersonalUseTransactions = listingTransactions.filter { $0.type != .personalUse }

            let (income, _) = TransactionHelper.getExpectingValue(for: listingTransactions)
            let (expenses, _) = TransactionHelper.getExpensesValue(for: listingTransactions)
            let (fees, _) = TransactionHelper.getFeesToPayValue(for: listingTransactions, adminFees: allAdminFees)
            let balanceWith = income - expenses - fees

            let (incomeWithout, _) = TransactionHelper.getExpectingValue(for: nonPersonalUseTransactions)
            let (expensesWithout, _) = TransactionHelper.getExpensesValue(for: nonPersonalUseTransactions)
            let (feesWithout, _) = TransactionHelper.getFeesToPayValue(for: nonPersonalUseTransactions, adminFees: allAdminFees)
            let balanceWithout = incomeWithout - expensesWithout - feesWithout

            return PersonalUseEntry(
                listingTitle: listing.title,
                balanceWithPersonalUse: balanceWith,
                balanceWithoutPersonalUse: balanceWithout
            )
        }.sorted { $0.listingTitle < $1.listingTitle }
    }

    var personalUseTotalImpact: Double {
        let (adjustment, _) = TransactionHelper.getPersonalUseAdjustment(
            for: filteredTransactions,
            adminFees: allAdminFees
        )
        return adjustment
    }

    var balanceWithoutPersonalUse: Double {
        let nonPersonalUseTransactions = filteredTransactions.filter { $0.type != .personalUse }
        let (income, _) = TransactionHelper.getExpectingValue(for: nonPersonalUseTransactions)
        let (expenses, _) = TransactionHelper.getExpensesValue(for: nonPersonalUseTransactions)
        let (fees, _) = TransactionHelper.getFeesToPayValue(for: nonPersonalUseTransactions, adminFees: allAdminFees)
        return income - expenses - fees
    }

    // MARK: - Data Loading

    private func fetchInitialData() {
        isLoading = true
        Task {
            await dataSource.transactionDataSource.fetchTransactions()
            await dataSource.listingDataSource.fetchListings()
            await dataSource.adminFeeDataSource.fetchAll()
            isLoading = false
        }
    }

    private func registerListeners() {
        dataSource.transactionDataSource.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.allTransactions = transactions
            }
            .store(in: &cancellables)

        dataSource.listingDataSource.listingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                self?.allListings = listings
            }
            .store(in: &cancellables)

        dataSource.adminFeeDataSource.adminFeesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fees in
                self?.allAdminFees = fees
            }
            .store(in: &cancellables)
    }
}
