//
//  ListingMainView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//

import SwiftUI

struct ListingMainView: View {
    @ObservedObject var coordinator: ListingCoordinator = ListingCoordinator()
    @StateObject var navigationRouter: NavigatorRouter<ListingRoute> = .init(initial: .list)
    
    var body: some View {
        NavigatorView(router: navigationRouter) { route in
            switch route {
            case .list:
                ListingsView(viewModel: ListingsViewModel(dataSource: AppDataSource.defaultDataSource, output: { output in
                    switch output {
                    case .detail(let listing):
                        navigationRouter.push(.detail(listing: listing))
                    }
                        
                }))
//                .customTitle("cosa")
            case .detail(let listing):
                
                AddEditListingView(viewModel: AddEditListingViewModel(dataSource: AppDataSource.defaultDataSource,
                                                                      listing: listing, output: { output in
                    switch output {
                    case .backDidSelect:
                        navigationRouter.pop()
                    case .addNewAdminFeeDidSelect:
                        navigationRouter.push(.createOrEditAdminFee(listing: listing, adminFee: nil))
                    case .editAdminFeeDidSelect(let adminFee):
                        navigationRouter.push(.createOrEditAdminFee(listing: listing, adminFee: adminFee))
                    }
                }))
                    
                
            case .createOrEditAdminFee(let listing, let adminFee):
                
                NewAdminFeeView(viewModel: NewAdminFeeViewModel(dataSource: AppDataSource.defaultDataSource,
                                                                listing: listing,
                                                                adminFee: adminFee) { output in
                    switch output {
                    case .backDidSelect:
                        navigationRouter.pop()
                    }
                })
            }
        }
        
        .onLoad {
            coordinator.set(navigationRouter: navigationRouter)
        }
    }
}
