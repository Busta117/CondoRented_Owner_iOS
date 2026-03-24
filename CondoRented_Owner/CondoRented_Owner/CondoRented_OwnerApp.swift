//
//  CondoRented_OwnerApp.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CondoRented_OwnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var session = SessionManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        Group {
            switch session.state {
            case .loading:
                ProgressView("Loading...")
            case .unauthenticated:
                LoginView()
            case .authenticated:
                if session.appDataSource != nil {
                    MainTabView()
                } else {
                    VStack(spacing: 16) {
                        Text("No accounts available")
                            .font(.headline)
                        Text("Contact your administrator to get access to an account.")
                            .foregroundColor(.secondary)
                        Button("Sign Out") { session.signOut() }
                    }
                }
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            Group {
                TransactionTabbarItemView()
                    .tabItem { Label("Transactions", systemImage: "dollarsign.circle") }
                    .tag(1)

                ListingMainView()
                    .tabItem { Label("Listing", systemImage: "house.circle") }
                    .tag(2)

                StatisticsTabbarItemView()
                    .tabItem { Label("Statistics", systemImage: "chart.bar.xaxis") }
                    .tag(3)

                NavigationStack {
                    ProfileView()
                }
                .tabItem { Label("Profile", systemImage: "person.circle") }
                .tag(4)
            }
            .toolbarBackground(.background.blendMode(.normal), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

struct TransactionTabbarItemView: View {
    @EnvironmentObject var session: SessionManager
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if let dataSource = session.appDataSource {
                TransactionCoordinator(page: .summaryList, navigationPath: $navigationPath, dataSource: dataSource).view()
                    .navigationDestination(for: TransactionCoordinator.self) { coordinator in
                        coordinator.view()
                    }
            }
        }
    }
}

struct StatisticsTabbarItemView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            if let dataSource = session.appDataSource {
                StatisticsView(viewModel: StatisticsViewModel(dataSource: dataSource))
            }
        }
    }
}
