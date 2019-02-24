//
//  Timer.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 20/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation

extension Timer {
    /**
     Set time out
     */
    func settimeoutIn(_ second:TimeInterval, completionHandler: @escaping ()->()){
        DispatchQueue.main.asyncAfter(deadline: .now() + second, execute: {
            self.invalidate()
            completionHandler()
        })
    }
}
