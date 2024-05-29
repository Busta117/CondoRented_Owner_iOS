//
//  CondoRented_OwnerTests.swift
//  CondoRented_OwnerTests
//
//  Created by Santiago Bustamante on 17/04/24.
//

import CondoRented_Owner
import XCTest
import SwiftData

final class CondoRented_OwnerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testExample() throws {
        
//        let model = ModelContainer.sharedInMemoryModelContainer
//        
//        let c = Currency(id: "COP1")
//        let l1 = Listing(title: "Distrio Vera")
//        let l2 = Listing(title: "La Riviere")
//        let t1 = Transaction(amountMicros: 2_000_000_000, currency: c, listing: l1, type: .notPaid)
//        let t2 = Transaction(amountMicros: 500_000_000, currency: c, listing: l1, type: .notPaid)
//        let t3 = Transaction(amountMicros: 70_000_000, currency: c, listing: l1, type: .expense, expenseConcept: "aseo", expensePaidByOwner: false)
//        
//        let tras: [Transaction] = [t1,t2,t3]
//        
//        let cosa = TransactionHelper.splitByListing(transactions: tras)
//        
//        print(cosa)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
