//
//  AddEditListingView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 18/04/24.
//

import SwiftUI
import FirebaseFirestore


struct AddEditListingView: View {

    enum Field {
        case title, propertyValue
    }

    @Bindable var viewModel: AddEditListingViewModel
    @FocusState private var focusedField: Field?

    init(viewModel: AddEditListingViewModel) {
        self.viewModel = viewModel
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { viewModel.listing.title },
            set: { newValue in
                viewModel.listing.title = newValue
                viewModel.triggerSave()
            }
        )
    }

    private var propertyValueBinding: Binding<Double?> {
        Binding(
            get: { viewModel.listing.propertyValue },
            set: { newValue in
                viewModel.listing.propertyValue = newValue
                viewModel.triggerSave()
            }
        )
    }

    var body: some View {
        VStack {
            NavigatorBar(title: "Listing")
                .navigatorBackButton(title: "") {
                    viewModel.saveImmediately()
                    viewModel.output(.backDidSelect)
                }
            Form {
                Section {
                    TextField("", text: titleBinding)
                        .focused($focusedField, equals: .title)
                        .onSubmit {
                            focusedField = nil
                            viewModel.saveImmediately()
                        }
                } header: {
                    Text("Listing Name")
                }

                Section {
                    TextField("Property Value", value: propertyValueBinding, format: .number)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .propertyValue)
                } header: {
                    Text("Property Value (COP)")
                }

                Section {
                    Button(action: {
                        viewModel.output(.seeTransactionsDidSelect)
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
                    ForEach(viewModel.listing.expectedMonthlyExpenseTypes, id: \.self) { expenseType in
                        Text(expenseType)
                    }
                    .onDelete { indexSet in
                        let types = viewModel.listing.expectedMonthlyExpenseTypes
                        for index in indexSet {
                            viewModel.removeExpenseType(types[index])
                        }
                    }
                } header: {
                    HStack {
                        Text("Expected Monthly Expenses")
                        Spacer()
                        Button {
                            viewModel.showExpensePicker = true
                        } label: {
                            Text("add new")
                                .font(.caption)
                                .bold()
                        }
                    }
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
                            viewModel.output(.addNewAdminFeeDidSelect)
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
                            viewModel.output(.addNewAdminFeeDidSelect)
                        }, label: {
                            Text("add new")
                                .font(.caption)
                                .bold()
                        })
                    }

                }

                Section {
                    if let folderName = viewModel.listing.driveFolderName {
                        HStack {
                            Label(folderName, systemImage: "folder")
                            Spacer()
                            Button("Cambiar") {
                                viewModel.selectDriveFolder()
                            }
                            .font(.caption)
                        }
                    } else {
                        Button("Seleccionar carpeta") {
                            viewModel.selectDriveFolder()
                        }
                    }
                } header: {
                    Text("Carpeta de Drive")
                }

                RecipientEmailsView(
                    emails: Binding(
                        get: { viewModel.listing.recipientEmails },
                        set: { viewModel.listing.recipientEmails = $0 }
                    ),
                    onChanged: { viewModel.triggerSave() }
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                        viewModel.saveImmediately()
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .sheet(isPresented: $viewModel.showExpensePicker) {
            ExpenseTypePickerView(
                items: viewModel.availableExpenseTypesForPicker,
                onSelect: { type in
                    viewModel.addExpenseType(type)
                }
            )
        }
        .sheet(isPresented: $viewModel.showDriveFolderPicker) {
            DriveFolderPickerView { folderId, folderName in
                viewModel.listing.driveFolderId = folderId
                viewModel.listing.driveFolderName = folderName
                viewModel.triggerSave()
            }
        }
    }
}
