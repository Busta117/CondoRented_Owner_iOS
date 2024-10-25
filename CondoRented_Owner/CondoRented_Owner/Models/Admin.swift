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
    @Relationship(inverse: \AdminFee.admin) var fees: [AdminFee]? {
        didSet{
            feeIds = fees?.map({$0.id}) ?? []
        }
    }
    
    var feeIds: [String]
    
    @available(*, deprecated, renamed: "init", message: "use init with ids")
    init(id: String = UUID().uuidString, name: String, fees: [AdminFee]? = nil) {
        self.id = id
        self.name = name
        self.fees = fees
        
        feeIds = fees?.map({$0.id}) ?? []
    }
    
    init(id: String = UUID().uuidString, name: String, feeIds: [String]) {
        self.id = id
        self.name = name
        self.feeIds = feeIds
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case feeIds
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        feeIds = try container.decode([String].self, forKey: .feeIds)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(feeIds, forKey: .feeIds)
    }
    
}

