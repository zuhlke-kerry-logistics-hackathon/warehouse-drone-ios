//
//  DroneState.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 19/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJIWidget
import DJISDK

extension DJIConnectionFailSafeBehavior: CustomStringConvertible{
    public var description:String {
        switch self {
        case .goHome:
            return "goHome"
        case .hover:
            return "hover"
        case .landing:
            return "landing"
        case .unknown:
            return "unknown"
        default:
            return "Nope"
        }
    }
}

class DroneState: UIView, DJIFlightControllerDelegate{
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var statusIndicator: UIView!
    
    func commonInit(){
        Bundle.main.loadNibNamed("DroneStateView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        DJIHelper.fetchFlightController()?.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        let isOk = (abs(state.velocityX) < 0.1) && (abs(state.velocityY) < 0.1)  && (abs(state.velocityZ) < 0.1)
        if (isOk) {
            self.statusIndicator.backgroundColor = UIColor.green
        }else{
           self.statusIndicator.backgroundColor = UIColor.red
        }
    }
}
