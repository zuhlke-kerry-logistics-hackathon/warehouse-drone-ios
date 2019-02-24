//
//  StartupViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 11/13/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import UIKit
import DJISDK

class StartupViewController: BaseViewController {

    @IBOutlet weak var productConnectionStatus: UILabel!
    @IBOutlet weak var productModel: UILabel!
    @IBOutlet weak var productFirmwarePackageVersion: UILabel!
    @IBOutlet weak var openComponents: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var sdkVersionLabel: UILabel!
    @IBOutlet weak var bridgeModeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.showHideNavBar(hide: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.registerAndLsitenToConnectedKey(completion: { [weak self] isConnected in
                guard isConnected else {
                    return
                }
                self?.productConnected()
            })

            self?.retrieveConnectionStatus(completion: { [weak self] isConnected in
                guard isConnected else {
                    return
                }
                self?.productConnected()
            })

        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showHideNavBar(hide: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
    }

    private func setupUI() {
        let isBridgeModeEnabled = ProductCommunicationManager.shared.enableBridgeMode
        self.navigationController?.navigationBar.isHidden = true
        self.sdkVersionLabel.text = "DJI SDK Version: \(DJISDKManager.sdkVersion())"
        self.openComponents.isEnabled = false; //FIXME: set it back to false        
        self.productModel.isHidden = true
        self.productFirmwarePackageVersion.isHidden = true
        self.bridgeModeLabel.isHidden = !isBridgeModeEnabled
        
        if isBridgeModeEnabled {
            self.bridgeModeLabel.text = "Bridge: \(ProductCommunicationManager.shared.bridgeAppId)"
        }

    }

    private func registerAndLsitenToConnectedKey(completion:@escaping ((_ isConnected: Bool) -> Void)) {
        guard let connectedKey = ProductCommunicationManager.shared.productKey else {
            NotiLogger.log(message: "Fail to get the product key", event: .error)
            return;
        }
        DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
            guard let isConnected = newValue?.boolValue,
                isConnected else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true)
            }
        })
    }

    private func retrieveConnectionStatus(completion:@escaping ((_ isConnected: Bool) -> Void)) {
        guard let connectedKey = ProductCommunicationManager.shared.productKey else {
            NotiLogger.log(message: "Fail to get the product key", event: .error)
            return;
        }
        DJISDKManager.keyManager()?.getValueFor(connectedKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
            guard let isConnected = value?.boolValue,
                isConnected else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true)
            }
        })
    }

    private func productConnected() {
        guard let newProduct = DJISDKManager.product() else {
            Logger.log(message: "Product is connected but DJISDKManager.product is nil -> something is wrong", event: .debug)
            return;
        }

        //Updates the product's model
        self.productModel.text = "Model: \((newProduct.model)!)"
        self.productModel.isHidden = false
        
        //Updates the product's firmware version - COMING SOON
        newProduct.getFirmwarePackageVersion{ (version:String?, error:Error?) -> Void in
            self.productFirmwarePackageVersion.text = "Firmware Package Version: \(version ?? "Unknown")"
            
            if let _ = error {
                self.productFirmwarePackageVersion.isHidden = true
            } else {
                self.productFirmwarePackageVersion.isHidden = false
            }
            Logger.log(message: "Firmware package version is: \(version ?? "Unknown")", event: .debug)
        }
        
        //Updates the product's connection status
        self.productConnectionStatus.text = "Status: Product Connected"
        
        self.openComponents.isEnabled = true;
        self.openComponents.alpha = 1.0;
        Logger.log(message: "Product connected", event: .debug)
    }
    
    private func productDisconnected() {
        self.productConnectionStatus.text = "Status: No Product Connected"

        self.openComponents.isEnabled = false;
        self.openComponents.alpha = 0.8;
        Logger.log(message: "Product disconnected", event: .debug)
    }

    private func showHideNavBar(hide: Bool) {
        self.navigationController?.navigationBar.isHidden = hide
    }

    @IBAction func openButtonDidTap(_ sender: UIButton) {
        self.navigateToViewController(storyboardIdentifier: MenuListViewController.storyboardIdentifier())
    }

    @IBAction func skipButtonDidTap(_ sender: UIButton) {
        self.navigateToViewController(storyboardIdentifier: MenuListViewController.storyboardIdentifier())
    }
    
}





