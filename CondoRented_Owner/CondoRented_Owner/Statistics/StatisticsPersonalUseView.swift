//
//  StatisticsPersonalUseView.swift
//  CondoRented_Owner
//
//  Created on 2026-03-06.
//

import SwiftUI

struct StatisticsPersonalUseView: View {

    let entries: [StatisticsViewModel.PersonalUseEntry]
    let totalImpact: Double
    let currency: Currency

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Label("Personal Use Detected", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            // Entries
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                if index > 0 {
                    Divider()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.listingTitle)
                        .font(.subheadline)
                        .bold()

                    HStack(spacing: 4) {
                        VStack(spacing: 2) {
                            Text("Real")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(compactCurrency(entry.balanceWithPersonalUse))
                                .font(.caption)
                                .bold()
                                .foregroundStyle(entry.balanceWithPersonalUse >= 0 ? .green : .red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 2) {
                            Text("Sin uso")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(compactCurrency(entry.balanceWithoutPersonalUse))
                                .font(.caption)
                                .bold()
                                .foregroundStyle(entry.balanceWithoutPersonalUse >= 0 ? .green : .red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 2) {
                            Text("Impacto")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            let impact = entry.balanceWithPersonalUse - entry.balanceWithoutPersonalUse
                            Text(compactCurrency(impact))
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            // Total
            Divider()

            HStack {
                Text("Total Impact")
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text(compactCurrency(totalImpact))
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
