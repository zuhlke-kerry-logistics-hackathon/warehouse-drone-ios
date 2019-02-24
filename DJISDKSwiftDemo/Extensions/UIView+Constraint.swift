//
//  UIView+Constraint.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 19/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func findConstraint<V: UIView>(layoutAttribute: NSLayoutConstraint.Attribute, viewType: V.Type) -> NSLayoutConstraint? {
        guard let constraints = superview?.constraints else {
            return nil
        }
        for constraint in constraints where itemMatch(constraint: constraint, layoutAttribute: layoutAttribute, viewType: viewType) {
            return constraint
        }
        return nil
    }

    private func itemMatch<V: UIView>(
        constraint: NSLayoutConstraint,
        layoutAttribute: NSLayoutConstraint.Attribute,
        viewType: V.Type) -> Bool {
        if let firstItem = constraint.firstItem {
            return isItemMatch(withView: firstItem, constraint: constraint, layoutAttribute: layoutAttribute, viewType: viewType)
        }
        if let secondItem = constraint.secondItem {
            return isItemMatch(withView: secondItem, constraint: constraint, layoutAttribute: layoutAttribute, viewType: viewType)
        }
        return false
    }

    private func isItemMatch<V: UIView>(withView view: AnyObject, constraint: NSLayoutConstraint, layoutAttribute: NSLayoutConstraint.Attribute, viewType: V.Type) -> Bool {
        guard let view = view as? V,
            view == self,
            constraint.firstAttribute == layoutAttribute else {
                return false
        }
        return true
    }
}
