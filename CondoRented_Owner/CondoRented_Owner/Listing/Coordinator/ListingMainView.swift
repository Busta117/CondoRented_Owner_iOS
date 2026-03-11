//
//  ListingMainView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//

import SwiftUI

struct ListingMainView: View {
    @EnvironmentObject var session: SessionManager
    @ObservedObject var coordinator: ListingCoordinator = ListingCoordinator()
    @StateObject var navigationRouter: NavigatorRouter<ListingRoute> = .init(initial: .list)

    var body: some View {
        NavigatorView(router: navigationRouter) { route in
            switch route {
            case .list:
                ListingsView(viewModel: ListingsViewModel(dataSource: session.appDataSource!, output: { output in
                    switch output {
                    case .detail(let listing):
                        navigationRouter.push(.detail(listing: listing))
                    }

                }))
            case .detail(let listing):

                AddEditListingView(viewModel: AddEditListingViewModel(dataSource: session.appDataSource!,
                                                                      listing: listing, output: { output in
                    switch output {
                    case .backDidSelect:
                        navigationRouter.pop()
                    case .addNewAdminFeeDidSelect:
                        navigationRouter.push(.createOrEditAdminFee(listing: listing, adminFee: nil))
                    case .editAdminFeeDidSelect(let adminFee):
                        navigationRouter.push(.createOrEditAdminFee(listing: listing, adminFee: adminFee))
                    case .seeTransactionsDidSelect:
                        navigationRouter.push(.transactionList(listingId: listing.id))
                    }
                }))


            case .createOrEditAdminFee(let listing, let adminFee):

                NewAdminFeeView(viewModel: NewAdminFeeViewModel(dataSource: session.appDataSource!,
                                                                listing: listing,
                                                                adminFee: adminFee) { output in
                    switch output {
                    case .backDidSelect:
                        navigationRouter.pop()
                    }
                })

            case .transactionList(let listingId):
                let dataSource = session.appDataSource!
                let vm = TransactionSummaryListViewModel(dataSource: dataSource,
                                                         selectedListingId: listingId,
                                                         output:
                        .init(
                            addNew: {},
                            monthDetail: { transactions in
                                navigationRouter.push(.transactionMonthDetail(transactions: transactions, ListingId: listingId))
                            },
                            backDidSelect: {
                                navigationRouter.pop()
                            }
                        ))
                NavigationStack {
                    TransactionSummaryListView(viewModel: vm)
                }

            case .transactionMonthDetail(let transactions, let ListingId):
                let dataSource = session.appDataSource!
                let vm = TransactionMonthDetailViewModel(dataSource: dataSource, transactions: transactions, selectedListingId: ListingId) { output in
                    switch output {
                    case .addNewTransaction:
                        ()
                    case .addNewTransactionWithType:
                        ()
                    case .editTransaction(let transaction):
                        ()
                    }
                }
                NavigationStack {
                    TransactionMonthDetailView(viewModel: vm)
                }

            }
        }

        .onLoad {
            coordinator.set(navigationRouter: navigationRouter)
        }
    }
}
