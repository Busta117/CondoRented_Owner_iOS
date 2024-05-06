//
//  Listing.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class Listing {
    @Attribute(.unique) var id: String
    var title: String
    var link: URL?
    @Relationship(deleteRule: .cascade) 
    var adminFees: [AdminFee]? = []
    var airbnbId: String?
    
    init(id: String = UUID().uuidString, 
         title: String,
         link: URL? = nil,
         adminFees: [AdminFee]? = [],
         airbnbId: String? = nil) {
        
        self.id = id
        self.title = title
        self.link = link
        self.adminFees = adminFees
        self.airbnbId = airbnbId
    }
}
