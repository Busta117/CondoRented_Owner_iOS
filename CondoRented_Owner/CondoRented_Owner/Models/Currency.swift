//
//  Currency.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class Currency {
    @Attribute(.unique) var id: String
    var microMultiplier: Double
    
    init(id: String, microMultiplier: Double? = 0.000001) {
        self.id = id
        self.microMultiplier = microMultiplier ?? 0.000001
    }
}

extension Currency {
    public var USD: Currency {
        Currency(id: "USD", microMultiplier: 0.000001)
    }
    
    public var COP: Currency {
        Currency(id: "COP", microMultiplier: 0.000001)
    }
}
