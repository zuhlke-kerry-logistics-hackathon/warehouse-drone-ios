//
//  AutoFlyViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Pak Wai Lau on 29/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJISDK
import DJIWidget

class AutoFlyViewController: BaseViewController, DJIFlightControllerDelegate {

    let MAX_HEADING_ORIENTATION_ERROR:CGFloat = 0.8
    
    var callibrationTimer: Timer?
    var isCallibrationFinish = false
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var droneControlDataLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var calibrationResultLabel: UILabel!
    
    @IBOutlet weak var landButton: UIButton!
    @IBAction func stopButtonOnTouched(_ sender: UIButton) {
        DJIHelper.fetchFlightController()?.setVirtualStickModeEnabled(false) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }else {
                DJIHelper.showAlertView(vc: self, title: "Great", message: "virtual stick mode set to false")
            }
        }
    }
    
    @IBAction func turnOnVirtualModeButtonOnTouched(_ sender: UIButton) {
        DJIHelper.fetchFlightController()?.setVirtualStickModeEnabled(true){(error) in
            if let error = error {
                Logger.log(message: error.localizedDescription, event: .error)
            }else {
                DJIHelper.showAlertView(vc: self, title: "Great", message: "virtual stick mode set to true")
            }
        }
    }
    
    @IBAction func takeOffButtonOnTouched(_ sender: Any) {
        if let fc = DJIHelper.fetchFlightController(){
            fc.startTakeoff { (error) in
                DJIHelper.showAlertView(vc: self, title: "", message: "Take off success")
            }
        }
    }
    @IBAction func resetGimbalButton(_ sender: UIButton) {
        self.resetGimbal()
    }
    
    @IBAction func rotateCW90ButtonOnTouched(_ sender: Any) {
        debugPrint("\(index): Begin rotate 90 degree")
        guard let heading =  DJIHelper.getHeading() else {
            return
        }
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.rotateDrone(withAngleCW: 90, heading: heading)
        }
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        timer.fire()
        RunLoop.current.run(until: Date().addingTimeInterval(5))
        debugPrint("\(index): After 2s: Invalidate rotate 90 degree")
        timer.invalidate()
        
    }
    
    @IBAction func forwardButtonOnTouched(_ sender: Any) {
    }
    
    @IBAction func calibrateOrientationButtonOnTouched(_ sender: UIButton) {
        calibrateOrientation()
    }
    
    @IBAction func stopCalibrationButtonOnTouched(_ sender: UIButton) {
        callibrationTimer?.invalidate()
        callibrationTimer = nil
    }
    
    @IBAction func landingButtonOnTouched(_ sender: Any) {
        if let fc = DJIHelper.fetchFlightController(){
            fc.startLanding { (error) in
                DJIHelper.showAlertView(vc: self, title: "Landing", message: "")
            }
        }
    }

    override class func storyboardIdentifier() -> String {
        return "AutoFlyViewController"
    }
    
    func rotateDrone(withAngleCW: Float, heading:Double){
        if let fc = DJIHelper.fetchFlightController() {
            var angle = Float(heading) + withAngleCW
            if (angle > 180 ){
                angle -= 360
            }else if ( angle < -180){
                angle += 360
            }
            self.droneControlDataLabel.text = "withAngleCW: \(withAngleCW), Rotating to: \(angle)"
            let controlData = DJIVirtualStickFlightControlData(pitch: 0, roll: 0, yaw: angle, verticalThrottle: 0 )
            fc.yawControlMode = .angle
            fc.rollPitchCoordinateSystem = .body
            fc.verticalControlMode = .velocity
            fc.isVirtualStickAdvancedModeEnabled = true
            fc.send(controlData) { (error) in
                if let error = error {
                    DJIHelper.showAlertView(vc: self, title: "Oops", message: error.localizedDescription)
                }
            }
        }
    }
    
    func setUpFlightController() {
        if let fc = DJIHelper.fetchFlightController(){
            fc.delegate = self
            fc.rollPitchCoordinateSystem = .body
            fc.rollPitchControlMode = .velocity
            fc.verticalControlMode = .velocity
            fc.yawControlMode = .angle
        }
    }
    
    func resetGimbal() {
        if let gimbal = DJIHelper.fetchAircraft()?.gimbal{
            gimbal.reset(completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFlightController()
        
        resetGimbal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpPreviewer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DJIVideoPreviewer.instance()?.removeVideoPreviewer(listener: self)
        DJIVideoPreviewer.instance()?.reset()
        DJIVideoPreviewer.instance()?.close()
    }
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        if let heading = fc.compass?.heading{
            self.headingLabel.text = ("Heading: \(heading)")
        }
    }
}

