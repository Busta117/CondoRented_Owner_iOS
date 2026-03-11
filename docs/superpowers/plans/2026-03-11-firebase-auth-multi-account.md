# Firebase Auth + Multi-Account Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add user authentication (login only, no sign-up in app) with multi-account support, so users log in and see data scoped to their selected account.

**Architecture:** A `SessionManager` (ObservableObject) manages auth state + active account. It holds the current `AppDataSource` and recreates it when accounts switch. The root view toggles between `LoginView` and `MainTabView` based on auth state. A new Profile tab lets users switch accounts and log out. Users and accounts are created via Firebase Console + Node.js scripts.

**Tech Stack:** Firebase Auth, FirebaseFirestore, SwiftUI, Combine

**Firestore Structure:**
```
/User/{firebaseAuthUID}          - email, name
/AccountMember/{autoId}          - userId, accountId, role
/Account/{accountId}/...         - existing subcollections
```

---

## Chunk 1: Foundation (Models, Auth, DataSources)

### Task 1: Add FirebaseAuth dependency

**Manual step in Xcode — cannot be automated.**

- [ ] **Step 1:** Open `CondoRented_Owner.xcodeproj` in Xcode
- [ ] **Step 2:** Go to project target > Package Dependencies
- [ ] **Step 3:** The `firebase-ios-sdk` package is already added. Click on it, add the **FirebaseAuth** product to the CondoRented_Owner target
- [ ] **Step 4:** Build to verify it compiles (Cmd+B)
- [ ] **Step 5:** Enable Email/Password sign-in in Firebase Console > Authentication > Sign-in method

---

### Task 2: Create User and AccountMember models

**Files:**
- Create: `CondoRented_Owner/Models/User.swift`
- Create: `CondoRented_Owner/Models/AccountMember.swift`

- [ ] **Step 1: Create User model**

```swift
// User.swift
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
```

- [ ] **Step 2: Create AccountMember model**

```swift
// AccountMember.swift
import Foundation

struct AccountMember: CodableAndIdentifiable, Hashable {
    private(set) var collectionId = "AccountMember"

    var id: String
    var userId: String
    var accountId: String
    var role: String  // "owner", "viewer", "admin"

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
```

- [ ] **Step 3:** Add both files to the Xcode project (drag into Models group)
- [ ] **Step 4:** Build to verify compilation

**Note:** `User` and `AccountMember` are root-level Firestore collections (NOT under Account), so their insert/delete use `Firestore.firestore().collection("User")` directly — not `accountCollection()`. We need a separate insert method for root-level models, or handle them in their own DataSources.

---

### Task 3: Create AuthManager

**Files:**
- Create: `CondoRented_Owner/DataSource/AuthManager.swift`

- [ ] **Step 1: Create AuthManager**

```swift
// AuthManager.swift
import Foundation
import FirebaseAuth
import Combine

protocol AuthManagerProtocol {
    var currentUserId: String? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<String?, Never> { get }

    func signIn(email: String, password: String) async throws
    func signOut() throws
}

final class AuthManager: AuthManagerProtocol {
    private let authStateSubject = CurrentValueSubject<String?, Never>(nil)
    private var handle: AuthStateDidChangeListenerHandle?

    var currentUserId: String? {
        authStateSubject.value
    }

    var isAuthenticated: Bool {
        currentUserId != nil
    }

    var authStatePublisher: AnyPublisher<String?, Never> {
        authStateSubject.eraseToAnyPublisher()
    }

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.authStateSubject.send(user?.uid)
        }
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
```

- [ ] **Step 2:** Add file to Xcode project
- [ ] **Step 3:** Build to verify

---

### Task 4: Create UserDataSource and AccountMemberDataSource

**Files:**
- Create: `CondoRented_Owner/DataSource/UserDataSource.swift`
- Create: `CondoRented_Owner/DataSource/AccountMemberDataSource.swift`
- Modify: `CondoRented_Owner/DataSource/Firestore+functions.swift`

