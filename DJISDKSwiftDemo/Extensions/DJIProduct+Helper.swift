//
//  DJIProductHelper.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 23/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK

extension DJIBaseProduct {
    var secondaryVideoFeedWhiteList: [String] {
        return [
            DJIAircraftModelNameA3,
            DJIAircraftModelNameN3,
            DJIAircraftModelNameMatrice600,
            DJIAircraftModelNameMatrice600Pro,
        ]
    }

    func isSecondaryVideoFeedModel() -> Bool {
        guard let model = self.model else {
            debugPrint("Missing model name")
            return false
        }
        return secondaryVideoFeedWhiteList.contains(model)
    }

    func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }

        if product is DJIAircraft {
            return (product as? DJIAircraft)?.camera
        } else if product is DJIHandheld {
            return (product as? DJIHandheld)?.camera
        }
        return nil
    }
    
    
}
