//
//  CondoRented_OwnerApp.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        
        createAdminsIfNeeded()
        createCurrencyIfNeeded()
        ModelContainer.sharedModelContainer.sync()
        
        return true
    }
    
    @MainActor
    func createAdminsIfNeeded() {
        
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
            
            let newExistElement = try modelContext.fetch(descriptor)
            
            let db = Firestore.firestore()
            for admin in newExistElement {
                db.insert(admin, collection: "Admin")
            }
            
            
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func createCurrencyIfNeeded() {
        
        let container = ModelContainer.sharedModelContainer
        let modelContext = container.mainContext
        let descriptor = FetchDescriptor<Currency>()
        
        do {
            let existElement = try modelContext.fetch(descriptor)
            if existElement.count == 0 {
                let c1 = Currency(id: "COP", microMultiplier: 0.000001)
                let c2 = Currency(id: "USD", microMultiplier: 0.000001)
                modelContext.insert(c1)
                modelContext.insert(c2)
                
            }
        } catch {
            print(error)
        }
        
        Currency.loadAll()
        
        let db = Firestore.firestore()
        for c in Currency.all {
            db.insert(c, collection: "Currency")
        }
    }
}

struct TransactionTabbarItemView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TransactionCoordinator(page: .summaryList, navigationPath: $navigationPath).view()
                .navigationDestination(for: TransactionCoordinator.self) { coordinator in
                    coordinator.view()
                }
        }
    }
}

@main
struct CondoRented_OwnerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

//    private var transactionSummaryListViewModel: TransactionSummaryListViewModel
//    private var transactionCoordinator = TransactionCoordinator()
    
    init() {
//        let modelContainer = ModelContainer.sharedModelContainer
//        let dataSource = AppDataSource(transactionDataSource: TransactionDataSource(modelContainer: modelContainer),
//                                       listingDataSource: ListingDataSource(modelContainer: modelContainer))
//        let coordinator = TransactionCoordinator()
//        let transactionVM = TransactionSummaryListViewModel(dataSource: dataSource, coordinator: coordinator)
//        transactionSummaryListViewModel = transactionVM
        
//        createAdminsIfNeeded()
//        createCurrencyIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Group {
                    TransactionTabbarItemView()
//                    TransactionSummaryListView(viewModel: transactionSummaryListViewModel)
                        .tabItem { Label("Transactions", systemImage: "dollarsign.circle") }
                        .tag(1)
                    
                    ListingsView(container: ModelContainer.sharedModelContainer)
                        .tabItem { Label("Listing", systemImage: "house.circle") }
                        .tag(2)
                }
                .toolbarBackground(.background.blendMode(.normal), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
        }
        .modelContainer(ModelContainer.sharedModelContainer)
        
    }
}
