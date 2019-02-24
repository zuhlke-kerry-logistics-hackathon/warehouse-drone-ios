//
//  KerryWarehouseDefaultImpl.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 11/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit


final class KerryWarehouseDefaultImpl: KerryWarehouseApiImpl, ApiEndpoint {

    var baseUrl: URL {
        return URL(string:"http://10.99.246.93:3000/api/")!
    }

    func fetchWarehouseItems(completion: @escaping((WarehouseItemFetchResponse) -> Void)) {
        let path = "warehouse-item"
        let requestUrl = baseUrl.appendingPathComponent(path)        
        HttpClient.shared.request(
            method: .get,
            url: requestUrl,
            type: WarehouseItemFetchResponse.self) { response in
            completion(response)
        }
    }

    func submit(withWarehouseItem item: WarehouseItem, completion:(@escaping (_ response: WarehouseResponse) -> Void)) {
        let path = "warehouse-item"
        let requestUrl = baseUrl.appendingPathComponent(path)
        let jsonData = try! JSONEncoder().encode(item)

        HttpClient.shared.request(
            method: .post,
            url: requestUrl,
            type: WarehouseResponse.self,
            parameter: jsonData
        ) { (warehouseResponse) in
            completion(warehouseResponse)
        }
    }

    func upload(withImage image: UIImage, fileName: String, completion: @escaping ((WarehouseResponse) -> Void)) {
        let path = "warehouse-item/upload"
        let requestUrl = baseUrl.appendingPathComponent(path)

        HttpClient.shared.uploadImage(
            url: requestUrl,
            type: WarehouseResponse.self,
            paramName: "file",
            fileName: fileName,
            image: image
        ) { (warehouseResponse) in
            completion(warehouseResponse)
        }
    }
}


