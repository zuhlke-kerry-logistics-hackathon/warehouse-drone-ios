//
//  MoveMission'.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 20/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation


class MoveUpMission: VirtualStickMissionProtocol{
    var timeout: TimeInterval = 8
    private var targetInM: Float
    // TODO: Invalidate timer when reaching target height
    init(toHeight:Float) {
        self.targetInM = toHeight
    }
    
    func task() {
        AutoFlyHelper.moveUp(targetInM: self.targetInM)
    }
}

class MoveMission: VirtualStickMissionProtocol {
    var timeout: TimeInterval = 5
    var velocity: Float
    
    init(velocity:Float, direction: MoveMissionDirection, timeout: TimeInterval?) {
        switch direction {
            case .Right:
                self.velocity = velocity
            case .Left:
                self.velocity = velocity * -1
            }
        if let timeout = timeout {
            self.timeout = timeout
        }
    }
    
    func task() {
        AutoFlyHelper.moveRight(withVelocityInMeterPerSecond: velocity)
    }
    
    func shouldStop(completion: @escaping ((Bool) -> Void)) {
        completion(false)
    }
}

enum MoveMissionDirection {
    case Right
    case Left
}

