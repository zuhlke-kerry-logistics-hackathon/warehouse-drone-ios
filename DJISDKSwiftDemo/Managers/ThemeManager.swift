//
//  ThemeManager.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 31/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

final class ThemeManager {
    static let shared = ThemeManager()

    private init(){ }

    func applyTheme() {
        applyNavigationBarTheme()
    }

    private func applyNavigationBarTheme() {
        UINavigationBar.appearance().barTintColor = .gray
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }
}
