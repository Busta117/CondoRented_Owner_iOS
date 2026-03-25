//
//  ProfileView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 11/03/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionManager
    private var googleAuth = GoogleAuthManager.shared

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

            Section("Google Drive") {
                if googleAuth.isSignedIn {
                    if let email = googleAuth.userEmail {
                        LabeledContent("Connected as", value: email)
                    }
                    Button("Disconnect Google Drive", role: .destructive) {
                        googleAuth.signOut()
                    }
                } else {
                    Button("Connect Google Drive") {
                        Task { @MainActor in
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let rootVC = windowScene.windows.first?.rootViewController else { return }
                            try? await googleAuth.signIn(presenting: rootVC)
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
