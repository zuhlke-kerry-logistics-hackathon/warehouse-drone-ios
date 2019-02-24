//
//  WarehouseMission.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 13/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK
import DJIWidget

/**
 A collection of Custom TimelineEvent
 */
struct WarehouseMission {
    static let firstShelfHeightInMeter:Float = 0.7
    static let shelfDistanceInMeter:Float =  0.5
    
    static func scanShelf2ToLeft(vc: IndoorFlyingViewController) -> DJIMissionControlTimelineElement {
        let mission = ScanLevel(velocity: 0.3, direction: .Right, lastPosition: "04", level: 2, vc: vc)
        return VirtualStickMission(mission: mission)
    }
    
    static func scanShelf1ToRight(vc: IndoorFlyingViewController) -> DJIMissionControlTimelineElement {
        let mission = ScanLevel(velocity: 0.1, direction: .Right, lastPosition: "03", level: 1, vc: vc)
        return VirtualStickMission(mission: mission)
    }
    
    static func moveRightUntilNewQR() -> DJIMissionControlTimelineElement {
        let mission = MoveUntilQRCodeDetected(velocity: 0.1, direction: .Right)
        return VirtualStickMission(mission: mission)
    }
    
    static func moveToShelf(n:Int) -> DJIMissionControlTimelineElement{
        let toHeight:Float = firstShelfHeightInMeter + Float(n) * shelfDistanceInMeter
        let mission = MoveUpMission(toHeight: toHeight)
        return VirtualStickMission(mission: mission)
    }
    
    static func rotate90CW() -> DJIMissionControlTimelineElement?{
        let mission = RotateMission(angleInCW: 90)
        return VirtualStickMission(mission: mission)
    }
    
    static func moveLeft(v:Double, t:Double = 2) ->DJIMissionControlTimelineElement {
        let mission = MoveMission(velocity: Float(v), direction: .Left, timeout:t)
        return VirtualStickMission(mission: mission)
    }
    
    static func moveRight(v:Double, t:Double = 2) ->DJIMissionControlTimelineElement {
        let mission = MoveMission(velocity: Float(v), direction: .Right, timeout:t)
        return VirtualStickMission(mission: mission)
    }
    
    static func takeSnapshot(vc:WarehouseMissionViewController) -> DJIMissionControlTimelineElement {
        return SnapShotMission(vc:vc)
    }

}
