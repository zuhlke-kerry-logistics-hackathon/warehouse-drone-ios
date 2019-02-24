//
//  KerryWarehouseApi.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 11/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

protocol KerryWarehouseApiImpl {
    func fetchWarehouseItems(completion:(@escaping (_ items: WarehouseItemFetchResponse) -> Void))
    func submit(withWarehouseItem: WarehouseItem, completion:(@escaping (_ response: WarehouseResponse) -> Void))
    func upload(withImage: UIImage, fileName: String, completion:(@escaping (_ response: WarehouseResponse) -> Void))
}

final class KerryWarehouseApi {
    private var implementation: KerryWarehouseApiImpl

    init(withImpl: KerryWarehouseApiImpl = KerryWarehouseDefaultImpl()) {
        self.implementation = withImpl
    }

    func fetchWarehouseItem(
        completion:@escaping ((_ model: WarehouseItemFetchResponse) -> Void)) {
        implementation.fetchWarehouseItems(completion: { response in
            completion(response)
        })
    }

    func submit(
        withWarehouseItem item: WarehouseItem,
        completion:(@escaping (_ isSuccess: Bool) -> Void)) {
        implementation.submit(withWarehouseItem: item, completion: { warehouseResponse in
            let isSuccess = warehouseResponse.status == "success"
            completion(isSuccess)
        })
    }

    func upload(
        withImage image: UIImage,
        fileName: String,
        completion:(@escaping (_ isSuccess: Bool) -> Void)) {
        implementation.upload(withImage: image, fileName: fileName) { warehouseResponse in
            let isSuccess = warehouseResponse.status == "success"
            completion(isSuccess)
        }
    }
}
