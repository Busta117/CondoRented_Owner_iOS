//
//  AccountMember.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import Foundation

struct AccountMember: CodableAndIdentifiable, Hashable {
    private(set) var collectionId = "AccountMember"

    var id: String
    var userId: String
    var accountId: String
    var role: String

    enum CodingKeys: CodingKey {
        case id, userId, accountId, role
    }

    init(id: String = UUID().uuidString, userId: String, accountId: String, role: String = "owner") {
        self.id = id
        self.userId = userId
        self.accountId = accountId
        self.role = role
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        accountId = try container.decode(String.self, forKey: .accountId)
        role = try container.decodeIfPresent(String.self, forKey: .role) ?? "owner"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(role, forKey: .role)
    }
}
