//
//  UIView+Animation.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 19/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    private struct AssociatedKeys {
        static var originalLeadingValue = "originalLeadingValue"
    }

    fileprivate var originalLeadingValue: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.originalLeadingValue) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.originalLeadingValue,
                newValue as CGFloat,
                .OBJC_ASSOCIATION_ASSIGN
            )
        }
    }

    func fadeOutToLeft<V: UIView>(animated: Bool, viewType: V.Type) {
        guard let leadingConstraint = findConstraint(layoutAttribute: .leading, viewType: viewType) else {
            return
        }
        originalLeadingValue = leadingConstraint.constant
        let width = frame.width
        let newLeadingValue = -(originalLeadingValue + width)
        if animated {
            UIView.animate(
                withDuration: 0.7,
                animations: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    leadingConstraint.constant = newLeadingValue
                    self.alpha = 0.0
                    self.superview?.layoutIfNeeded()
                },
                completion: nil)
        } else {
            leadingConstraint.constant = newLeadingValue
            self.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }
    }

    func fadeInFromLeft<V: UIView>(viewType: V.Type, shouldFadeOut: Bool = true) {
        guard let leadingConstraint = findConstraint(layoutAttribute: .leading, viewType: viewType) else {
            return
        }
        UIView.animate(
            withDuration: 0.7,
            animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.alpha = 1.0
                leadingConstraint.constant = self.originalLeadingValue
                self.superview?.layoutIfNeeded()
            },
            completion: { [weak self] (isCompleted) in
                guard isCompleted, shouldFadeOut else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self?.fadeOutToLeft(animated: true, viewType: UIImageView.self)
                })
        })
    }
}
