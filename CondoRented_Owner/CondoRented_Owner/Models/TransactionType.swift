//
//  TransactionType.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 30/11/24.
//


enum TransactionType: Codable, CaseIterable, Hashable {
    case income
    case expense(title: String)
    
    static var other: TransactionType {
        .expense(title: "Other")
    }
    
    static var allCases: [TransactionType] {
        [.income,
         .expense(title: "Internet"),
         .expense(title: "Mortgage"),
         .expense(title: "Utilities"),
         .expense(title: "Co-Ownership Fees"),
         other]
    }
    
    var isOther: Bool {
        if TransactionType.other == self {
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
        }
    }
    
    var title: String {
        switch self {
        case .income:
            return "Income"
        case .expense(let title):
            return title
        }
    }
    
    var titleWithType: String {
        switch self {
        case .income:
            return "Income"
        case .expense(let title1):
            return [title1, "(Expense)"].filter({!$0.isEmpty}).joined(separator: " ")
        }
    }
    
    var rawValue: String {
        switch self {
        case .income:
            "income"
        case .expense:
            "expense"
        }
    }
    
    init(rawValue: String, concept: String?) throws {
        switch rawValue {
        case "income":
            self = .income
        case "expense":
            self = .expense(title: concept ?? "")
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid rawValue"))
        }
    }
}
