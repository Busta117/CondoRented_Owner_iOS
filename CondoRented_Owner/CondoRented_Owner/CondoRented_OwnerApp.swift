//
//  CondoRented_OwnerApp.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import SwiftUI
import SwiftData

@main
struct CondoRented_OwnerApp: App {

    init() {
        createAdminsIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(container: ModelContainer.sharedModelContainer)
                .modelContainer(ModelContainer.sharedModelContainer)
        }
        
    }
    
    @MainActor func createAdminsIfNeeded() {
        
        let container = ModelContainer.sharedModelContainer
        let modelContext = container.mainContext
        let descriptor = FetchDescriptor<Admin>()
        
        do {
            let existElement = try modelContext.fetch(descriptor)
            if existElement.count == 0 {
                let admin = Admin(name: "Jorge Luis")
                let admin2 = Admin(name: "Santiago Bustamante")
                modelContext.insert(admin)
                modelContext.insert(admin2)
            }    
        } catch {
            print(error)
        }
    }
    
}
