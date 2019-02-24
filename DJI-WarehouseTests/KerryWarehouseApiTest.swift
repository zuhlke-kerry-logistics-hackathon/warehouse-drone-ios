//
//  KerryWarehouseApiTest.swift
//  DJI-WarehouseTests
//
//  Created by Brian Chung on 11/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import XCTest
@testable import DJI_Warehouse

class KerryWarehouseApiTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchWarehouseItem() {
        let expectation = XCTestExpectation(description: "Fetch Warehouse Items")
        let kerryWarehouseApi = KerryWarehouseApi()
        kerryWarehouseApi.fetchWarehouseItem { response in
            Logger.log(message: "Model:\(response)", event: .debug)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testUpload() {
        let uploadImage = UIImage(
            contentsOfFile:Bundle(for: type(of: self)).path(
                forResource: "warehouseItemSample", ofType: "jpg")!)!
        let expectation = XCTestExpectation(description: "Upload Warehouse Image")
        let kerryWarehouseApi = KerryWarehouseApi()
        kerryWarehouseApi.upload(
        withImage: uploadImage,
        fileName: "warehouseItem.png", completion: { isSuccess in
            Logger.log(message: "Upload Success:\(isSuccess)", event: .debug)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
}
