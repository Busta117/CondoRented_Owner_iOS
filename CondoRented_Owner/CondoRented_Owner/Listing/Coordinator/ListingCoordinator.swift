//
//  ListingCoordinator.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//

import Foundation
import SwiftUI
import Combine

final class ListingCoordinator: ObservableObject {
    
    enum Action {
        case listingDidSelect(_ listing: Listing)
        case createOrEditAdminFeeDidSelect(listing: Listing, adminFee: AdminFee?)
        case adminFeeDidCreate
        case adminFeeDidEdit
    }
    
    private var navigationRouter: NavigatorRouter<ListingRoute> = NavigatorRouter()
    private let actionSubject = CurrentValueSubject<Action?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservables()
    }
    
    func set(navigationRouter: NavigatorRouter<ListingRoute>) {
        self.navigationRouter = navigationRouter
    }
    
    private func setupObservables() {
        actionSubject.sink { action in
            switch action {
            case .listingDidSelect(let listing):
                self.navigationRouter.push(.detail(listing: listing))
                
            case .createOrEditAdminFeeDidSelect(let listing, let adminFee):
                ()
            case .adminFeeDidCreate:
                ()
            case .adminFeeDidEdit:
                ()
            case nil:
                ()
            }
        }.store(in: &cancellables)
    }
    
}
