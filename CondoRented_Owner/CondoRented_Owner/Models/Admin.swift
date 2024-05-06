//
//  Admin.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 1/05/24.
//

import Foundation
import SwiftData

@Model
class Admin: Identifiable {
    @Attribute(.unique) var id: String
    var name: String
    @Relationship(inverse: \AdminFee.admin) var fees: [AdminFee]?
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.fees = nil
    }
}
    
