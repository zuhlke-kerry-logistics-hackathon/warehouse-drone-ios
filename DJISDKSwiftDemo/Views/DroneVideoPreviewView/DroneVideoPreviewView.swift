//
//  DroneVideoPreviewView.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 20/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJISDK
import DJIWidget

class DroneVideoPreviewView: UIView, DJIVideoFeedListener {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var previewView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit(){
        Bundle.main.loadNibNamed("DroneVideoPreviewView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor.black
    }

    override open var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            if contentView != nil {
                contentView.backgroundColor = newValue
                previewView.backgroundColor = newValue
            }
            super.backgroundColor = newValue
        }
    }

    func setup() {
        DJIVideoPreviewer.instance()?.setupVideoPreviewer(
            previewViewer: self.previewView,
            listener: self
        )
    }

    func stop() {
        DJIVideoPreviewer.instance()?.removeVideoPreviewer(listener: self)
    }

    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        let videoPreviewer = DJIVideoPreviewer.instance()
        let tmpVideoData = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.count)
        videoData.copyBytes(to: tmpVideoData, count: videoData.count)
        videoPreviewer?.push(tmpVideoData, length: Int32(videoData.count))
    }
}
