//
//  Listing.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 17/04/24.
//

import Foundation

class Listing: CodableAndIdentifiable, Equatable, Hashable {
    private(set) var collectionId = "Listing"
    
    static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.propertyValue == rhs.propertyValue
        && lhs.expectedMonthlyExpenseTypes == rhs.expectedMonthlyExpenseTypes
        && lhs.adminFeeIds == rhs.adminFeeIds
        && lhs.driveFolderId == rhs.driveFolderId
        && lhs.driveFolderName == rhs.driveFolderName
        && lhs.recipientEmails == rhs.recipientEmails
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var title: String
    var link: URL?
    var airbnbId: String?
    var propertyValue: Double?

    var adminFeeIds: [String] = []
    var expectedMonthlyExpenseTypes: [String] = []
    var driveFolderId: String?
    var driveFolderName: String?
    var recipientEmails: [String] = []

    var shortCode: String {
        title.split(separator: " ")
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()
    }

    init(id: String = UUID().uuidString,
         title: String,
         link: URL? = nil,
         adminFeeIds: [String] = [],
         airbnbId: String? = nil,
         propertyValue: Double? = nil,
         expectedMonthlyExpenseTypes: [String] = [],
         driveFolderId: String? = nil,
         driveFolderName: String? = nil,
         recipientEmails: [String] = []) {

        self.id = id
        self.title = title
        self.link = link
        self.adminFeeIds = adminFeeIds
        self.airbnbId = airbnbId
        self.propertyValue = propertyValue
        self.expectedMonthlyExpenseTypes = expectedMonthlyExpenseTypes
        self.driveFolderId = driveFolderId
        self.driveFolderName = driveFolderName
        self.recipientEmails = recipientEmails
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case link
        case adminFeeIds
        case airbnbId
        case propertyValue
        case expectedMonthlyExpenseTypes
        case driveFolderId
        case driveFolderName
        case recipientEmails
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        link = try container.decodeIfPresent(URL.self, forKey: .link)
        adminFeeIds = try container.decodeIfPresent([String].self, forKey: .adminFeeIds) ?? []
        propertyValue = try container.decodeIfPresent(Double.self, forKey: .propertyValue)
        expectedMonthlyExpenseTypes = try container.decodeIfPresent([String].self, forKey: .expectedMonthlyExpenseTypes) ?? []
        driveFolderId = try container.decodeIfPresent(String.self, forKey: .driveFolderId)
        driveFolderName = try container.decodeIfPresent(String.self, forKey: .driveFolderName)
        recipientEmails = try container.decodeIfPresent([String].self, forKey: .recipientEmails) ?? []
    }

    func copy() -> Listing {
        Listing(
            id: id,
            title: title,
            link: link,
            adminFeeIds: adminFeeIds,
            airbnbId: airbnbId,
            propertyValue: propertyValue,
            expectedMonthlyExpenseTypes: expectedMonthlyExpenseTypes,
            driveFolderId: driveFolderId,
            driveFolderName: driveFolderName,
            recipientEmails: recipientEmails
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(link, forKey: .link)
        try container.encode(adminFeeIds, forKey: .adminFeeIds)
        try container.encodeIfPresent(propertyValue, forKey: .propertyValue)
        try container.encode(expectedMonthlyExpenseTypes, forKey: .expectedMonthlyExpenseTypes)
        try container.encodeIfPresent(driveFolderId, forKey: .driveFolderId)
        try container.encodeIfPresent(driveFolderName, forKey: .driveFolderName)
        try container.encode(recipientEmails, forKey: .recipientEmails)
    }
}
