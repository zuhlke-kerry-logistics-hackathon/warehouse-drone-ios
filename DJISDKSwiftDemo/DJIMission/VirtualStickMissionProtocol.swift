//
//  VirtualStickMissionProtocol.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 20/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation


protocol VirtualStickMissionProtocol {
    var timeout: TimeInterval { get set }
    
    func task()
    func shouldStop(completion:@escaping ((Bool) -> Void))
    func willStart()
}

extension VirtualStickMissionProtocol {
    func shouldStop(completion: @escaping ((Bool) -> Void)) {
    }
    func willStart(){}
}
