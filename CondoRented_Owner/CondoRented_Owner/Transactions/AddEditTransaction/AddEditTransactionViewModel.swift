//
//  AddEditTransactionViewModel.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 15/05/24.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI
import UniformTypeIdentifiers
import MessageUI

@Observable
final class AddEditTransactionViewModel {
    
    enum Output {
        case back
    }
    
    enum Input {
        case saveTapped
    }
    
    @ObservationIgnored
    private let dataSource: AppDataSourceProtocol
    @ObservationIgnored
    var transaction: Transaction?
    @ObservationIgnored
    var output: (Output) -> Void
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var allCurrencies: [Currency] = []
    var allListing: [Listing] = []

    var loading: Bool = true
    
    var amount: Double = 0
    var currency: Currency = Currency(id: "COP")
    var listing: Listing? = nil
    var date: Date = .now
    var type: TransactionType? = nil

    var paidAmountFormatted: String? = nil
    var paidAmountCurrency: Currency? = nil
    var expenseConcept: String? = nil
    var expensePaidByOwner: Bool = true

    // Receipt state
    var receiptData: Data?
    var receiptFileName: String?
    var receiptMimeType: String?
    var receiptImage: UIImage?
    var existingDriveFileId: String?
    var receiptLoading = false
    var receiptError: String?

    var isCoOwnershipFee: Bool {
        type?.title == "Co-Ownership Fees"
    }

    var hasReceipt: Bool {
        receiptData != nil
    }

    var canSendEmail: Bool {
        hasReceipt && existingDriveFileId != nil
        && MFMailComposeViewController.canSendMail()
        && !(listing?.recipientEmails.isEmpty ?? true)
    }

    var driveFileName: String? {
        guard let listing = listing, let ext = receiptFileName?.components(separatedBy: ".").last else { return nil }
        return receiptFileNameForDrive(for: listing, date: date, ext: ext)
    }

    init(transaction: Transaction? = nil,
         dataSource: AppDataSourceProtocol,
         output: @escaping (Output) -> Void) {
        self.transaction = transaction
        self.dataSource = dataSource
        self.output = output
        
        registerListeners()
        fetchInitialData()
    }
    
    private func fetchInitialData() {
        Task {
            await dataSource.listingDataSource.fetchListings()
            await MainActor.run {
                self.allCurrencies = Currency.all
                self.currency = Currency.all.first ?? Currency(id: "COP")
                self.onDoneLoaded()
            }
        }
    }

