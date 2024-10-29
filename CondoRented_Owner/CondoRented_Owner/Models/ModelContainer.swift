//
//  ModelContainer.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation
import FirebaseFirestore
import SwiftData

protocol CodableAndIdentifiable: Codable {
    var collectionId: String { get }
    var id: String { get set }
}
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

public extension ModelContainer {
    
    private static var schema: Schema {
        Schema([
            Currency.self,
            Transaction.self,
            AdminFee.self,
            Admin.self,
            Listing.self
        ])
    }
    
    static var sharedModelContainer: ModelContainer = {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let model = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return model
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }()
    
    static var sharedInMemoryModelContainer: ModelContainer = {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @MainActor
    func sync() {
        return
        return
        let listingDataSource = ListingDataSource()
        listingDataSource.firebaseSaveAll()
        
        
        let transactionDataSource = TransactionDataSource()
        transactionDataSource.firebaseSaveAll()
        
        AdminFee.firebaseSaveAll(modelContext: self.mainContext)
    }
}
