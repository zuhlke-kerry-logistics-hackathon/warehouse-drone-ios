//
//  BorderView.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 1/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit

class BorderView: UIView {
    var strokeColor: UIColor {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var borderWidth: CGFloat {
        didSet {
            self.setNeedsDisplay()
        }
    }

    init(frame: CGRect, strokeColor: UIColor = UIColor.red, borderWidth: CGFloat = 2.0) {
        self.strokeColor = strokeColor
        self.borderWidth = borderWidth
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let border = UIBezierPath(rect: rect)
        strokeColor.setStroke()
        border.lineWidth = borderWidth
        border.stroke()
    }
}
