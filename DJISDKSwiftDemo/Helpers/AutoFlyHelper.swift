//
//  AutoFlyHelper.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 11/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK

/**
 A collection of virtual-stick-commands that can be sent at a rate of 10Hz to flight controller
 */
final class AutoFlyHelper {
    
 
    static func moveRight(withVelocityInMeterPerSecond v:Float){
        guard let fc = DJIHelper.fetchFlightController() else{
            debugPrint("Cannot get fc")
            return;
        }
        fc.rollPitchCoordinateSystem = .body
        fc.rollPitchControlMode = .velocity
        fc.yawControlMode = .angularVelocity
        fc.verticalControlMode = .velocity
        fc.isVirtualStickAdvancedModeEnabled = true
        
        let controlData = DJIVirtualStickFlightControlData(pitch: v, roll: 0, yaw: 0, verticalThrottle: 0 )
        fc.send(controlData) { (error) in
            Logger.log(message: "command sent", event: .info)
            if let error = error {
                let message = error.localizedDescription;
                Logger.log(message: message, event: .error)
            }
        }
    }
    
    static func rotateDrone(withAngleCW: Float, heading:Double){
        var angle = Float(heading) + withAngleCW
        if (angle > 180 ){
            angle -= 360
        }else if ( angle < -180){
            angle += 360
        }
        guard let fc = DJIHelper.fetchFlightController() else{
            debugPrint("Cannot get fc")
            return;
        }
        let controlData = DJIVirtualStickFlightControlData(pitch: 0, roll: 0, yaw: angle, verticalThrottle: 0 )
        fc.yawControlMode = .angle
        fc.rollPitchCoordinateSystem = .body
        fc.isVirtualStickAdvancedModeEnabled = true
        fc.send(controlData) { (error) in
            if let error = error {
                let message = error.localizedDescription;
                Logger.log(message: message, event: .error)
            }
        }
    }
    
    static func moveUp(targetInM: Float) {
        guard let fc = DJIHelper.fetchFlightController() else{
            debugPrint("Cannot get fc")
            return;
        }
        fc.verticalControlMode = .position
        fc.yawControlMode = .angularVelocity
        let controlData = DJIVirtualStickFlightControlData(pitch: 0, roll: 0, yaw: 0, verticalThrottle:  targetInM )
        fc.isVirtualStickAdvancedModeEnabled = true
        fc.send(controlData) { (error) in
            if let error = error {
                let message = error.localizedDescription;
                Logger.log(message: message, event: .error)
            }
        }
    }
    
    static func moveUp(relativeInM: Float){
        guard let key = DJIFlightControllerKey(param: DJIFlightControllerParamAltitudeInMeters) else{
            Logger.log(message: "Fail to get key", event: .error)
            return
        }
        guard let currentAltitude = DJISDKManager.keyManager()?.getValueFor(key)?.doubleValue else{
            Logger.log(message: "Fail to get currentAltitude", event: .error)
            return
        }
        
        let targetInM = relativeInM + Float(currentAltitude)
        moveUp(targetInM: targetInM)
    }
}
