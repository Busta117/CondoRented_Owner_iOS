//
//  AdminFee.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import FirebaseFirestore
import SwiftData

@Model
class AdminFee: CodableAndIdentifiable {
    
    @Attribute(.unique) var id: String
    var listing: Listing?
    var dateStart: Date
    var dateFinish: Date?
    var percent: Double
    var admin: Admin?
    
    var listingId: String?
    var adminId: String?
    
    @available(*, deprecated, renamed: "init", message: "use init with ids")
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
    
    init(id: String = UUID().uuidString,
         listingId: String?,
         dateStart: Date,
         dateFinish: Date? = nil,
         percent: Double,
         adminId: String? = nil) {
        
        self.id = id
        self.listingId = listingId
        self.dateStart = dateStart
        self.dateFinish = dateFinish
        self.percent = percent
        self.adminId = adminId
    }
    
    enum CodingKeys: CodingKey {
        case id
        case dateStart
        case dateFinish
        case percent
        case listingId
        case adminId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        dateStart = try container.decode(Date.self, forKey: .dateStart)
        dateFinish = try container.decodeIfPresent(Date.self, forKey: .dateFinish)
        percent = try container.decode(Double.self, forKey: .percent)
        adminId = try container.decodeIfPresent(String.self, forKey: .adminId)
        listingId = try container.decodeIfPresent(String.self, forKey: .listingId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(dateStart, forKey: .dateStart)
        try container.encodeIfPresent(dateFinish, forKey: .dateFinish)
        try container.encode(percent, forKey: .percent)
        try container.encodeIfPresent(adminId, forKey: .adminId)
        try container.encodeIfPresent(listingId, forKey: .listingId)
    }
    
    static func fetchAll(modelContext: ModelContext) -> [AdminFee] {
        do {
            let descriptor = FetchDescriptor<AdminFee>(sortBy: [SortDescriptor(\.id)])
            let fees = try modelContext.fetch(descriptor)
            
            //sync with db
            let db = Firestore.firestore()
            for fee in fees {
                db.insert(fee, collection: "AdminFee")
            }
            
            return fees
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}

