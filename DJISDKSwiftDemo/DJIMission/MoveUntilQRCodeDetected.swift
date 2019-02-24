//
//  MoveUntilQRCodeDetected.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 20/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJIWidget

class MoveUntilQRCodeDetected: MoveMission {
    
    init(velocity:Float, direction: MoveMissionDirection) {
        super.init(velocity: velocity, direction: direction, timeout: 500)
    }
    
    override func shouldStop(completion:@escaping ((Bool) -> Void)) {
        DJIVideoPreviewer.instance()?.snapshotPreview({  (previewImage) in
            guard let previewImage = previewImage else {
                NotiLogger.log(message: "Missing preview image", event: .error)
                completion(false)
                return
            }
            if let qrFeatures = QRCodeHelper.detectQRCode(previewImage),
                !qrFeatures.isEmpty {
                NotiLogger.log(message: "Stopped drone becoz qr found", event: .info)
                completion(true)
            }
            completion(false)
        })
    }
}
