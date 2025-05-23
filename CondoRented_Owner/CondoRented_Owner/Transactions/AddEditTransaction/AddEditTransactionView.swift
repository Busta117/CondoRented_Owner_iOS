//
//  AddEditTransactionView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import SwiftUI


struct AddEditTransactionView: View {
    
    @Bindable var viewModel: AddEditTransactionViewModel
    
    @FocusState private var textfieldIsFocused: Bool
    
    var body: some View {
        VStack {
            if viewModel.loading {
                VStack {
                    ZStack {
                        Color.black.opacity(0.3)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                            .padding()
                    }
                    Spacer()
                }
            } else {
                Form {
                    amountSection
//                    currencySection
                    listingSection
                    dateSection
                    typeSection
                    saveButtonSection
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack{
                    Spacer()
                    Button("Done") {
                        textfieldIsFocused = false
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var amountSection: some View {
        Section {
            TextField("add an amount", value: $viewModel.amount, format: .currency(code: viewModel.currency.id).grouping(.automatic))
                .keyboardType(.decimalPad)
                .focused($textfieldIsFocused)
        } header: {
            Text("Amount")
        } footer: {
            if !viewModel.isAmountCorrect {
                Text("please enter a valid value")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
    
    @ViewBuilder
    private var currencySection: some View {
        Section {
            Picker(selection: $viewModel.currency) {
                ForEach(viewModel.allCurrencies, id: \.self) { currency in
                    Text(currency.id)
                        .tag(currency.id)
                }
            } label: {
                EmptyView()
            }

        } header: {
            Text("Currency")
        }
    }
    
    private var listingSection: some View {
        Section {
            Picker(selection: $viewModel.listing) {
                if viewModel.listing == nil {
                    Text("Select a listing")
                        .tag(nil as Listing?)
                }
                ForEach(viewModel.allListing, id: \.self) { listing in
                    Text(listing.title)
                        .tag(listing as Listing?)
                }
            } label: {
                EmptyView()
            }

        } header: {
            Text("Listing")
        }
    }
    
    private var dateSection: some View {
        Section {
            DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
        } header: {
            Text("Payable Date")
        }
    }
    
    private var typeSection: some View {
        Section {
            
            let binding = Binding<String>(
                get: {
                    if let match = TransactionType.allCases.first(where: { $0.title == viewModel.type?.title }) {
                        return match.title
                    } else if let title = viewModel.type?.title {
                        return TransactionType.other.title
                    }
                    return ""
                },
                set: { newTitle in
                    if newTitle == "" {
                        viewModel.type = nil
                    } else if let match = TransactionType.allCases.first(where: { $0.title == newTitle }) {
                        viewModel.type = match
                    } else {
                        // Es un tipo personalizado (other)
                        viewModel.type = .expense(title: newTitle)
                    }
                }
            )
            
            Picker(selection: binding) {
                if viewModel.type == nil {
                    Text("Select a type").tag("")
                }
                ForEach(TransactionType.allCases.map(\.title), id: \.self) { title in
                    Text(title).tag(title)
                }
                
            } label: {
                EmptyView()
            }
            
            expenseType
            
        } header: {
            Text("Transaction type")
        }
    }
    
    @ViewBuilder
    private var expenseType: some View {
        if let type = viewModel.type, type.isOther {
            TextField(
                "Write a concept",
                text: Binding(
                    get: { viewModel.expenseConcept ?? "" },
                    set: { viewModel.expenseConcept = $0.isEmpty ? nil : $0 }
                )
            )
            .focused($textfieldIsFocused)
            
            Toggle(isOn: $viewModel.expensePaidByOwner) {
                Text("Paid by Owner?")
            }
        }
    }
    
    private var saveButtonSection: some View {
        Section {
            Button(action: {
                viewModel.input(.saveTapped)
            }, label: {
                HStack {
                    Spacer()
                    Text("Save")
                        .font(.headline)
                    Spacer()
                }
            })
            .disabled(!viewModel.canSave)
        }
    }
}

//#Preview {
//    let container = ModelContainer.sharedInMemoryModelContainer
//    
//    let l1 = Listing(title: "Distrito Vera")
//    let l2 = Listing(title: "La Riviere")
//    container.mainContext.insert(l1)
//    container.mainContext.insert(l2)
//    
//    let appDataSource = AppDataSource.defaultDataSource
//    
//    return AddEditTransactionView(viewModel: AddEditTransactionViewModel(dataSource: appDataSource, output: { _ in }))
//}
