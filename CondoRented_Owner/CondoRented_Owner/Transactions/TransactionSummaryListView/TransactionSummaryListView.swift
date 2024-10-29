//
//  TransactionSummaryListView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 6/05/24.
//

import SwiftUI
import SwiftData

struct TransactionSummaryListView: View {
    
    @State var viewModel: TransactionSummaryListViewModel
    @State private var backButtonText: Bool = true
    
    var body: some View {
        ZStack {
            List {
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
                Button(action: {
                    viewModel.input(.addNewTapped)
                }, label: {
                    Label("Add Item", systemImage: "plus")
                })
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
