//
//  FetchWarehouseItemResponse.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 14/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation

struct WarehouseItemFetchResponse: Codable {
    var status: String
    var data: [WarehouseItem]
}
