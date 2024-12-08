//
//  AddEditListingView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 18/04/24.
//

import SwiftUI
import FirebaseFirestore


struct AddEditListingView: View {
    
//    @Environment(\.modelContext) private var modelContext
//    @State private var container: ModelContainer
//    private var tempModelContext: ModelContext
    
    @State var viewModel: AddEditListingViewModel
    @Binding var path: NavigationPath
    
    init(path: Binding<NavigationPath>, viewModel: AddEditListingViewModel) {
        
        self._path = path
        self.viewModel = viewModel
    }
    
    var body: some View {
        Form {
            Section {
                TextField("", text: $viewModel.listing.title)
            } header: {
                Text("Listing Name")
            }
            
            Section {
                if viewModel.adminFees.count > 0 {
                    List {
                        ForEach(viewModel.adminFees) { item in
                            AdminFeeDetail(adminFee: item, admin: viewModel.admin(forId: item.adminId))
                        }
                    }
                }
                else {
                    Button {
                        addNewAdminFee()
                    } label: {
                        Text("add new")
                            .font(.headline)
                            .bold()
                    }
                    
                }
                
            } header: {
                HStack {
                    Text("Admin Fee")
                    Spacer()
                    Button(action: {
                        addNewAdminFee()
                    }, label: {
                        Text("add new")
                            .font(.caption)
                            .bold()
                    })
                }
                
            }
            
            Section {
                Button(action: {
                    saveAction()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Save")
                            .font(.headline)
                        Spacer()
                    }
                    
                    
                })
            }
        }
        .navigationDestination(for: AdminFee.self) { adminFee in
//            NewAdminFeeView(tmpContext: tempModelContext, path: $path, listing: listing)
        }
        .navigationTitle("Listing")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    private func addNewAdminFee() {
        
//        let adminFee = AdminFee(listing: listing, dateStart: .now, percent: 15, admin: Admin(name: "Jorge"))
//        tempModelContext.insert(adminFee)
//        listing.adminFees?.append(adminFee)
                                
//        path.append(AdminFee(listing: listing, dateStart: .now, percent: 15, admin: Admin(name: "")))
    }
    
    private func saveAction() {
//        do {
//            try tempModelContext.save()
//            if !path.isEmpty {
//                path.removeLast()
//            }
//            
//            let db = Firestore.firestore()
//            db.insert(listing, collection: "Listing")
//            
//        } catch {
//            print(error)
//        }
        
//        let id = listing.id
//        let descriptor = FetchDescriptor<Listing>(predicate: #Predicate {$0.id == id})
//        
//        do {
//            let existElement = try modelContext.fetch(descriptor)
//            if let listing = existElement.first {
//                listing.title = self.listing.title
//                try? modelContext.save()
//            } else {
//                modelContext.insert(listing)
//            }
//        } catch {
//            modelContext.insert(listing)
//        }
//        if !path.isEmpty {
//            path.removeLast()
//        }
    }
}

//#Preview {
//    let container = ModelContainer.sharedInMemoryModelContainer
//    let example = Listing(id: "1", title: "title here")
//    return AddEditListingView(path: .constant(NavigationPath()), container: container, listing: example)
//        .modelContainer(container)
//        .modelContext(container.mainContext)
//}
