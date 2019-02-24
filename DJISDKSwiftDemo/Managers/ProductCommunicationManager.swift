//
//  ProductCommunicationManager.swift
//  SDK Swift Sample
//
//  Created by Arnaud Thiercelin on 3/22/17.
//  Copyright © 2017 DJI. All rights reserved.
//

import UIKit
import DJISDK

final class ProductCommunicationManager: NSObject {

    static let shared = ProductCommunicationManager()
    private static let bridgeIdAppKey = "DJIAppBridgeAppId"

    override private init() {}

    // Set this value to true to use the app with the Bridge and false to connect directly to the product
    var enableBridgeMode: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    var productKey: DJIKey? {
        return DJIProductKey(param: DJIParamConnection)
    }

    var bridgeAppId: String {
        guard let bridgeAppId = Bundle.main.object(forInfoDictionaryKey: ProductCommunicationManager.bridgeIdAppKey) as? String,
            !bridgeAppId.isEmpty else {
            NotiLogger.log(message: "Please enter your bridge app id in the info.plist", event: .error)
            return ""
        }
        return bridgeAppId
    }

    func registerWithSDK() {
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String,
            !appKey.isEmpty else {
            NotiLogger.log(message: "Please enter your app key in the info.plist", event: .error)
            return
        }
        DJISDKManager.registerApp(with: self)
    }
    
}

extension ProductCommunicationManager : DJISDKManagerDelegate {
    func appRegisteredWithError(_ error: Error?) {
        NotiLogger.log(message: "SDK Registered with error \(error?.localizedDescription ?? "")", event: .error)
        if enableBridgeMode {
            DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppId)
        } else {
            DJISDKManager.startConnectionToProduct()
        }
        
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        product?.delegate = self
        NotificationCenter.default.post(name: .didProductConnected, object: nil)
    }
    
    func productDisconnected() {        
        NotificationCenter.default.post(name: .didProductDisConnected, object: nil)
    }
    
    func componentConnected(withKey key: String?, andIndex index: Int) {
        
    }
    
    func componentDisconnected(withKey key: String?, andIndex index: Int) {
        
    }
}

extension ProductCommunicationManager: DJIBaseProductDelegate {
    
}