**Note:** These collections are at the Firestore root level (not under Account). We need a root-level insert helper.

- [ ] **Step 1: Add root-level helper to Firestore+functions.swift**

Add to the existing `Firestore` extension:

```swift
func insertAtRoot<T>(_ object: T) async where T: CodableAndIdentifiable {
    do {
        try self.collection(object.collectionId).document(object.id).setData(from: object)
    } catch {
        print("Error adding document: \(error)")
    }
}
```

- [ ] **Step 2: Create UserDataSource**

```swift
// UserDataSource.swift
import Foundation
import FirebaseFirestore

protocol UserDataSourceProtocol {
    func fetch(id: String) async -> AppUser?
}

final class UserDataSource: UserDataSourceProtocol {
    private let db: Firestore

    init() {
        self.db = Firestore.firestore()
    }

    func fetch(id: String) async -> AppUser? {
        do {
            return try await db.collection("User").document(id).getDocument(as: AppUser.self)
        } catch {
            print("Failed to fetch user \(id): \(error)")
            return nil
        }
    }
}
```

- [ ] **Step 3: Create AccountMemberDataSource**

```swift
// AccountMemberDataSource.swift
import Foundation
import FirebaseFirestore

protocol AccountMemberDataSourceProtocol {
    func fetchAccounts(forUserId userId: String) async -> [AccountMember]
}

final class AccountMemberDataSource: AccountMemberDataSourceProtocol {
    private let db: Firestore

    init() {
        self.db = Firestore.firestore()
    }

    func fetchAccounts(forUserId userId: String) async -> [AccountMember] {
        do {
            let snapshot = try await db.collection("AccountMember")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            return try snapshot.documents.map { try $0.data(as: AccountMember.self) }
        } catch {
            print("Failed to fetch account members: \(error)")
            return []
        }
    }
}
```

- [ ] **Step 4:** Add both files to Xcode project
- [ ] **Step 5:** Build to verify

---

## Chunk 2: SessionManager + UI

### Task 5: Create SessionManager

**Files:**
- Create: `CondoRented_Owner/DataSource/SessionManager.swift`
- Modify: `CondoRented_Owner/DataSource/AccountManager.swift`

The `SessionManager` is the central piece: it listens to auth state, loads the user's accounts, manages account selection, and provides the active `AppDataSource`.

- [ ] **Step 1: Update AccountManager to support setting accountId**

Replace `AccountManager.swift` with:

```swift
// AccountManager.swift
import Foundation

protocol AccountManagerProtocol {
    var accountId: String? { get }
    func setAccountId(_ id: String)
    func clear()
}

final class AccountManager: AccountManagerProtocol {
    private static let accountIdKey = "currentAccountId"

    var accountId: String? {
        UserDefaults.standard.string(forKey: Self.accountIdKey)
    }

    func setAccountId(_ id: String) {
        UserDefaults.standard.set(id, forKey: Self.accountIdKey)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Self.accountIdKey)
    }
}
```

- [ ] **Step 2: Create SessionManager**

