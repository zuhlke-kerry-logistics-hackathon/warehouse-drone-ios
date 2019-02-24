//
//  WarehouseFetchResponseTest.swift
//  DJI-WarehouseTests
//
//  Created by Brian Chung on 14/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import XCTest
@testable import DJI_Warehouse

class WarehouseItemFetchResponseTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJsonDecode() {
        let jsonData = FileHelper.readFile(fileName: "fetchWarehouseItem", ofType: "json")
        guard let decodedModel = try? JSONDecoder().decode(WarehouseItemFetchResponse.self, from: jsonData) else {
            assertionFailure("Unable to decode json to object")
            return
        }
        Logger.log(message: "decodedModel:\(decodedModel)", event: .debug)
    }
}

