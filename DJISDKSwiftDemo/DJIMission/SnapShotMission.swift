//
//  SnapShotMission.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 13/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK
import DJIWidget

class SnapShotMission: NSObject, DJIMissionControlTimelineElement {
    static func takeSnapShot(vc:WarehouseMissionViewController, completionHandler:  @escaping () -> Void) {
        Logger.log(message: "takeSnapShot triggered", event: .info)
        if let previwer = DJIVideoPreviewer.instance() {
            Logger.log(message: "Got previewer", event: .info)
            previwer.snapshotPreview({ (previewImage) in
                guard let previewImage = previewImage else {
                    Logger.log(message: "Missing preview image", event: .error)
                    completionHandler()
                    return
                }
                Logger.log(message: "Taking SnapShot", event: .info)
                vc.lastSnapshotView.image = previewImage
                let kerryWarehouseApi = KerryWarehouseApi()
                kerryWarehouseApi.upload(
                    withImage: previewImage,
                    fileName: "warehouseItem.png",
                    completion: { (isUploadSuccess) in
                    Logger.log(message: "is image upload success:\(isUploadSuccess)", event: .debug)
                })
                completionHandler()
            })
        }else{
                Logger.log(message: "Cannot get previewer", event: .error)
                completionHandler()
        }
    }
    
    func checkValidity() -> Error? {
        return nil
    }
    
    let vc: WarehouseMissionViewController
    
    init(vc: WarehouseMissionViewController) {
        self.vc = vc
    }
    
    func run() {
        DJISDKManager.missionControl()?.elementDidStartRunning(self);
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            SnapShotMission.takeSnapShot(vc:self.vc, completionHandler: {
                DJISDKManager.missionControl()?.element(self, didFinishRunningWithError: nil)
            })
        }
    }
    
    func stopRun() {
        DJISDKManager.missionControl()?.elementDidStopRunning(self)
    }
    
    func isPausable() -> Bool {
        return false;
    }
}

