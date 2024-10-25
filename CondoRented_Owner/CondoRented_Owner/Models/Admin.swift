//
//  Admin.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 1/05/24.
//

import Foundation
import FirebaseFirestore

import SwiftData

@Model
class Admin: CodableAndIdentifiable {
    @Attribute(.unique) var id: String
    var name: String
    @Relationship(inverse: \AdminFee.admin) var fees: [AdminFee]?
    
    init(id: String = UUID().uuidString, name: String, fees: [AdminFee]? = nil) {
        self.id = id
        self.name = name
        self.fees = fees
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
//        case fees
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
//        fees = try container.decodeIfPresent([AdminFee].self, forKey: .fees)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
//        try container.encodeIfPresent(fees, forKey: .fees)
    }
    
}

