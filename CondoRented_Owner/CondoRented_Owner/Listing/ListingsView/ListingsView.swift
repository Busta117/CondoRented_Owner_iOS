//
//  ListingsView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import SwiftUI

struct ListingsView: View {
    
    @State var viewModel: ListingsViewModel
    
    @State private var scrollOffset: CGFloat = 0
    
//    @State private var path = NavigationPath()
    
    var body: some View {
        
        VStack(spacing: 0) {
            NavigatorBar(title: "Listings")
            // Barra de navegación
//            CustomNavigationBar(
//                title: "Mi Título",
//                scrollOffset: scrollOffset,
//                leadingAction: { print("Volver") },
//                trailingAction: { print("Configuración") }
//            )
            
            // Contenido desplazable
//            ScrollableContentView(scrollOffset: $scrollOffset) {
                List {
                    ForEach(viewModel.listingList) { item in
                        Button {
                            viewModel.output(.detail(listing: item))
                        } label: {
                            HStack(alignment: .center) {
                                Image(systemName: "house")
                                    .imageScale(.large)
                                    .foregroundStyle(.primary.opacity(0.5))
                                    .frame(width: 70, height: 70, alignment: .center)
                                    .background(Color.gray.opacity(0.2))
                                Text(item.title)
                                    .font(.headline)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
//                }
            }
        }
        
        
        
//        NavigationStack(path: $path) {
//        VStack {
////            CustomNavigationBar(scrollOffset: .constant(0), title: "hola sexy", leadingAction: nil, trailingAction: nil)
////            NavigatorBar(title: "Listings")
//            List {
//                ForEach(viewModel.listingList) { item in
//                    Button {
//                        viewModel.output(.detail(listing: item))
//                    } label: {
//                        Image(systemName: "house")
//                            .imageScale(.large)
//                            .foregroundStyle(.primary.opacity(0.5))
//                            .frame(width: 70, height: 70, alignment: .center)
//                            .background(Color.gray.opacity(0.2))
//                        Text(item.title)
//                            .font(.headline)
//                    }
//                }
////                .onDelete(perform: deleteItems)
//            }
//            //            .navigationDestination(for: Listing.self) { listing in
//            //                let vm = AddEditListingViewModel(dataSource: viewModel.dataSource, listing: listing)
//            //                AddEditListingView(path: $path, viewModel: vm)
//            //            }
//            
//        }
////        .navigatorTitle("Listing2")
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(action: addItem) {
//                    Label("Add Item", systemImage: "plus")
//                }
//            }
//        }
    }

    private func addItem() {
//        withAnimation {
//            path.append(Listing(title: ""))
//        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
//                modelContext.delete(viewModel.listingList[index])
            }
        }
    }
}

//#Preview {
//    let container = ModelContainer.sharedInMemoryModelContainer
//    return ListingsView(container: container)
//        .modelContainer(container)
//}
