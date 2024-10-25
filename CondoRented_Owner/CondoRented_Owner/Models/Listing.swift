//
//  Listing.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import SwiftData

@Model
class Listing: CodableAndIdentifiable, Equatable, Hashable {
    
    static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case link
        case adminFees
        case airbnbId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        link = try container.decodeIfPresent(URL.self, forKey: .link)
        adminFees = try container.decodeIfPresent([AdminFee].self, forKey: .adminFees)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(link, forKey: .link)
        try container.encode(adminFees, forKey: .adminFees)
    }
}
