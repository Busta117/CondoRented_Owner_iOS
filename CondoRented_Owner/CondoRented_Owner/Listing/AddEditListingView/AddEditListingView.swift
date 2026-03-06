//
//  AddEditListingView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 18/04/24.
//

import SwiftUI
import FirebaseFirestore


struct AddEditListingView: View {

    @Bindable var viewModel: AddEditListingViewModel
    @FocusState private var isFieldFocused: Bool

    init(viewModel: AddEditListingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            NavigatorBar(title: "Listing")
                .navigatorBackButton(title: "") {
                    viewModel.output(.backDidSelect)
                }
            Form {
                Section {
                    TextField("", text: $viewModel.listing.title)
                } header: {
                    Text("Listing Name")
                }
                
                Section {
                    TextField("Property Value", value: $viewModel.listing.propertyValue, format: .number)
                        .keyboardType(.numberPad)
                        .focused($isFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isFieldFocused = false
                                }
                            }
                        }
                } header: {
                    Text("Property Value (COP)")
                }

                Section {
                    Button(action: {
                        seeTransactionsAction()
                    }, label: {
                        HStack {
                            Text("See Transactions")
                            Spacer()
                            Label("", systemImage: "chevron.right")
                        }
                        .font(.body)
                        .contentShape(Rectangle())
                    })
                    .buttonStyle(.plain)
                }
                
                Section {
                    if viewModel.adminFees.count > 0 {
                        List {
                            ForEach(viewModel.adminFees) { item in
                                Button(action: {
                                    viewModel.output(.editAdminFeeDidSelect(item))
                                }, label: {
                                    AdminFeeDetail(adminFee: item, admin: viewModel.admin(forId: item.adminId))
                                        .contentShape(Rectangle())
                                })
                                .buttonStyle(PlainButtonStyle())
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
        }
        .onAppear {
            viewModel.onAppear()
        }
            
    }
    
    private func addNewAdminFee() {
        viewModel.output(.addNewAdminFeeDidSelect)
    }
    
    private func seeTransactionsAction() {
        viewModel.output(.seeTransactionsDidSelect)
    }
    
    private func saveAction() {
        isFieldFocused = false
        viewModel.save()
    }
}

//#Preview {
//    let container = ModelContainer.sharedInMemoryModelContainer
//    let example = Listing(id: "1", title: "title here")
//    return AddEditListingView(path: .constant(NavigationPath()), container: container, listing: example)
//        .modelContainer(container)
//        .modelContext(container.mainContext)
//}
