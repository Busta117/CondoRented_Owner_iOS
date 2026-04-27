//
//  ListingsView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import SwiftUI

struct ListingsView: View {

    @Bindable var viewModel: ListingsViewModel

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            NavigatorBar(title: "Listings")
            List {
                Section {
                    ForEach(viewModel.activeListings) { item in
                        Button {
                            viewModel.didSelectListing(item)
                        } label: {
                            listingRow(for: item, disabled: false)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                if !viewModel.disabledListings.isEmpty {
                    Section("Disabled") {
                        ForEach(viewModel.disabledListings) { item in
                            Button {
                                viewModel.didSelectListing(item)
                            } label: {
                                listingRow(for: item, disabled: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .id(viewModel.listingsVersion)
        }
    }

    @ViewBuilder
    private func listingRow(for item: Listing, disabled: Bool) -> some View {
        HStack(alignment: .center) {
            Image(systemName: "house")
                .imageScale(.large)
                .foregroundStyle(.primary.opacity(disabled ? 0.3 : 0.5))
                .frame(width: 70, height: 70, alignment: .center)
                .background(Color.gray.opacity(0.2))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(disabled ? .secondary : .primary)
                if disabled, let date = item.disabledDate {
                    Text("Sold \(date.formatted(.dateTime.day().month(.abbreviated).year()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
    }
}
