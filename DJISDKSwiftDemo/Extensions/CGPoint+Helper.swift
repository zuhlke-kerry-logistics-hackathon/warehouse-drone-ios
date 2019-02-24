//
//  CGPoint+Helper.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 31/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = Double(bearingRadians) * (180 / Double.pi);
        while bearingDegrees < 0 {
            bearingDegrees += 360
        }
        return CGFloat(bearingDegrees)
    }
}
