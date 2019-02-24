//
//  IndoorFlyingViewController.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 19/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJISDK
import DJIWidget

class IndoorFlyingViewController: BaseViewController {
    private var isTripodModeEnabled = false
    private var isSettingTripodMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpAsRemoteControllerDelegate()
        self.setConnectionFailSafeBehaviorToHover()
    }
    
    func setUpIndoorFlying(){
        setConnectionFailSafeBehaviorToHover()
        disableReturnToHomeWhenLowBatteries()
    }
    
    func setConnectionFailSafeBehaviorToHover(){
        DJIHelper.fetchFlightController()?.setConnectionFailSafeBehavior(.hover) { (error) in
            if let error = error{
                NotiLogger.log(message: "Fail to set connection fail behavior \(error.localizedDescription)", event: .error)
            }
            NotiLogger.log(message: "Set connection fail behavior to HOVER", event: .info)
        }
    }
    
    func disableReturnToHomeWhenLowBatteries() {
        DJIHelper.fetchFlightController()?.setSmartReturnToHomeEnabled(false) { (error) in
            if let error = error{
                NotiLogger.log(message: "Fail to setSmartReturnToHomeEnabled \(error.localizedDescription)", event: .error)
            }
            NotiLogger.log(message: "Set SmartReturnToHome DISABLED", event: .info)
        }
    }
}

extension IndoorFlyingViewController: DJIRemoteControllerDelegate{
    func setUpAsRemoteControllerDelegate(){
        if let rc = DJIHelper.fetchAircraft()?.remoteController{
            rc.delegate = self
        }
    }
    
    func setFnButtonAsTripodModeToggle(_ state:DJIRCHardwareState){
        // Fn: toggle tripod mode
        if (state.fnButton.isClicked.boolValue && !isSettingTripodMode){
            NotiLogger.log(message: "Fn button clicked", event: .info)
            self.isSettingTripodMode = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isSettingTripodMode = false
            }
            guard let fc = DJIHelper.fetchFlightController() else { return }
            fc.setTripodModeEnabled(!isTripodModeEnabled) { (error) in
                if let error = error{
                    NotiLogger.log(message: error.localizedDescription, event: .error)
                    return
                }
                self.isTripodModeEnabled = !self.isTripodModeEnabled
                NotiLogger.log(message: "isTripodModeEnabled set to \(self.isTripodModeEnabled)", event: .info)
            }
        }
    }
    
    func remoteController(_ rc: DJIRemoteController, didUpdate state: DJIRCHardwareState) {
        self.setFnButtonAsTripodModeToggle(state)
    }
    
    func upload(image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let kerryWarehouseApi = KerryWarehouseApi()
            kerryWarehouseApi.upload(
                withImage: image,
                fileName: "warehouseItem.png", completion: { isSuccess in
                    Logger.log(message: "Upload Success:\(isSuccess)", event: .debug)
            })
        }
    }
    
    @objc
    func takeSnapshot(snapshotImageView:UIImageView, shouldFadeIn: Bool = true) {
        DispatchQueue.main.async {
            DJIVideoPreviewer.instance()?.snapshotPreview({ [weak self] (previewImage) in
                guard let previewImage = previewImage else {
                    Logger.log(message: "Missing preview image", event: .debug)
                    return
                }
                snapshotImageView.image = previewImage
                if (shouldFadeIn){
                    snapshotImageView.fadeInFromLeft(viewType: UIImageView.self)
                }
                
                self?.upload(image: previewImage)
            })
        }
    }
}
