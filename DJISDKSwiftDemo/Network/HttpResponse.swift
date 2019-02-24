//
//  Response.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 4/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation

struct HttpResponse {
    fileprivate var data: Data
    init(data: Data) {
        self.data = data
    }
}

extension HttpResponse {
    func decode<T: Codable>(_ type: T.Type) -> T? {
        let jsonDecoder = JSONDecoder()
        do {
            let response = try jsonDecoder.decode(T.self, from: data)
            return response
        } catch let error {
            Logger.log(message: "Fail to decode:\(error.localizedDescription)", event: .error)
            return nil
        }
    }
}
