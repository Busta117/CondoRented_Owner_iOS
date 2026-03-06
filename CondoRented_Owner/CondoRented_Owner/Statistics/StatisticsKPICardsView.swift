import SwiftUI

struct StatisticsKPICardsView: View {

    let balance: Double
    let roi: Double
    let vsPrevious: Double?
    let annualizedROI: Double?
    let currency: Currency
    let hasPersonalUse: Bool
    let balanceWithoutPersonalUse: Double

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                balanceCard
                roiCard
                vsPreviousCard
            }
            if let annualizedROI {
                roiAnnualCard(annualizedROI)
            }
        }
    }

    // MARK: - Cards

    private var balanceCard: some View {
        cardContainer {
            Text("Balance")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(compactCurrency(balance))
                .font(.caption)
                .bold()
                .foregroundStyle(balance >= 0 ? .green : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if hasPersonalUse {
                Text("Sin uso: \(compactCurrency(balanceWithoutPersonalUse))")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }

    private var roiCard: some View {
        cardContainer {
            Text("Margin")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(String(format: "%.1f%%", roi))
                .font(.caption)
                .bold()
                .foregroundStyle(roi >= 0 ? .green : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var vsPreviousCard: some View {
        cardContainer {
            Text("vs Prev")
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let vsPrevious {
                HStack(spacing: 2) {
                    Text(vsPrevious >= 0 ? "\u{25B2}" : "\u{25BC}")
                    Text(String(format: "%.1f%%", abs(vsPrevious)))
                }
                .font(.caption)
                .bold()
                .foregroundStyle(vsPrevious >= 0 ? .green : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            } else {
                Text("N/A")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func roiAnnualCard(_ roi: Double) -> some View {
        cardContainer {
            Text("ROI (12m)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(String(format: "%.1f%%", roi))
                .font(.caption)
                .bold()
                .foregroundStyle(roi >= 0 ? .green : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Annualized over property value")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    // MARK: - Helpers

    private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 3) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
