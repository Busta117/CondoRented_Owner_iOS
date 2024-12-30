//
//  ListingDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import FirebaseFirestore


protocol AdminDataSourceProtocol {
    func fetchAll() async -> [Admin]
    func fetch(id: String) async -> Admin?
    func save(_ admin: Admin) async
}

final class AdminDataSource: AdminDataSourceProtocol {
    private let db: Firestore
    
    init() {
        db = Firestore.firestore()
    }
    
    func fetchAll() async -> [Admin] {
        let docRef = db.collection("Admin")
        
        do {
            let result  = try await docRef.getDocuments()
            let results = try result.documents.map({ try $0.data(as: Admin.self) })
            
            return results
            
        } catch {
            print(error)
            return []
        }
    }
    
    func fetch(id: String) async -> Admin? {
        let docRef = db.collection("Admin").document(id)
        do {
            
            let result  = try await docRef.getDocument(as: Admin.self)
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    func save(_ admin: Admin) async {
        await db.insert(admin)
    }

}
