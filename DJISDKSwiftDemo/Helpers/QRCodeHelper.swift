//
//  QRCodeHelper.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 25/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//
import UIKit

final class QRCodeHelper {
    static func detectQRCodeAndDrawBoundary(imageView: UIImageView) -> [CIQRCodeFeature]? {
        guard let image = imageView.image else {
            Logger.log(message: "Missing image", event: .error)
            return nil
        }

        // prepare transform to convert CI coordinate system to iOS coordinate system
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -imageView.bounds.height)

        guard let features = QRCodeHelper.detectQRCode(image), !features.isEmpty else {
            Logger.log(message: "No QR Code", event: .debug)
            return nil
        }

        _ = imageView.subviews.map { subview in
            if subview is BorderView {
                subview.removeFromSuperview()
            }
        }

        for feature in features {
            // apply the transformation to convert the coordinate system
            let transformedRect = feature.bounds.applying(transform)
            let borderView = BorderView(frame: transformedRect)
            imageView.addSubview(borderView)
        }

        return features
    }

    static func detectQRCode(_ image: UIImage) -> [CIQRCodeFeature]? {
        guard let ciImage = CIImage.init(image: image) else {
            return nil
        }
        var options: [String: Any]
        let context = CIContext()
        options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        } else {
            options = [CIDetectorImageOrientation: 1]
        }
        let features = qrDetector?.features(in: ciImage, options: options)
        let qrFeatures = features?.compactMap { $0 as? CIQRCodeFeature }
        return qrFeatures
    }
}
