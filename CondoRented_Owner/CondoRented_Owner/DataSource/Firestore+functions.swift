//
//  Firestore+functions.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 30/11/24.
//

import Foundation
import FirebaseFirestore

extension Firestore {
    
    func insert<T>(_ object: T) async where T: CodableAndIdentifiable {
        do {
            try self.collection(object.collectionId).document(object.id).setData(from: object)
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    func delete<T>(_ object: T) async where T: CodableAndIdentifiable {
        do {
            try await self.collection(object.collectionId).document(object.id).delete()
        } catch {
            print("Error adding document: \(error)")
        }
    }
}