    private func registerListeners() {
        dataSource.listingDataSource.listingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] listings in
                guard let self else { return }
                self.allListing = listings
                if self.transaction != nil {
                    self.onDoneLoaded() // Actualiza si ya estabas editando
                }
            }
            .store(in: &cancellables)
    }

    private func onDoneLoaded() {
        guard let transaction = transaction else {
            loading = false
            return
        }

        self.amount = transaction.amountMicros * transaction.currency.microMultiplier
        self.currency = transaction.currency
        self.listing = allListing.first(where: { $0.id == transaction.listingId })
        self.date = transaction.date
        self.type = transaction.type
        self.expenseConcept = transaction.expenseConcept
        self.expensePaidByOwner = transaction.expensePaidByOwner ?? true
        self.loading = false

        if isCoOwnershipFee {
            loadExistingReceipt()
        }
    }
    
    var navigationTitle: String {
        transaction == nil ? "New transaction" : "Edit transaction"
    }
    
    var isAmountCorrect: Bool {
        type == .personalUse || amount > 0
    }

    var canSave: Bool {
        isAmountCorrect && listing != nil && type != nil
    }
    
    func input(_ input: Input) {
        switch input {
        case .saveTapped:
            saveTransaction()
        }
    }
    
    private func saveTransaction() {
        loading = true
        
        guard let listing = listing, let type = type else {
            return
        }
        
        let microAmount = amount / currency.microMultiplier
        
        let expenseConceptFixed: String? = {
            return switch type {
            case .expense(let title):
                type.isOther ? expenseConcept : title
            default:
                nil
            }
        }()
        
        let expensePaidByOwnerFixed: Bool? = {
            if case .expense = type {
                return expensePaidByOwner
            }
            return nil
        }()
        
        let newTransaction = Transaction(
            id: transaction?.id ?? UUID().uuidString,
            amountFormatted: "",
            amountMicros: microAmount,
            currency: currency,
            listingId: listing.id,
            date: date,
            type: type,
            paidAmountFormatted: nil,
            paidAmountCurrency: nil,
            expenseConcept: expenseConceptFixed,
            expensePaidByOwner: expensePaidByOwnerFixed
        )
        
        Task {
            await dataSource.transactionDataSource.add(transaction: newTransaction)

            // Upload receipt to Drive if present
            if let receiptData = self.receiptData,
               let listing = self.listing,
               let rootFolderId = listing.driveFolderId,
               self.isCoOwnershipFee {

                let ext = self.receiptFileName?.components(separatedBy: ".").last ?? "png"
                let name = self.receiptFileNameForDrive(for: listing, date: self.date, ext: ext)
                let mime = self.receiptMimeType ?? "image/png"
                let year = self.yearString(from: self.date)

                do {
                    let yearFolderId = try await DriveService.shared.findOrCreateYearFolder(year: year, parentId: rootFolderId)
                    let uploaded = try await DriveService.shared.uploadFile(
                        data: receiptData, name: name, mimeType: mime, folderId: yearFolderId
                    )
                    if let oldId = self.existingDriveFileId, oldId != uploaded.id {
                        try? await DriveService.shared.deleteFile(fileId: oldId)
                    }
                } catch {
                    await MainActor.run {
                        self.receiptError = "Transaction saved but receipt upload to Drive failed"
                        self.loading = false
                    }
                    return
                }
            }

            await MainActor.run {
                self.loading = false
                self.output(.back)
            }
        }
    }

    // MARK: - Receipt Helpers

    private static let spanishMonths = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]

    private func spanishMonth(from date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        return Self.spanishMonths[month - 1]
    }

    private func yearString(from date: Date) -> String {
        let year = Calendar.current.component(.year, from: date)
        return String(year)
    }

    private func monthString(from date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        return String(format: "%02d", month)
    }

    private func receiptFileNameForDrive(for listing: Listing, date: Date, ext: String) -> String {
        "\(listing.shortCode)-\(yearString(from: date))-\(monthString(from: date)).\(ext)"
    }

    private func receiptNamePrefix(for listing: Listing, date: Date) -> String {
        "\(listing.shortCode)-\(yearString(from: date))-\(monthString(from: date))"
    }

    func loadExistingReceipt() {
        guard let listing = listing, let rootFolderId = listing.driveFolderId else { return }
        guard isCoOwnershipFee else { return }

        receiptLoading = true
        receiptError = nil

        Task {
            do {
                let year = yearString(from: date)
                let yearFolderId = try await DriveService.shared.findOrCreateYearFolder(year: year, parentId: rootFolderId)
                let prefix = receiptNamePrefix(for: listing, date: date)
                guard let file = try await DriveService.shared.findFile(namePrefix: prefix, folderId: yearFolderId) else {
                    await MainActor.run {
                        receiptLoading = false
                    }
                    return
                }

                let data = try await DriveService.shared.downloadFile(fileId: file.id)
                await MainActor.run {
                    self.existingDriveFileId = file.id
                    self.receiptData = data
                    self.receiptFileName = file.name
                    self.receiptMimeType = file.mimeType
                    if let mimeType = file.mimeType, mimeType.hasPrefix("image") {
                        self.receiptImage = UIImage(data: data)
                    }
                    self.receiptLoading = false
                }
            } catch {
                await MainActor.run {
                    self.receiptError = "Could not load receipt"
                    self.receiptLoading = false
                }
            }
        }
    }

    func setReceiptFile(data: Data, fileName: String, mimeType: String) {
        if mimeType.hasPrefix("image"), let image = UIImage(data: data) {
            let pdfData = convertImageToPDF(image)
            let pdfFileName = fileName.replacingOccurrences(
                of: "\\.[^.]+$",
                with: ".pdf",
                options: .regularExpression
            )
            self.receiptData = pdfData
            self.receiptFileName = pdfFileName
            self.receiptMimeType = "application/pdf"
            self.receiptImage = image
        } else {
            self.receiptData = data
            self.receiptFileName = fileName
            self.receiptMimeType = mimeType
            self.receiptImage = nil
        }
    }

    private func convertImageToPDF(_ image: UIImage) -> Data {
        let pageRect = CGRect(origin: .zero, size: image.size)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { context in
            context.beginPage()
            image.draw(in: pageRect)
        }
    }

    var emailSubject: String {
        "Pago Administración \(spanishMonth(from: date)) \(yearString(from: date))"
    }

    var emailBody: String {
        "Hola,<br><br>Adjunto comprobante de pago de la administración correspondiente al mes <b>\(spanishMonth(from: date)) \(yearString(from: date))</b>.<br><b>\(listing?.title ?? "")</b>"
    }

    var emailRecipients: [String] {
        listing?.recipientEmails ?? []
    }
}
