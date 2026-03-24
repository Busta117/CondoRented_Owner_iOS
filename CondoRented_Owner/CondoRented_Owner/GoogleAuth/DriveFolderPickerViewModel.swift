//
//  DriveFolderPickerViewModel.swift
//  CondoRented_Owner
//

import Foundation

@Observable
final class DriveFolderPickerViewModel {
    struct FolderLevel {
        let id: String
        let name: String
    }

    private let driveService = DriveService.shared

    var folders: [DriveFile] = []
    var breadcrumb: [FolderLevel] = [FolderLevel(id: "root", name: "My Drive")]
    var loading = false
    var error: String?

    var currentFolderId: String { breadcrumb.last?.id ?? "root" }
    var currentFolderName: String { breadcrumb.last?.name ?? "My Drive" }

    func loadFolder(id: String, name: String) async {
        await MainActor.run {
            loading = true
            error = nil
        }
        do {
            let results = try await driveService.listFolders(parentId: id)
            await MainActor.run {
                folders = results
                loading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.loading = false
            }
        }
    }

    func navigateInto(folder: DriveFile) async {
        await MainActor.run {
            breadcrumb.append(FolderLevel(id: folder.id, name: folder.name))
        }
        await loadFolder(id: folder.id, name: folder.name)
    }

    func navigateBack() async {
        guard breadcrumb.count > 1 else { return }
        await MainActor.run {
            breadcrumb.removeLast()
        }
        await loadFolder(id: currentFolderId, name: currentFolderName)
    }

    func loadRoot() async {
        await loadFolder(id: "root", name: "My Drive")
    }
}
