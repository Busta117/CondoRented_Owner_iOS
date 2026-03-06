import SwiftUI
import Charts

struct StatisticsPieChartView: View {
    let data: [StatisticsViewModel.PieChartEntry]

    var body: some View {
        VStack {
            Text("Expense Distribution")
                .font(.headline)

            if data.isEmpty {
                Text("No expense data available.")
            } else {
                Chart(data) { entry in
                    SectorMark(
                        angle: .value(entry.label, entry.value)
                    )
                    .foregroundStyle(entry.color)
                }
                .chartLegend(position: .bottom, alignment: .center)
                .scaledToFit()
                .frame(height: 200)
                .frame(maxWidth: .infinity, alignment: .center)

                VStack {
                    ForEach(data) { entry in
                        HStack {
                            Circle()
                                .fill(entry.color)
                                .frame(width: 10, height: 10)

                            Text(entry.label)
                                .font(.caption)

                            Spacer()

                            Text(compactCurrency(entry.value))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
}
