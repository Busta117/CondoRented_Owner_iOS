//
//  DriveService.swift
//  CondoRented_Owner
//

import Foundation

final class DriveService {
    static let shared = DriveService()

    private let baseURL = "https://www.googleapis.com/drive/v3"
    private let uploadURL = "https://www.googleapis.com/upload/drive/v3"
    private let authManager = GoogleAuthManager.shared

    private init() {}

    // MARK: - Folder Operations

    func listFolders(parentId: String = "root") async throws -> [DriveFile] {
        let token = try await authManager.validAccessToken()
        let query = "'\(parentId)' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/files?q=\(encodedQuery)&fields=files(id,name)&orderBy=name"

        guard let url = URL(string: urlString) else { throw DriveError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)

        let result = try JSONDecoder().decode(DriveFileList.self, from: data)
        return result.files
    }

    // MARK: - File Operations

    func findFile(namePrefix: String, folderId: String) async throws -> DriveFile? {
        let token = try await authManager.validAccessToken()
        let nameQueries = ["png", "jpg", "jpeg", "pdf"].map { "name='\(namePrefix).\($0)'" }.joined(separator: " or ")
        let query = "'\(folderId)' in parents and (\(nameQueries)) and trashed=false"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/files?q=\(encodedQuery)&fields=files(id,name,mimeType,thumbnailLink)&pageSize=1"

        guard let url = URL(string: urlString) else { throw DriveError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)

        let result = try JSONDecoder().decode(DriveFileList.self, from: data)
        return result.files.first
    }

    func uploadFile(data fileData: Data, name: String, mimeType: String, folderId: String) async throws -> DriveFile {
        let token = try await authManager.validAccessToken()
        let urlString = "\(uploadURL)/files?uploadType=multipart&fields=id,name,mimeType"

        guard let url = URL(string: urlString) else { throw DriveError.invalidURL }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/related; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let metadata: [String: Any] = ["name": name, "parents": [folderId]]
        let metadataData = try JSONSerialization.data(withJSONObject: metadata)

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: .utf8)!)
        body.append(metadataData)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)

        return try JSONDecoder().decode(DriveFile.self, from: data)
    }

    func downloadFile(fileId: String) async throws -> Data {
        let token = try await authManager.validAccessToken()
        let urlString = "\(baseURL)/files/\(fileId)?alt=media"

        guard let url = URL(string: urlString) else { throw DriveError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)

        return data
    }

    func deleteFile(fileId: String) async throws {
        let token = try await authManager.validAccessToken()
        let urlString = "\(baseURL)/files/\(fileId)"

        guard let url = URL(string: urlString) else { throw DriveError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 {
            throw DriveError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    // MARK: - Helpers

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DriveError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw DriveError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - Models

struct DriveFile: Codable, Identifiable {
    let id: String
    let name: String
    var mimeType: String?
    var thumbnailLink: String?
}

struct DriveFileList: Codable {
    let files: [DriveFile]
}

enum DriveError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL invalida"
        case .invalidResponse: return "Respuesta invalida del servidor"
        case .requestFailed(let code): return "Error del servidor (codigo \(code))"
        }
    }
}
