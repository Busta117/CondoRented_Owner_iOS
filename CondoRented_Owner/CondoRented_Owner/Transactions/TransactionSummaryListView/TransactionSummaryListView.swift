//
//  TransactionSummaryListView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 6/05/24.
//

import SwiftUI


struct TransactionSummaryListView: View {
    
    @Bindable var viewModel: TransactionSummaryListViewModel
    @State private var backButtonText: Bool = true
    @State var isGlobalSummaryExpanded = false
    
    var body: some View {
//        ZStack {
            List {
//                if let listing = viewModel.selectedListing {
//                    Text(viewModel.selectedListing?.title ?? "")
//                        .font(.headline)
//                }
                    
                Section(isExpanded: $isGlobalSummaryExpanded) {
                    globalSummary
                } header: {
                    HStack(spacing: 0) {
                        Button {
                            isGlobalSummaryExpanded.toggle()
                        } label: {
                            HStack {
                                Text("Global summary")
                                Spacer()
                                Image(systemName: isGlobalSummaryExpanded ? "chevron.up" : "chevron.down")
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                    }
                }

                
                ForEach(viewModel.transactionPerMonth, id:\.self) { transactions in
                    Section {
                        Button(action: {
                            viewModel.input(.monthDetailTapped(transactions))
                        }, label: {
                            TransactionSummaryListMonth(transactions: transactions, adminFees: viewModel.allAdminFees)
                                .contentShape(Rectangle())
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color.clear)
            .navigationTitle("Transactions")
            .toolbar {
                if viewModel.selectedListingId != nil {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.selectedListing?.title ?? "")
                            .font(.headline)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.input(.backDidSelect)
                        } label: {
                            Label("back", systemImage: "chevron.left")
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.input(.addNewTapped)
                        } label: {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
            .refreshable {
                viewModel.input(.onAppear)
            }
            .onAppear(perform: {
                backButtonText = true
//                viewModel.input(.onAppear)
            })
            .onDisappear(perform: {
                backButtonText = false
            })
            
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                    .padding()
            }
//        }
    }
    
    
    // MARK: - Global Summary
    
    @ViewBuilder
    var globalSummary: some View {
        /*
         + 3 tabs (all the time, past year, last 3 months)
         - gloabal balance: all months balance added
         - total admin fees paid
         - small chart per listing with: imcome, expenses, fees
         */
        
        Picker("", selection: $viewModel.summarySelectedTab) {
            Text("All").tag(0)
            Text("Past year").tag(1)
            Text("Last 3 months").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        
        // Tab Content
        Group {
            switch viewModel.summarySelectedTab {
            case 0:
                globalBalanceGeneral(months: 10000)
            case 1:
                let currentMonth = Calendar.current.component(.month, from: Date())
                globalBalanceGeneral(months: currentMonth)
            case 2:
                globalBalanceGeneral(months: 3)
            default:
                EmptyView()
            }
        }
    }
    
    func globalBalanceGeneral(months: Int) -> some View {
        HStack {
            Text("Balance")
                .font(.body)
            Spacer()
            Text(viewModel.gloabalBalance(monthsAgo: months), format: .currency(code: "COP"))
                .font(.body)
                .bold()
//                .foregroundStyle(monthBalanceValue >= 0 ? .green : .red)
        }
    }
    
}


//#Preview {
//    let container = ModelContainer.sharedInMemoryModelContainer
//    let listing = Listing(id: "1", title: "Distrito Vera",adminFees: [AdminFee(listing: nil, dateStart: .now, percent: 0.1)])
//    
////    let trans = Transaction(amountMicros: 200000000, listing: listing, date: Date(timeIntervalSinceNow: 9999999), type: .notPaid)
//    let trans2 = Transaction(amountMicros: 1000000000000, currency: Currency(id: "COP"), listing: listing, type: .paid)
//    container.mainContext.insert(listing)
////    container.mainContext.insert(trans)
//    container.mainContext.insert(trans2)
//    
//    let dataSource = AppDataSource(transactionDataSource: TransactionDataSource(modelContainer: container), listingDataSource: ListingDataSource(modelContainer: container))
//    
//    let viewModel = TransactionSummaryListViewModel(dataSource: dataSource, output: .init(addNew: {}, monthDetail: {_ in }))
//    
//    return TransactionSummaryListView(viewModel: viewModel, backButtonText: <#T##Bool#> )
//}
