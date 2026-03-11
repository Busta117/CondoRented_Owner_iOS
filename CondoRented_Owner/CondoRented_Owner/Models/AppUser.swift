//
//  AppUser.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import Foundation

struct AppUser: CodableAndIdentifiable, Hashable {
    private(set) var collectionId = "User"

    var id: String  // Firebase Auth UID
    var email: String
    var name: String

    enum CodingKeys: CodingKey {
        case id, email, name
    }

    init(id: String, email: String, name: String) {
        self.id = id
        self.email = email
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
    }
}
