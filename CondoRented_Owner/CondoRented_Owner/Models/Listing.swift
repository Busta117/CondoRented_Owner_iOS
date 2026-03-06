//
//  Listing.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation

class Listing: CodableAndIdentifiable, Equatable, Hashable {
    private(set) var collectionId = "Listing"
    
    static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var title: String
    var link: URL?
    var airbnbId: String?
    var propertyValue: Double?

    var adminFeeIds: [String] = []

    init(id: String = UUID().uuidString,
         title: String,
         link: URL? = nil,
         adminFeeIds: [String] = [],
         airbnbId: String? = nil,
         propertyValue: Double? = nil) {

        self.id = id
        self.title = title
        self.link = link
        self.adminFeeIds = adminFeeIds
        self.airbnbId = airbnbId
        self.propertyValue = propertyValue
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case link
        case adminFeeIds
        case airbnbId
        case propertyValue
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        link = try container.decodeIfPresent(URL.self, forKey: .link)
        adminFeeIds = try container.decodeIfPresent([String].self, forKey: .adminFeeIds) ?? []
        propertyValue = try container.decodeIfPresent(Double.self, forKey: .propertyValue)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(link, forKey: .link)
        try container.encode(adminFeeIds, forKey: .adminFeeIds)
        try container.encodeIfPresent(propertyValue, forKey: .propertyValue)
    }
}
