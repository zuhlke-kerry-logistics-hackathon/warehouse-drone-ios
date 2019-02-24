//
//  MoveMission.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 11/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJIWidget

class RotateMission: VirtualStickMissionProtocol {
    var angleInCW: Float
    var timeout:TimeInterval = 8
    var heading: Double?
    
    init(angleInCW: Float) {
        self.angleInCW = angleInCW
    }
    
    // Use real time heading for rotation
    func willStart() {
        guard let heading =  DJIHelper.getHeading() else {
            return
        };
        self.heading = heading
    }
    
    func task() {
        if let heading = self.heading{
            AutoFlyHelper.rotateDrone(withAngleCW: 90, heading: heading)
        }
    }
}
