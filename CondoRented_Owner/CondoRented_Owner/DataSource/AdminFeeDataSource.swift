//
//  AdminFeeDataSource.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import FirebaseFirestore


protocol AdminFeeDataSourceProtocol {
    func fetchAll() async -> [AdminFee]
    func fetch(id: String) async -> AdminFee?
    func fetch(forListingId listingId: String) async -> [AdminFee]
    func save(_ adminFee: AdminFee) async
}

final class AdminFeeDataSource: AdminFeeDataSourceProtocol {
    private let db: Firestore
    
    init() {
        db = Firestore.firestore()
    }
    
    func fetchAll() async -> [AdminFee] {
        let docRef = db.collection("AdminFee")
        
        do {
            let result  = try await docRef.getDocuments()
            let results = try result.documents.map({ try $0.data(as: AdminFee.self) })
            
            return results
            
        } catch {
            print(error)
            return []
        }
    }
    
    func fetch(id: String) async -> AdminFee? {
        let docRef = db.collection("AdminFee").document(id)
        do {
            
            let result  = try await docRef.getDocument(as: AdminFee.self)
            return result
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetch(forListingId listingId: String) async -> [AdminFee] {
        let all = await fetchAll()
        return all.filter({$0.listingId == listingId})
    }
    
    func save(_ adminFee: AdminFee) async {
        await db.insert(adminFee)
    }

}
