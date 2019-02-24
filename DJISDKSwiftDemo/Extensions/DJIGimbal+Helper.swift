//
//  DJIGimbal+Helper.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 30/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK
import DJIWidget

extension DJIGimbal {
    func face(direction:GimbalRotationDirection, handleErrorVC: UIViewController) {
        let rotation = DJIGimbalRotation(pitchValue: direction.rawValue, rollValue: nil, yawValue:nil, time: 0.3, mode: .absoluteAngle)
        self.rotate(with: rotation) { (error) in
            if let error = error {
                DJIHelper.showAlertView(vc: handleErrorVC, title: "Oops", message: error.localizedDescription)
            }
        }
    }
    
    func printPitchCapabilities() {
        if let ajustPitchCapability = self.capabilities[DJIGimbalParamAdjustPitch] as? DJIParamCapabilityMinMax {
            print("ajustPitch isSupported: \(ajustPitchCapability.isSupported)")
            print("ajustPitch Max: \(String(describing: ajustPitchCapability.max))")
            print("ajustPitch Min: \(String(describing: ajustPitchCapability.min))")
        }
    }
}


enum GimbalRotationDirection:NSNumber {
    case Downward = -90
    case Forward = 0
}
