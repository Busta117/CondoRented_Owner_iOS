//
//  ListingsView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import SwiftUI
import SwiftData

struct ListingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State var container: ModelContainer
    
    @State var viewModel: ListingsViewModel = ListingsViewModel(dataSource: AppDataSource(transactionDataSource: TransactionDataSource(), listingDataSource: ListingDataSource()))
    
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(viewModel.listingList) { item in
                    NavigationLink(value: item) {
                        Image(systemName: "house")
                            .imageScale(.large)
                            .foregroundStyle(.primary.opacity(0.5))
                            .frame(width: 70, height: 70, alignment: .center)
                            .background(Color.gray.opacity(0.2))
                        Text(item.title)
                            .font(.headline)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Listing")
            .navigationDestination(for: Listing.self) { listing in
                AddEditListingView(path: $path, container: container, listing: listing)
            }
            .toolbar {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            
        }
    }

    private func addItem() {
        withAnimation {
            path.append(Listing(title: ""))
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
//                modelContext.delete(viewModel.listingList[index])
            }
        }
    }
}

#Preview {
    let container = ModelContainer.sharedInMemoryModelContainer
    return ListingsView(container: container)
        .modelContainer(container)
}
