//
//  AddEditListingView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 18/04/24.
//

import SwiftUI
import SwiftData

struct AddEditListingView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var container: ModelContainer
    
    private var tempModelContext: ModelContext
    @Binding var path: NavigationPath
    @State var listing: Listing
    
    init(path: Binding<NavigationPath>, container: ModelContainer, listing: Listing) {
        
        self._path = path
        self.container = container
        self.tempModelContext = ModelContext(container)
        self.tempModelContext.autosaveEnabled = false
        
        let id = listing.id
        let descriptor = FetchDescriptor<Listing>(predicate: #Predicate {$0.id == id})
        do {
            let existElement = try tempModelContext.fetch(descriptor)
            if let listingTmp = existElement.first {
                self.listing = listingTmp
            } else {
                self.listing = listing
            }
        } catch {
            self.listing = listing
        }
        
        self.tempModelContext.insert(self.listing)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("", text: $listing.title)
            } header: {
                Text("Listing Name")
            }
            
            Section {
                if let adminFees = listing.adminFees, adminFees.count > 0 {
                    List {
                        ForEach(adminFees) { item in
                            AdminFeeDetail(adminFee: item)
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
            NewAdminFeeView(tmpContext: tempModelContext, path: $path, listing: listing)
        }
        .navigationTitle("Listing")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    private func addNewAdminFee() {
        
//        let adminFee = AdminFee(listing: listing, dateStart: .now, percent: 15, admin: Admin(name: "Jorge"))
//        tempModelContext.insert(adminFee)
//        listing.adminFees?.append(adminFee)
                                
        path.append(AdminFee(listing: listing, dateStart: .now, percent: 15, admin: Admin(name: "")))
    }
    
    private func saveAction() {
        print("busta \(listing.title)")
        print("busta admin \(listing.adminFees?.first?.admin?.name)")
        
        do {
            try tempModelContext.save()
            if !path.isEmpty {
                path.removeLast()
            }
        } catch {
            print(error)
            print("busta")
        }
        
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

#Preview {
    let container = ModelContainer.sharedInMemoryModelContainer
    let example = Listing(id: "1", title: "title here")
    return AddEditListingView(path: .constant(NavigationPath()), container: container, listing: example)
        .modelContainer(container)
        .modelContext(container.mainContext)
}
