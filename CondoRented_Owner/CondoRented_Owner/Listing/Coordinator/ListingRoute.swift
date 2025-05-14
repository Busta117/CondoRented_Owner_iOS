//
//  ListingRoute.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//

enum ListingRoute: RouteProtocol {
    static func == (lhs: ListingRoute, rhs: ListingRoute) -> Bool {
        switch (lhs, rhs) {
        case (.list, .list), (.detail, .detail), (.createOrEditAdminFee, .createOrEditAdminFee):
            return true
        default:
            return false
        }
    }

    case list
    case detail(listing: Listing)
    case createOrEditAdminFee(listing: Listing, adminFee: AdminFee?)
    case transactionList(listingId: String)
    case transactionMonthDetail(transactions: [Transaction], ListingId: String)
}
