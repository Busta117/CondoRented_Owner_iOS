//
//  RecipientEmailsView.swift
//  CondoRented_Owner
//

import SwiftUI

struct RecipientEmailsView: View {
    @Binding var emails: [String]
    @State private var newEmail = ""
    @State private var showAddField = false
    var onChanged: () -> Void

    var body: some View {
        Section {
            ForEach(emails, id: \.self) { email in
                Text(email)
            }
            .onDelete { indexSet in
                emails.remove(atOffsets: indexSet)
                onChanged()
            }

            if showAddField {
                HStack {
                    TextField("email@ejemplo.com", text: $newEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Agregar") {
                        let trimmed = newEmail.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty, trimmed.contains("@"), trimmed.contains(".") else { return }
                        emails.append(trimmed)
                        newEmail = ""
                        showAddField = false
                        onChanged()
                    }
                    .disabled(newEmail.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        } header: {
            HStack {
                Text("Emails destinatarios comprobante")
                Spacer()
                Button {
                    showAddField = true
                } label: {
                    Text("add new")
                        .font(.caption)
                        .bold()
                }
            }
        }
    }
}
