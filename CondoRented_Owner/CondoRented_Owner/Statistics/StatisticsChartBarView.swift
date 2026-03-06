import SwiftUI
import Charts

struct StatisticsChartBarView: View {
    let data: [StatisticsViewModel.BarChartEntry]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Income vs Expenses")
                .font(.headline)

            if data.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(data) { entry in
                        BarMark(
                            x: .value("Label", entry.label),
                            y: .value("Amount", entry.income)
                        )
                        .foregroundStyle(by: .value("Type", "Income"))
                        .position(by: .value("Type", "Income"))
                        .opacity(entry.hasPersonalUse ? 0.4 : 1.0)

                        BarMark(
                            x: .value("Label", entry.label),
                            y: .value("Amount", entry.expenses)
                        )
                        .foregroundStyle(by: .value("Type", "Expenses"))
                        .position(by: .value("Type", "Expenses"))
                        .opacity(entry.hasPersonalUse ? 0.4 : 1.0)
                    }
                }
                .chartXScale(domain: data.map { $0.label })
                .chartForegroundStyleScale(["Income": .green, "Expenses": .red])
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(compactCurrency(doubleValue))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .chartLegend(position: .bottom)
                .frame(height: 220)
            }
        }
    }
}
