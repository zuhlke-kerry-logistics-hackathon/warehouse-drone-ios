//
//  FileHelper.swift
//  DJI-WarehouseTests
//
//  Created by Brian Chung on 14/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation

final class FileHelper {
    static func readFile(fileName: String, ofType: String) -> Data {
        guard let filePath = Bundle(for: FileHelper.self).path(forResource: fileName, ofType: ofType) else {
            fatalError("Dummy json file not found")
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath), options: .alwaysMapped) else {
            fatalError("Unable to read JSON data")
        }

        return data
    }
}
