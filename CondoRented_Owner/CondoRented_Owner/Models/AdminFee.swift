//
//  AdminFee.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class AdminFee {
    
    @Attribute(.unique) var id: String
    var listing: Listing?
    var dateStart: Date
    var dateFinish: Date?
    var percent: Double
    var admin: Admin?
    
    init(id: String = UUID().uuidString, 
         listing: Listing?,
         dateStart: Date,
         dateFinish: Date? = nil,
         percent: Double,
         admin: Admin? = nil) {
        
        self.id = id
        self.listing = listing
        self.dateStart = dateStart
        self.dateFinish = dateFinish
        self.percent = percent
        self.admin = admin
    }
}
