//
//  UIViewController+Navigation.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 24/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentPreviewImageViewController(animated: Bool = true) {
        guard let previewImageVc = self.storyboard?.instantiateViewController(withIdentifier: PreviewImageViewController.storyboardIdentifier) as? PreviewImageViewController else {
            return
        }        
        self.present(previewImageVc, animated: true, completion: nil)
    }

    func presentQRCodeList(qrCodeFeatures: [CIQRCodeFeature], animated: Bool = true) {
        guard let qrCodeListVc = self.storyboard?.instantiateViewController(withIdentifier: QRCodeListViewController.storyboardIdentifier) as? QRCodeListViewController else {
            return
        }
        qrCodeListVc.dataSource = qrCodeFeatures
        self.present(qrCodeListVc, animated: true, completion: nil)
    }

    func navigateToViewController(storyboardIdentifier: String, aniamted: Bool = true) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: storyboardIdentifier) else {
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


