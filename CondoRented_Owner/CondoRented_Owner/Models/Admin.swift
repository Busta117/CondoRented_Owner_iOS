//
//  Admin.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 1/05/24.
//

import Foundation
import FirebaseFirestore

struct Admin: CodableAndIdentifiable, Hashable {
    private(set) var collectionId = "Admin"
    var id: String
    var name: String
    var feeIds: [String] = []
    
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
    
    init(from decoder: Decoder) throws {
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

