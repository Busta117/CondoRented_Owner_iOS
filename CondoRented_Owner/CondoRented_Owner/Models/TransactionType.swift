//
//  TransactionType.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 30/11/24.
//


enum TransactionType: Codable, CaseIterable, Hashable {
    case income
    case expense(title: String)
    case personalUse

    static var other: TransactionType {
        .expense(title: "Other")
    }

    static var availableExpenseTypes: [String] {
        ["Internet", "Mortgage", "Utilities", "Co-Ownership Fees"]
    }

    static var defaultExpenseTypes: [String] {
        availableExpenseTypes
    }

    static func expectedMonthlyExpenseTypes(for expenseTypes: [String]) -> [TransactionType] {
        let types = expenseTypes.isEmpty ? defaultExpenseTypes : expenseTypes
        return types.map { .expense(title: $0) }
    }

    static var allCases: [TransactionType] {
        [.income,
         .expense(title: "Internet"),
         .expense(title: "Mortgage"),
         .expense(title: "Utilities"),
         .expense(title: "Co-Ownership Fees"),
         other,
         .personalUse]
    }

    var isOther: Bool {
        if TransactionType.other == self {
            return true
        }
        if TransactionType.allCases.filter({ $0.title == self.title }).isEmpty {
            return true
        }
        return false
    }

    var typeTitle: String {
        switch self {
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        case .personalUse:
            return "Personal Use"
        }
    }

    var title: String {
        switch self {
        case .income:
            return "Income"
        case .expense(let title):
            return title
        case .personalUse:
            return "Personal Use"
        }
    }

    var titleWithType: String {
        switch self {
        case .income:
            return "Income"
        case .expense(let title1):
            return [title1, "(Expense)"].filter({!$0.isEmpty}).joined(separator: " ")
        case .personalUse:
            return "Personal Use"
        }
    }

    var rawValue: String {
        switch self {
        case .income:
            "income"
        case .expense:
            "expense"
        case .personalUse:
            "personalUse"
        }
    }

    init(rawValue: String, concept: String?) throws {
        switch rawValue {
        case "income":
            self = .income
        case "expense":
            self = .expense(title: concept ?? "")
        case "personalUse":
            self = .personalUse
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid rawValue"))
        }
    }
}