extension AutoFlyViewController:DJIGimbalDelegate{
    func gimbal(_ gimbal: DJIGimbal, didUpdate state: DJIGimbalState) {
    }
    
    
    func checkQRCode(completionBlock: @escaping ((_ feature: CIQRCodeFeature?) -> Void)) {
        DispatchQueue.main.async {
            DJIVideoPreviewer.instance()?.snapshotPreview({ (previewImage) in
                guard let previewImage = previewImage else {
                    debugPrint("[Drone] missing preview image")
                    return
                }
                let qrCodeFeatures = QRCodeHelper.detectQRCode(previewImage)
                return completionBlock(qrCodeFeatures?.count ?? 0 > 0 ? qrCodeFeatures?[0] : nil)
            })
        }
    }
    
    func calibrateOrientationOnceIn(_ seconds:Double){
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { _ in
            self.calibrateOrientation()
        })
    }
    
    @objc
    func calibrateOrientation() {
        if let gimbal = DJIHelper.fetchAircraft()?.gimbal{
            gimbal.delegate = self
            gimbal.face(direction: .Downward, handleErrorVC: self)
            sleep(1)
            self.checkQRCode { qrCodeFeature in
                if let feature = qrCodeFeature, let heading =  DJIHelper.getHeading() {
                    // top left as origin
                    let angle = feature.topRight.angle(to: feature.topLeft) - 180.0
                    if (abs(angle) < self.MAX_HEADING_ORIENTATION_ERROR) {
                        self.calibrationResultLabel.text = "Obtained perfect angle:\(angle)"
                    }else{
                        self.calibrationResultLabel.text = ("Will rotate \(angle) degrees")
                        guard let fc = DJIHelper.fetchFlightController() else { return }
                        
                        // Rotate the drone if virtual stick mode is on
                        fc.getVirtualStickModeEnabled(completion: { (isEnabled, nil) in
                            if (isEnabled){
                                // Send signal in 10Hz
                                let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                    debugPrint("setting timer 10hz, heading:\(heading)")
                                    self.rotateDrone(withAngleCW: Float(angle * -1), heading: heading)
                                })
                                RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
                                timer.fire()
                                RunLoop.current.run(until: Date().addingTimeInterval(1))
                                timer.invalidate()
                            }
                            self.calibrationResultLabel.text = "Bad Angle:\(angle) Try again in 2 sec"
                            self.calibrateOrientationOnceIn(2)
                        })
                    }
                }else{
                    debugPrint("No Feature")
                    self.calibrationResultLabel.text = "No Feature, Try again in 2 sec"
                    self.calibrateOrientationOnceIn(2)
                }
            }
        }
    }
}


extension AutoFlyViewController: DJIVideoFeedListener {
    func setUpPreviewer() {
        DJIVideoPreviewer.instance()?.setupVideoPreviewer(
            previewViewer: self.previewView,
            listener: self
        )
    }
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        let videoPreviewer = DJIVideoPreviewer.instance()
        let tmpVideoData = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.count)
        videoData.copyBytes(to: tmpVideoData, count: videoData.count)
        videoPreviewer?.push(tmpVideoData, length: Int32(videoData.count))
    }
}
