//
//  NotiLogger.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 18/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//


import Foundation
import NotificationBannerSwift

final class NotiLogger {
    static public func log(
        message: String,
        event: LogEvent,
        time: TimeInterval = 0.5,
        fileName: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function) {
        Logger.log(message: message, event: event)
        switch event {
        case .info, .error:
            let bannerStyle: BannerStyle = (.info == event) ? .info : .danger
            let banner = NotificationBanner(
                title: message,
                subtitle: nil,
                leftView: nil,
                rightView: nil,
                style: bannerStyle)
            banner.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                banner.dismiss()
            }
        default:
            break
        }
    }

}
