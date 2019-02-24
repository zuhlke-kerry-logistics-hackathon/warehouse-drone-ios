//
//  UIViewController+Helper.swift
//  DJISDKSwiftDemo
//
//  Created by Brian Chung on 23/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?, animated: Bool = true) {
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        self.present(alertController, animated: animated, completion: nil)
    }

    func addChildViewController(_ viewController: UIViewController, toView: UIView?) {
        addChild(viewController)
        let targetView: UIView! = toView ?? view
        viewController.view.frame = targetView.frame
        targetView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func removeChildViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
