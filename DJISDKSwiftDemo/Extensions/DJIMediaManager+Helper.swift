//
//  DJIMediaManager+Helper.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 24/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import DJISDK

extension DJIMediaManager {
    func isSdCardBusy() -> Bool {
        let sdCardState = self.sdCardFileListState
        return sdCardState == .syncing || sdCardState == .deleting
    }
}