```swift
// SessionManager.swift
import Foundation
import Combine

enum SessionState {
    case loading
    case unauthenticated
    case authenticated
}

@MainActor
final class SessionManager: ObservableObject {
    @Published var state: SessionState = .loading
    @Published var currentUser: AppUser?
    @Published var accounts: [AccountMember] = []
    @Published var activeAccountId: String?
    @Published private(set) var appDataSource: AppDataSource?

    private let authManager: AuthManagerProtocol
    private let userDataSource: UserDataSourceProtocol
    private let accountMemberDataSource: AccountMemberDataSourceProtocol
    private let accountManager: AccountManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authManager: AuthManagerProtocol = AuthManager(),
         userDataSource: UserDataSourceProtocol = UserDataSource(),
         accountMemberDataSource: AccountMemberDataSourceProtocol = AccountMemberDataSource(),
         accountManager: AccountManagerProtocol = AccountManager()) {

        self.authManager = authManager
        self.userDataSource = userDataSource
        self.accountMemberDataSource = accountMemberDataSource
        self.accountManager = accountManager

        authManager.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userId in
                Task { await self?.handleAuthChange(userId: userId) }
            }
            .store(in: &cancellables)
    }

    private func handleAuthChange(userId: String?) async {
        guard let userId else {
            state = .unauthenticated
            currentUser = nil
            accounts = []
            activeAccountId = nil
            appDataSource = nil
            return
        }

        state = .loading
        currentUser = await userDataSource.fetch(id: userId)
        accounts = await accountMemberDataSource.fetchAccounts(forUserId: userId)

        // Select account: saved preference > first available
        if let saved = accountManager.accountId,
           accounts.contains(where: { $0.accountId == saved }) {
            activeAccountId = saved
        } else if let first = accounts.first {
            activeAccountId = first.accountId
            accountManager.setAccountId(first.accountId)
        }

        if let accountId = activeAccountId {
            buildDataSource(accountId: accountId)
        }

        state = .authenticated
    }

    func switchAccount(to accountId: String) {
        activeAccountId = accountId
        accountManager.setAccountId(accountId)
        buildDataSource(accountId: accountId)
    }

    private func buildDataSource(accountId: String) {
        appDataSource = AppDataSource(
            transactionDataSource: TransactionDataSource(accountId: accountId),
            listingDataSource: ListingDataSource(accountId: accountId),
            adminDataSource: AdminDataSource(accountId: accountId),
            adminFeeDataSource: AdminFeeDataSource(accountId: accountId)
        )
    }

    func signIn(email: String, password: String) async throws {
        try await authManager.signIn(email: email, password: password)
    }

    func signOut() {
        try? authManager.signOut()
        accountManager.clear()
    }
}
```

- [ ] **Step 3:** Add file to Xcode project
- [ ] **Step 4:** Build to verify

---

### Task 6: Create LoginView (login only, no sign-up)

**Files:**
- Create: `CondoRented_Owner/Auth/LoginView.swift`

- [ ] **Step 1: Create LoginView**

