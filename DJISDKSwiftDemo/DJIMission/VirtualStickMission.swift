//
//  VirtualStickMission.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 13/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK
import DJIWidget

class VirtualStickMission: NSObject, DJIMissionControlTimelineElement{
    private var mission: VirtualStickMissionProtocol
    private var timer: Timer!
    
    init(mission: VirtualStickMissionProtocol) {
        self.mission = mission
    }
    
    func willRun() {
        self.mission.willStart()
        // Send signal to flight controller at 10Hz
        self.timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] (timer) in
            guard let `self` = self else {
                NotiLogger.log(message: "No self", event: .error)
                return
            }
            
            self.mission.shouldStop(completion: { (shouldStop) in
                // Trigger custom default stop
                guard shouldStop else { return }
                timer.invalidate()
                self.finish()
                return
            })
            self.mission.task()
        }
    }
    
    // Finish running mission if times out or condition met
    // Run Only Once presummably
    func run() {
        // Tell timeline mission is running
        DJISDKManager.missionControl()?.elementDidStartRunning(self);
        NotiLogger.log(message: "Began", event: .info)
        // Fire timer
        RunLoop.current.add(timer, forMode: .default)
        timer.fire()
        
        // Set timeout for timer
        timer.settimeoutIn(mission.timeout) {
            self.finish()
        }
    }
    
    func stopRun() {
        NotiLogger.log(message: "Stopped", event: .info)
        DJISDKManager.missionControl()?.elementDidStopRunning(self)
        timer.invalidate()
    }
    
    func isPausable() -> Bool {
        return false;
    }
    
    func finish() {
        NotiLogger.log(message: "Finished", event: .info)
        DJISDKManager.missionControl()?.element(self, didFinishRunningWithError: nil)
    }
    
    func checkValidity() -> Error? {
        return nil;
    }
}
