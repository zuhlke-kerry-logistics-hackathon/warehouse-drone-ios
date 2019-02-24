//
//  DJIVideoPreviewerHelper.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 23/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK
import DJIWidget

extension DJIVideoPreviewer {
    func setupVideoPreviewer(previewViewer: UIView?, listener: DJIVideoFeedListener) {
        if let previewViewer = previewViewer{
            DJIVideoPreviewer.instance()?.setView(previewViewer)
        }
        
        guard let product = DJISDKManager.product() else {
            NotiLogger.log(message: "Missing product", event: .error)
            return
        }

        if product.isSecondaryVideoFeedModel() {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(listener, with: nil)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(listener, with: nil)
        }        
        DJIVideoPreviewer.instance()?.start()
    }

    func removeVideoPreviewer(listener: DJIVideoFeedListener) {
        DJIVideoPreviewer.instance()?.unSetView()

        guard let product = DJISDKManager.product() else {
            NotiLogger.log(message: "Missing product", event: .error)
            return
        }

        if product.isSecondaryVideoFeedModel() {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(listener)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(listener)
        }
    }

    func pointToStreamSpace(point: CGPoint, withView: UIView) -> CGPoint? {
        guard let videoPreviewer = DJIVideoPreviewer.instance() else {
            NotiLogger.log(message: "Missing previewer", event: .error)
            return nil
        }
        let videoFrame = videoPreviewer.frame
        let videoPoint = videoPreviewer.convert(point, toVideoViewFrom: withView)
        let normalized = CGPoint(x: videoPoint.x / videoFrame.size.width , y: videoPoint.y / videoFrame.size.height)
        return normalized
    }
}
