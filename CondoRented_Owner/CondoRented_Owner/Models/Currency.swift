//
//  Currency.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation

struct Currency: CodableAndIdentifiable, Hashable {
    private(set) var collectionId = "Currency"
    
    var id: String
    var microMultiplier: Double
    
    init(id: String, microMultiplier: Double? = 0.000001) {
        self.id = id
        self.microMultiplier = microMultiplier ?? 0.000001
    }
    
    enum CodingKeys: CodingKey {
        case id
        case microMultiplier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        microMultiplier = try container.decode(Double.self, forKey: .microMultiplier)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(microMultiplier, forKey: .microMultiplier)
    }
}

extension Currency {
    
    static private(set) var all = [Currency(id: "COP"), Currency(id: "USD")]
    
}
