//
//  ExpenseTypePickerView.swift
//  CondoRented_Owner
//
//  Created by Claude on 24/03/26.
//

import SwiftUI

struct ExpenseTypePickerView: View {

    let items: [(type: String, count: Int)]
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredItems: [(type: String, count: Int)] {
        if searchText.isEmpty { return items }
        return items.filter { $0.type.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredItems, id: \.type) { item in
                    Button {
                        onSelect(item.type)
                        dismiss()
                    } label: {
                        HStack {
                            Text(item.type)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(item.count)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search expense type")
            .navigationTitle("Add Expense Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
