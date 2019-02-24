//
//  DroneCameraViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 22/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit
import DJISDK
import DJIWidget
import CoreML
import Vision
import ImageIO

class DroneCameraViewController: IndoorFlyingViewController {
    @IBOutlet var previewView: UIView!
    @IBOutlet var snapshotImageView: UIImageView!
    private var isTakingSnapshot = false
    fileprivate var cameraButtonItem: UIBarButtonItem!
    fileprivate var storedQRFeatures = [String: CIQRCodeFeature]()
    fileprivate var videoPreviewViewController: VideoPreviewViewController!
    override class func storyboardIdentifier() -> String {
        return "DroneCameraViewController"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.disableColision()
        
        if let rc = DJIHelper.fetchAircraft()?.remoteController{
            rc.delegate = self
        }
    }

    private func disableColision() {
        DJIHelper.fetchFlightController()?.flightAssistant?.setCollisionAvoidanceEnabled(
            false,
            withCompletion: { (error) in
                if let error = error{
                    Logger.log(message: "Cannot disable collision avoidanced \(error)", event: .error)
                }
                Logger.log(message: "Disabled collision avoidanced", event: .error)
            }
        )
    }

    private func setupUI() {
        videoPreviewViewController = VideoPreviewViewController()
        addChildViewController(videoPreviewViewController, toView: previewView)

        let snapShotModeButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(captureButtonDidTap(_:)))
        self.navigationItem.rightBarButtonItems = [snapShotModeButtonItem]
        self.snapshotImageView.backgroundColor = UIColor.gray
        self.snapshotImageView.fadeOutToLeft(animated: false, viewType: UIImageView.self)
    }

    override func remoteController(_ rc: DJIRemoteController, didUpdate state: DJIRCHardwareState) {
        super.remoteController(rc, didUpdate: state)
        self.setRecordButtonAsSnapshotTrigger(state)
    }

    // MARK: DJIRemoteControllerDelegate
    func setRecordButtonAsSnapshotTrigger(_ state: DJIRCHardwareState) {
        if (state.recordButton.isClicked.boolValue && !self.isTakingSnapshot) {
            NotiLogger.log(message: "Shutter button clicked", event: .info)

            // Sometimes two updates is received for one click
            self.isTakingSnapshot = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isTakingSnapshot = false
            }

            snapshotImageView.image = nil
            takeSnapshot(snapshotImageView: snapshotImageView)
        }
    }

    @objc
    private func captureButtonDidTap(_ sender: UIBarButtonItem) {
        takeSnapshot(snapshotImageView: snapshotImageView)
    }

	func shootPhoto() {
        takeSnapshot(snapshotImageView: snapshotImageView)
    }

//    @objc
//    private func takeSnapshot() {
//        DispatchQueue.main.async {
//            DJIVideoPreviewer.instance()?.snapshotPreview({ [weak self] (previewImage) in
//                guard let previewImage = previewImage else {
//                    Logger.log(message: "Missing preview image", event: .debug)
//                    return
//                }
//                self?.snapshotImageView.image = previewImage
//                self?.snapshotImageView.fadeInFromLeft(viewType: UIImageView.self)
//                self?.upload(image: previewImage)
//            })
//        }
//    }

    private func updateStoredQRFeatureIfNeeded(_ qrCodeFeature: CIQRCodeFeature) {
        guard let message = qrCodeFeature.messageString,
            storedQRFeatures[message] == nil else {
            return
        }
        storedQRFeatures[message] = qrCodeFeature
    }


}
