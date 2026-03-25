//
//  ReceiptSectionView.swift
//  CondoRented_Owner
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

enum ReceiptSheet: String, Identifiable {
    case documentPicker
    case mailComposer
    case fullScreenReceipt

    var id: String { rawValue }
}

struct ReceiptSectionView: View {
    @Bindable var viewModel: AddEditTransactionViewModel

    // Presentation state lives in the PARENT view (AddEditTransactionView)
    // so it survives re-draws of this conditional subview.
    @Binding var showPhotosPicker: Bool
    @Binding var activeSheet: ReceiptSheet?

    var body: some View {
        Section {
            if viewModel.receiptLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading receipt...")
                    Spacer()
                }
            } else if let error = viewModel.receiptError, viewModel.receiptData == nil {
                VStack(spacing: 8) {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                    Button("Retry") {
                        viewModel.loadExistingReceipt()
                    }
                    .font(.caption)
                }
            } else if viewModel.hasReceipt {
                receiptPreview
                receiptActions
            } else {
                sourceButtons
            }
        } header: {
            Text("Receipt")
        }
    }

    // MARK: - Source Buttons (no receipt yet)

    private var sourceButtons: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(.tertiary)
                .frame(height: 100)
                .overlay {
                    VStack(spacing: 6) {
                        Image(systemName: "paperclip")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("No receipt attached")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

            HStack(spacing: 16) {
                Button {
                    ensureSignedIn { showPhotosPicker = true }
                } label: {
                    Label("Photo", systemImage: "photo")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button {
                    ensureSignedIn { activeSheet = .documentPicker }
                } label: {
                    Label("File", systemImage: "doc")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    // MARK: - Receipt Preview

    @ViewBuilder
    private var receiptPreview: some View {
        if let image = viewModel.receiptImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 180)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(Rectangle())
                .onTapGesture {
                    activeSheet = .fullScreenReceipt
                }
        } else if let data = viewModel.receiptData, let pdfThumbnail = pdfThumbnail(from: data) {
            Image(uiImage: pdfThumbnail)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 180)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(Rectangle())
                .onTapGesture {
                    activeSheet = .fullScreenReceipt
                }
        } else {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                Text(viewModel.receiptFileName ?? "Document")
                    .font(.subheadline)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                activeSheet = .fullScreenReceipt
            }
        }
    }

    private func pdfThumbnail(from data: Data) -> UIImage? {
        guard let document = PDFDocument(data: data),
              let page = document.page(at: 0) else { return nil }
        let bounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 300 / bounds.width
        let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)
        return page.thumbnail(of: size, for: .mediaBox)
    }

    // MARK: - Receipt Actions Row

    private var receiptActions: some View {
        HStack {
            Text(viewModel.driveFileName ?? viewModel.receiptFileName ?? "")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Menu {
                Button {
                    deferToNextRunLoop { ensureSignedIn { showPhotosPicker = true } }
                } label: {
                    Label("Replace from photos", systemImage: "photo")
                }

                Button {
                    deferToNextRunLoop { ensureSignedIn { activeSheet = .documentPicker } }
                } label: {
                    Label("Replace from files", systemImage: "doc")
                }

                if viewModel.canSendEmail {
                    Divider()
                    Button {
                        deferToNextRunLoop { activeSheet = .mailComposer }
                    } label: {
                        Label("Send by email", systemImage: "envelope")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Defers execution to the next run loop iteration.
    /// Required when presenting from Menu items — Menu uses UIContextMenuInteraction
    /// which is still dismissing its own presentation when the button action fires.
    private func deferToNextRunLoop(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }

    // MARK: - Auth Helper

    private func ensureSignedIn(then action: @escaping () -> Void) {
        if GoogleAuthManager.shared.isSignedIn {
            action()
        } else {
            Task { @MainActor in
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else { return }
                do {
                    try await GoogleAuthManager.shared.signIn(presenting: rootVC)
                    action()
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

// MARK: - PDFKitView

struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
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
                if let data = imageData {
                    if isImage, let uiImage = UIImage(data: data) {
                        ScrollView {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        }
                    } else {
                        PDFKitView(data: data)
                    }
                } else {
                    ContentUnavailableView("No receipt data", systemImage: "doc.questionmark")
                }
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
