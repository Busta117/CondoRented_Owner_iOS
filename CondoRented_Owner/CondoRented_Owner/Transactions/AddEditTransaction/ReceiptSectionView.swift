//
//  ReceiptSectionView.swift
//  CondoRented_Owner
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ReceiptSectionView: View {
    @Bindable var viewModel: AddEditTransactionViewModel

    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        Section {
            if viewModel.receiptLoading {
                HStack {
                    Spacer()
                    ProgressView("Cargando comprobante...")
                    Spacer()
                }
            } else if let error = viewModel.receiptError, viewModel.receiptData == nil {
                VStack {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                    Button("Reintentar") {
                        viewModel.loadExistingReceipt()
                    }
                    .font(.caption)
                }
            } else if viewModel.hasReceipt {
                VStack(alignment: .leading, spacing: 8) {
                    if let image = viewModel.receiptImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                viewModel.showFullScreenReceipt = true
                            }
                    } else {
                        HStack {
                            Image(systemName: "doc.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                            Text(viewModel.receiptFileName ?? "Documento")
                                .font(.caption)
                        }
                        .onTapGesture {
                            viewModel.showFullScreenReceipt = true
                        }
                    }

                    HStack {
                        Button("Reemplazar") {
                            attachReceipt()
                        }
                        .font(.caption)

                        if viewModel.canSendEmail {
                            Spacer()
                            Button("Enviar por correo") {
                                viewModel.showMailComposer = true
                            }
                            .font(.caption)
                        }
                    }
                }
            } else {
                Button("Adjuntar comprobante") {
                    attachReceipt()
                }
            }
        } header: {
            Text("Comprobante")
        }
        .confirmationDialog("Adjuntar comprobante", isPresented: $viewModel.showReceiptActionSheet) {
            Button("Elegir foto") {
                viewModel.showPhotosPicker = true
            }
            Button("Elegir archivo") {
                viewModel.showDocumentPicker = true
            }
            Button("Cancelar", role: .cancel) {}
        }
        .photosPicker(isPresented: $viewModel.showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let (mimeType, ext): (String, String) = {
                        if data.count >= 4 {
                            let header = [UInt8](data.prefix(4))
                            if header[0] == 0x89, header[1] == 0x50 { return ("image/png", "png") }
                            if header[0] == 0x25, header[1] == 0x50 { return ("application/pdf", "pdf") }
                        }
                        return ("image/jpeg", "jpg")
                    }()
                    let fileName = "receipt.\(ext)"
                    await MainActor.run {
                        viewModel.setReceiptFile(data: data, fileName: fileName, mimeType: mimeType)
                    }
                }
                selectedPhoto = nil
            }
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            DocumentPickerView(
                contentTypes: [.image, .pdf],
                onPick: { url in
                    guard let data = try? Data(contentsOf: url) else { return }
                    let ext = url.pathExtension.lowercased()
                    let mimeType = ext == "pdf" ? "application/pdf" : "image/\(ext)"
                    let fileName = url.lastPathComponent
                    viewModel.setReceiptFile(data: data, fileName: fileName, mimeType: mimeType)
                }
            )
        }
        .sheet(isPresented: $viewModel.showMailComposer) {
            MailComposeView(
                recipients: viewModel.emailRecipients,
                subject: viewModel.emailSubject,
                body: viewModel.emailBody,
                attachmentData: viewModel.receiptData,
                attachmentMimeType: viewModel.receiptMimeType,
                attachmentFileName: viewModel.receiptFileName,
                onDismiss: { viewModel.showMailComposer = false }
            )
        }
        .fullScreenCover(isPresented: $viewModel.showFullScreenReceipt) {
            ReceiptFullScreenView(
                imageData: viewModel.receiptData,
                isImage: viewModel.receiptImage != nil,
                fileName: viewModel.receiptFileName
            )
        }
    }

    private func attachReceipt() {
        if GoogleAuthManager.shared.isSignedIn {
            viewModel.showReceiptActionSheet = true
        } else {
            Task { @MainActor in
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else { return }
                do {
                    try await GoogleAuthManager.shared.signIn(presenting: rootVC)
                    viewModel.showReceiptActionSheet = true
                } catch {}
            }
        }
    }
}

// MARK: - DocumentPickerView

struct DocumentPickerView: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            onPick(url)
        }
    }
}

// MARK: - ReceiptFullScreenView

struct ReceiptFullScreenView: View {
    let imageData: Data?
    let isImage: Bool
    let fileName: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if isImage, let data = imageData, let uiImage = UIImage(data: data) {
                    ScrollView {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                } else {
                    VStack {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.red)
                        Text(fileName ?? "Documento PDF")
                    }
                }
            }
            .navigationTitle("Comprobante")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}
