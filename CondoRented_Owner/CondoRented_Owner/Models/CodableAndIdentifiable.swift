//
//  CodableAndIdentifiable.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 30/11/24.
//


protocol CodableAndIdentifiable: Codable, Identifiable {
    var collectionId: String { get }
    var id: String { get set }
}
