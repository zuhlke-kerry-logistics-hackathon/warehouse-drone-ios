//
//  MenuListCellViewModel.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 31/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation

struct MenuListCellViewModel {
    enum MenuType {
        case warehouseMission
        case autoFly
        case qrCamera        
        case info
        case mission
        case testQr
        case testRc

        func toStoryboardIdentifier() -> String {
            switch self {
            case .warehouseMission:
                return WarehouseMissionViewController.storyboardIdentifier()
            case .autoFly:
                return AutoFlyViewController.storyboardIdentifier()
            case .qrCamera:
                return DroneCameraViewController.storyboardIdentifier()
            case .testQr:
                return TestQRViewController.storyboardIdentifier()
            case .info:
                return KeyedInterfaceViewController.storyboardIdentifier()
            case .mission:
                return TimelineMissionViewController.storyboardIdentifier()
            case .testRc:
                return TestRemoteControllerViewController.storyboardIdentifier()
            }
        }
    }

    var title: String
    var type: MenuType
}