```swift
// LoginView.swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Sign In")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Button {
                Task { await signIn() }
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .padding(.horizontal)

            Spacer()
        }
    }

    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await session.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

- [ ] **Step 2:** Create `Auth/` folder, add file to Xcode project
- [ ] **Step 3:** Build to verify

---

### Task 7: Create ProfileView with account selector

**Files:**
- Create: `CondoRented_Owner/Profile/ProfileView.swift`

- [ ] **Step 1: Create ProfileView**

```swift
// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        List {
            if let user = session.currentUser {
                Section("User") {
                    LabeledContent("Name", value: user.name)
                    LabeledContent("Email", value: user.email)
                }
            }

            Section("Accounts") {
                ForEach(session.accounts, id: \.id) { member in
                    Button {
                        session.switchAccount(to: member.accountId)
                    } label: {
                        HStack {
                            Text(member.accountId)
                                .foregroundColor(.primary)
                            Spacer()
                            if member.accountId == session.activeAccountId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    session.signOut()
                }
            }
        }
        .navigationTitle("Profile")
    }
}
```

- [ ] **Step 2:** Create `Profile/` folder, add file to Xcode project
- [ ] **Step 3:** Build to verify

---

### Task 8: Update CondoRented_OwnerApp — root view + Profile tab

**Files:**
- Modify: `CondoRented_Owner/CondoRented_OwnerApp.swift`

The app root now switches between Login and Main based on auth state. All views get `session` via `@EnvironmentObject`. The `AppDataSource.defaultDataSource` singleton is no longer used — instead views get the dataSource from `session.appDataSource`.

- [ ] **Step 1: Rewrite CondoRented_OwnerApp.swift**

```swift
// CondoRented_OwnerApp.swift
import SwiftUI
import FirebaseCore

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
```

- [ ] **Step 2:** Build to verify (will have errors until Task 9)

---

### Task 9: Update all AppDataSource.defaultDataSource usages

**Files to modify:**
- `CondoRented_Owner/Transactions/TransactionCoordinator.swift` (lines 76, 93, 111)
- `CondoRented_Owner/Listing/Coordinator/ListingMainView.swift` (lines 18, 28, 45, 55, 73)
- `CondoRented_Owner/DataSource/AppDataSource.swift` (remove static singleton)

All these files currently use `AppDataSource.defaultDataSource`. They need to receive the dataSource from `SessionManager` via `@EnvironmentObject`.

- [ ] **Step 1: Update TransactionCoordinator**

Add a `dataSource` property to `TransactionCoordinator`. Replace all `AppDataSource.defaultDataSource` references with `self.dataSource`. Pass it from `TransactionTabbarItemView` which has access to `@EnvironmentObject`.

- [ ] **Step 2: Update ListingMainView**

Add `@EnvironmentObject var session: SessionManager`. Replace all `AppDataSource.defaultDataSource` with `session.appDataSource!`.

- [ ] **Step 3: Remove `AppDataSource.defaultDataSource` static property**

Delete the static singleton from `AppDataSource.swift`. It's no longer needed — `SessionManager.appDataSource` replaces it.

- [ ] **Step 4: Remove old AppDelegate code**

Remove `AccountManager.setupDefaultAccount()`, `createAdminsIfNeeded()`, and `createCurrencyIfNeeded()` from AppDelegate. Currency seeding can be done via script if needed.

- [ ] **Step 5:** Build and test full flow

---

## Chunk 3: Seed Data + Final Testing

### Task 10: Create user and seed data via script

Users are created in two places: Firebase Auth (Console) for credentials, and Firestore (script) for app data.

- [ ] **Step 1:** Create user in Firebase Console > Authentication > Add User (email + password)
- [ ] **Step 2:** Copy the UID from the Console
- [ ] **Step 3:** Create and run seed script:

```javascript
// seed-user.js
const admin = require("firebase-admin");
const serviceAccount = require("./firebase-adminsdk.json");

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

// Replace these values:
const USER_ID = "<FIREBASE_AUTH_UID>";
const USER_EMAIL = "<your-email>";
const USER_NAME = "<your-name>";
const ACCOUNT_ID = "busvil-medellin";

async function main() {
    // Create User document in Firestore
    await db.collection("User").doc(USER_ID).set({
        id: USER_ID,
        email: USER_EMAIL,
        name: USER_NAME,
    });
    console.log("User document created.");

    // Create AccountMember linking user to account
    const memberId = `${USER_ID}_${ACCOUNT_ID}`;
    await db.collection("AccountMember").doc(memberId).set({
        id: memberId,
        userId: USER_ID,
        accountId: ACCOUNT_ID,
        role: "owner",
    });
    console.log("AccountMember created.");

    process.exit(0);
}

main().catch(console.error);
```

- [ ] **Step 4:** Run: `npm install firebase-admin && node seed-user.js`
- [ ] **Step 5:** Verify in Firebase Console that `/User/{uid}` and `/AccountMember/{uid}_busvil-medellin` exist
- [ ] **Step 6:** Delete script, node_modules, package.json, package-lock.json

---

### Task 11: End-to-end testing

- [ ] **Step 1:** Launch app — should see Login screen (not the tabs)
- [ ] **Step 2:** Enter wrong credentials — should show error message
- [ ] **Step 3:** Sign in with correct credentials — should load main tab view with all data
- [ ] **Step 4:** Go to Profile tab — should show user name, email, and `busvil-medellin` with checkmark
- [ ] **Step 5:** Sign out — should return to Login screen
- [ ] **Step 6:** Kill and relaunch app — should auto-login (Firebase Auth persists session)
