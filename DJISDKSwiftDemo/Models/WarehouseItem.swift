//
//  QRMeta.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 11/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation

struct WarehouseItem: Codable {
    var location: String
    var productId: String
    var time: String

    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.locale = Locale(identifier: "en_US")
        df.dateFormat = "hh:mm:ss"
        return df
    }()

    init(location: String, productId: String) {
        let currentDateTime = Date()
        self.time = WarehouseItem.formatter.string(from: currentDateTime)
        self.location = location
        self.productId = productId
    }
}
