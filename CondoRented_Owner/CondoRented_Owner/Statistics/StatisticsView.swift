import SwiftUI

struct StatisticsView: View {
    @Bindable var viewModel: StatisticsViewModel

    private var selectedListingIdBinding: Binding<String> {
        Binding<String>(
            get: { viewModel.selectedListingId ?? "__all__" },
            set: { viewModel.selectedListingId = $0 == "__all__" ? nil : $0 }
        )
    }

    private var granularityBinding: Binding<StatisticsGranularity> {
        Binding<StatisticsGranularity>(
            get: { viewModel.granularity },
            set: { viewModel.input(.granularityChanged($0)) }
        )
    }

    var body: some View {
        List {
            // MARK: - Filters Section
            Section {
                Picker("Listing", selection: selectedListingIdBinding) {
                    Text("All Listings").tag("__all__")
                    ForEach(viewModel.allListings) { listing in
                        Text(listing.title).tag(listing.id)
                    }
                }

                Picker("Period", selection: granularityBinding) {
                    ForEach(StatisticsGranularity.allCases) { granularity in
                        Text(granularity.rawValue).tag(granularity)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Button {
                        viewModel.input(.periodBackward)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(viewModel.periodTitle)
                        .font(.headline)

                    Spacer()

                    Button {
                        viewModel.input(.periodForward)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                }
            }

            // MARK: - KPI Section
            Section {
                StatisticsKPICardsView(
                    balance: viewModel.currentBalance,
                    roi: viewModel.netMarginPercent,
                    vsPrevious: viewModel.vsPreviousPeriodPercent,
                    annualizedROI: viewModel.annualizedROI,
                    currency: viewModel.currency,
                    hasPersonalUse: viewModel.hasPersonalUse,
                    balanceWithoutPersonalUse: viewModel.balanceWithoutPersonalUse
                )
            }

            // MARK: - Personal Use Section
            if viewModel.hasPersonalUse {
                Section {
                    StatisticsPersonalUseView(
                        entries: viewModel.personalUseEntries,
                        totalImpact: viewModel.personalUseTotalImpact,
                        currency: viewModel.currency
                    )
                }
            }

            // MARK: - Bar Chart Section
            Section {
                StatisticsChartBarView(data: viewModel.barChartData)
            }

            // MARK: - Pie Chart Section
            Section {
                StatisticsPieChartView(data: viewModel.pieChartData)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Statistics")
    }
}
