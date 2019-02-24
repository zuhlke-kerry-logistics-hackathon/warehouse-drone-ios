//
//  TestViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 28/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit

final class TestQRViewController: BaseViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let image = UIImage(named: "qr") {
            Logger.log(message: "image view width:\(imageView.frame.width) height:\(imageView.frame.height)", event: .debug)
            let targetSize = CGSize(width: imageView.bounds.width, height: imageView.bounds.height)
            if let resizedImage = image.resize(withSize: targetSize) {
                Logger.log(message: "resized image width:\(resizedImage.cgImage?.width ?? 0) height:\(resizedImage.cgImage?.height ?? 0)", event: .debug)
                imageView.image = resizedImage
            }
        }
        QRCodeHelper.detectQRCodeAndDrawBoundary(imageView: imageView)
    }

    override class func storyboardIdentifier() -> String {
        return "TestQRViewController"
    }
}
