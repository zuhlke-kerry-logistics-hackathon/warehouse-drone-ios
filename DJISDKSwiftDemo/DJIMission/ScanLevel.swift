//
//  ScanLevel.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 21/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJIWidget


class ScanLevel: MoveMission {
    var isTimeForSnapshot = false
    var detectedQrCodesOfThisLevel:[String] = []
    var lastPosition: String
    var isTakingSnapshot = false
    var level:Int
    var vc: IndoorFlyingViewController
    init(velocity:Float, direction: MoveMissionDirection, lastPosition: String, level: Int, vc: IndoorFlyingViewController) {
        self.vc = vc
        self.lastPosition = lastPosition
        self.level = level
        super.init(velocity: velocity, direction: direction, timeout: 500)
    }
    
    func takeSnapshot(){
        NotiLogger.log(message: "Taking one snapshot", event: .info)
        if let vc = vc as? WarehouseMissionViewController{
            self.vc.takeSnapshot(snapshotImageView: vc.lastSnapshotView, shouldFadeIn: false)
        }
    }
    
    override func task(){
        if (!isTakingSnapshot && !isTimeForSnapshot){
            super.task()
            Logger.log(message: "flying", event: .info)
            return
        }
        
        if (!isTakingSnapshot && isTimeForSnapshot) {
            Logger.log(message: "Snap shot mode", event: .info)
            NotiLogger.log(message: "Should stop for 2s", event: .info)
            self.isTakingSnapshot = true
            self.takeSnapshot()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                NotiLogger.log(message: "Continue", event: .info)
                self.isTimeForSnapshot = false
                self.isTakingSnapshot = false
            }
        }
    }
    
    // Keep scanning for qr codes, when last qr code is scanned stop task, when new qr code fo this level scanned, take a pause
    override func shouldStop(completion:@escaping ((Bool) -> Void)) {
        DJIVideoPreviewer.instance()?.snapshotPreview({ [weak self] (previewImage) in
            guard let previewImage = previewImage else {
                Logger.log(message: "Missing preview image", event: .error)
                completion(false)
                return
            }
            guard let qrFeatures = QRCodeHelper.detectQRCode(previewImage),!qrFeatures.isEmpty else {
                completion(false)
                return
            }
            
            guard let `self` = self else{
                completion(false)
                return
            }

            for qrFeature in qrFeatures{
                // Check if qr code is last required to scan
                guard let messageString = qrFeature.messageString else{
                    continue
                }
                //TODO: Check if it is a location
                
                
                // Return if the qr code scanned is not belonged to this level
                let isBelongedToThisLevel = messageString.suffix(3).prefix(1) == "\(self.level)"
                guard isBelongedToThisLevel else {
                    continue
                }
                
                // Return if the qr code scanned of this levelhas been stored
                guard !self.detectedQrCodesOfThisLevel.contains(messageString) else {
                    continue
                }
               // New qr code that belons to this level
                self.detectedQrCodesOfThisLevel.append(messageString)
                NotiLogger.log(message: "\(messageString) stored", event: .info)
                // If last qr code is reached, quit
                if (messageString.suffix(2) == self.lastPosition){
                    NotiLogger.log(message: "Mission finished: Last qr code of this levl found", event: .info)
                    NotiLogger.log(message: "All scanned qr codes: \(self.detectedQrCodesOfThisLevel)", event: .info)
                    self.isTimeForSnapshot = true
                    // Leave some time for snapshot
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        completion(true)
                    }
                    return
                }
                
                // If it's not last qr code, pause and take picture
                self.isTimeForSnapshot = true
                
            }
            completion(false)
        })
    }
}
