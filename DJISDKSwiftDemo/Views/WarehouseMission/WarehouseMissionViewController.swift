//
//  TimelineMissionViewController.swift
//  SDK Swift Sample
//
//  Created by Arnaud Thiercelin on 3/22/17.
//  Copyright © 2017 DJI. All rights reserved.
//

import UIKit
import DJISDK
import DJIWidget

enum WarehouseTimelineElementKind: String {
    case takeOff = "Take Off"
    case singleShootPhoto = "Single Photo"
    case aircraftYaw = "Aircraft Yaw"
    case rotate90CW = "Rotate 90CW"
    case moveRight = "Move -> 1m/s * 2s"
    case takeSnapshot = "Say Hi"
    case moveToFirstShelf = "To shelf:0"
    case moveToSecondShelf = "To shelf:1"
    case moveLeft = "Move <- 1m/s * 2s"
    case moveRightUntilNewQR = "Move till new qr"
    case scanShelf1ToRight = "Scan shelf:1 ->"
    case scanShelf2ToLeft = "Scan shelf:2 ->"
}


class WarehouseMissionViewController: IndoorFlyingViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    @IBAction func disableVSMOnTouched(_ sender: UIButton) {
        DJIHelper.setVirtualStickMode(to: false, vc: self)
    }
    var a = false
    @IBOutlet weak var previewer: UIView!
    @IBAction func clearDashboard(_ sender: UIButton) {
        self.dashboardView.text = ""
    }
    
    @IBOutlet weak var toggleA: UIButton!
    @IBAction func toggleAOnTouched(_ sender: UIButton) {
        self.a = !self.a
        sender.setTitle("Toggle A:\(self.a)", for: .normal)
    }
    
    @IBOutlet weak var lastSnapshotView: UIImageView!
    
    @IBOutlet weak var viertualModeStatusLabel: UILabel!
    
    // Steppers
    @IBOutlet weak var timeStepper: UIStepper!
    
    @IBOutlet weak var velocityStepper: UIStepper!
    
    @IBAction func timeStepperChanged(_ sender: UIStepper) {
        self.dashboardView.text += "\nSet t: \(sender.value)s"
        self.scrollDashboardToLast()
    }

    @IBAction func velocityStepperOnTouched(_ sender: UIStepper) {
        self.dashboardView.text += "\nSet v: \(sender.value)m/s"
        self.scrollDashboardToLast()
    }
    private var isPauseButtonClicked = false
    
    func scrollDashboardToLast(){
        let lastLine = NSMakeRange(self.dashboardView.text.count  - 1, 1);
        self.dashboardView.scrollRangeToVisible(lastLine)
    }
    func setUpDashboard(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            DJIHelper.fetchFlightController()?.getVirtualStickModeEnabled(completion: { (isVsmOn, nil) in
                self.viertualModeStatusLabel.text = "VSM on?: \(isVsmOn)"
            })
        }
    }
    func terminate(){
        DJIHelper.setVirtualStickMode(to: false, vc: self)
        if let _ = DJISDKManager.missionControl()?.isTimelineRunning {
            DJISDKManager.missionControl()?.stopTimeline()
        }
    }
    
    @IBAction func terminate(_ sender: UIButton) {
        self.terminate()
    }

    
    @IBAction func enableVsm(_ sender: UIButton) {
       DJIHelper.setVirtualStickMode(to: true, vc: self)
    }
    
  
    @IBOutlet weak var dashboardView: UITextView!
    
    @IBOutlet weak var availableElementsView: UICollectionView!
    
    @IBOutlet weak var timelineView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var simulatorButton: UIButton!
    
    fileprivate var _isSimulatorActive: Bool = false
    
    var availableElements = [WarehouseTimelineElementKind]()
    var scheduledElements = [WarehouseTimelineElementKind]()
    
    public var isSimulatorActive: Bool {
        get {
            return _isSimulatorActive
        }
        set {
            _isSimulatorActive = newValue
            self.simulatorButton.titleLabel?.text = _isSimulatorActive ? "Stop Simulator" : "Start Simulator"
        }
    }
    
    override class func storyboardIdentifier() -> String {
        return "WarehouseMissionViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.availableElementsView.delegate = self
        self.availableElementsView.dataSource = self
        
        self.timelineView.delegate = self
        self.timelineView.dataSource = self
        
        self.availableElements.append(contentsOf: [.takeOff,.aircraftYaw, .rotate90CW, .moveLeft, .moveRight, .moveToFirstShelf, .moveToSecondShelf, .takeSnapshot,.moveRightUntilNewQR,.scanShelf1ToRight,.scanShelf2ToLeft])
        
        self.setUpDashboard()
        self.disableColision()
        self.setUpSteppers()
        
        self.setUpAsRemoteControllerDelegate()
    }
    
    func setUpSteppers(){
        self.velocityStepper.stepValue = 0.1
        self.velocityStepper.value = 0.5
        
        self.timeStepper.stepValue = 0.5
        self.timeStepper.value = 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopSnapShotTaker()
    }
    
//    func enableColision(){
//        DJIHelper.fetchFlightController()?.flightAssistant?.setCollisionAvoidanceEnabled(true, withCompletion: { (error) in
//            if let error = error{
//                Logger.log(message: "Cannot enable collision avoidanced \(error)", event: .error)
//            }
//            Logger.log(message: "Enabled collision avoidanced", event: .error)
//        })
//    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpSnapShotTaker()
//        self.enableColision()
        self.dashboardView.setContentOffset(.zero, animated: false)
        DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            if (error != nil){
                Logger.log(message: "\(error?.localizedDescription)) started", event: .error)
            }
            
            switch event {
            case .started:
                Logger.log(message: "\(String(describing: element?.description)) started", event: .info)
                if let el = element?.description {
                    self.dashboardView.text  += "\n\(el) started"
                }
                self.didStart()
            case .stopError,.startError:
                self.didStop()
            case .stopped:
                Logger.log(message: "\(String(describing: element?.description)) stopped", event: .info)
                if let el = element?.description {
                    self.dashboardView.text  += "\n\(el) stopped"
                }
                self.didStop()
            case .paused:
                self.didPause()
            case .resumed:
                self.didResume()
            case .finished:
                Logger.log(message: "\(String(describing: element?.description)) finished", event: .info)
                if let el = element?.description {
                    self.dashboardView.text  += "\n\(el) finished"
                }
                self.didStop()
            default:
                break
            }
            self.scrollDashboardToLast()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DJISDKManager.missionControl()?.removeListener(self)
        DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    fileprivate var started = false
    fileprivate var paused = false
    
    @IBAction func playButtonAction(_ sender: Any) {
        if self.paused {
            DJISDKManager.missionControl()?.resumeTimeline()
        } else if self.started {
            DJISDKManager.missionControl()?.pauseTimeline()
        } else {
            DJISDKManager.missionControl()?.startTimeline()
        }
    }
    
    @IBAction func stopButtonAction(_ sender: Any) {
        DJISDKManager.missionControl()?.stopTimeline()
    }
    
    @IBAction func startSimulatorButtonAction(_ sender: Any) {
        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            return
        }
        
        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
            return
        }
        
        let droneLocation = droneLocationValue.value as! CLLocation
        let droneCoordinates = droneLocation.coordinate
        
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            if self.isSimulatorActive {
                aircraft.flightController?.simulator?.stop(completion: nil)
            } else {
                aircraft.flightController?.simulator?.start(withLocation: droneCoordinates, updateFrequency: 30, gpsSatellitesNumber: 12,withCompletion: { (error) in
                    if (error != nil) {
                        NSLog("Start Simulator Error: \(error.debugDescription)")
                    }
                })
            }
        }
    }
    
    func didStart() {
        self.started = true
        DispatchQueue.main.async {
            self.stopButton.isEnabled = true
            self.playButton.setTitle("⏸", for: .normal)
        }
    }
    
    func didPause() {
        self.paused = true
        DispatchQueue.main.async {
            self.playButton.setTitle("▶️", for: .normal)
        }
    }
    
    func didResume() {
        self.paused = false
        DispatchQueue.main.async {
            self.playButton.setTitle("⏸", for: .normal)
        }
    }
    
    func didStop() {
        self.started = false
        DispatchQueue.main.async {
            self.stopButton.isEnabled = false
            self.playButton.setTitle("▶️", for: .normal)
        }
    }
    
    //MARK: OutlineView Delegate & Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.availableElementsView {
            return self.availableElements.count
        } else if collectionView == self.timelineView {
            return self.scheduledElements.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "elementCell", for: indexPath) as! TimelineElementCollectionViewCell
        
        if collectionView == self.availableElementsView {
            cell.label.text = self.availableElements[indexPath.row].rawValue
        } else if collectionView == self.timelineView {
            cell.label.text = self.scheduledElements[indexPath.row].rawValue
        }
        
        return cell
    }
    
    func addMissionToTimeline(kind: WarehouseTimelineElementKind) {
        guard let element = self.timelineElementForKind(kind: kind) else {
            return;
        }
        let error = DJISDKManager.missionControl()?.scheduleElement(element)
        
        if error != nil {
            NSLog("Error scheduling element \(String(describing: error))")
            return;
        }
        
        self.scheduledElements.append(kind)
        DispatchQueue.main.async {
            self.timelineView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(self.availableElementsView) {
            let elementKind = self.availableElements[indexPath.row]
            addMissionToTimeline(kind: elementKind)
          
        } else if collectionView.isEqual(self.timelineView) {
            if self.started == false{
                DJISDKManager.missionControl()?.unscheduleElement(at: UInt(indexPath.row))
                self.scheduledElements.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.timelineView.reloadData()
                }
            }
        }
    }
    
    // MARK : Timeline Element

    
    func timelineElementForKind(kind: WarehouseTimelineElementKind) -> DJIMissionControlTimelineElement? {
        switch kind {
            case .takeOff:
                return DJITakeOffAction()
            case .singleShootPhoto:
                return DJIShootPhotoAction(singleShootPhoto: ())
            case .aircraftYaw:
                return DJIAircraftYawAction(relativeAngle: 90, andAngularVelocity: 30)
            case .rotate90CW:
                return WarehouseMission.rotate90CW()
            case .moveRight:
                return WarehouseMission.moveRight(v: 0.1, t: 10)
            case .takeSnapshot:
                return WarehouseMission.takeSnapshot(vc: self)
            case .moveToFirstShelf:
                return WarehouseMission.moveToShelf(n: 0)
            case .moveToSecondShelf:
                return WarehouseMission.moveToShelf(n: 1)
            case .moveLeft:
                return WarehouseMission.moveLeft(v: 0.5, t: 10)
            case .moveRightUntilNewQR:
                return WarehouseMission.moveRightUntilNewQR()
            case .scanShelf1ToRight:
                return WarehouseMission.scanShelf1ToRight(vc: self)
            case .scanShelf2ToLeft:
                return WarehouseMission.scanShelf2ToLeft(vc:self)
        }
    }

    // MARK: - Convenience
    func degreesToRadians(_ degrees: Double) -> Double {
        return Double.pi / 180 * degrees
    }
    
    func disableColision(){
        DJIHelper.fetchFlightController()?.flightAssistant?.setCollisionAvoidanceEnabled(false, withCompletion: { (error) in
            if let error = error{
                Logger.log(message: "Cannot disable collision avoidanced \(error)", event: .error)
            }
            NotiLogger.log(message: "Disabled collision avoidance", event: .info)
        })
        DJIHelper.fetchFlightController()?.flightAssistant?.setActiveObstacleAvoidanceEnabled(false, withCompletion: { (error) in
            if let error = error{
                Logger.log(message: "Cannot disable active collision avoidanced \(error)", event: .error)
            }
            NotiLogger.log(message: "Disabled Active avoidance", event: .info)
        })
        DJIHelper.fetchFlightController()?.flightAssistant?.setUpwardsAvoidanceEnabled(false, withCompletion: { (error) in
            if let error = error{
                Logger.log(message: "Cannot disable upward avoidanced \(error)", event: .error)
            }
            NotiLogger.log(message: "Disabled Upward avoidance", event: .info)
        })
    }
    
    override func remoteController(_ rc: DJIRemoteController, didUpdate state: DJIRCHardwareState) {
        super.remoteController(rc, didUpdate: state)
        self.setPauseButtonAsTerminateButton(state)
    }
    
    func setPauseButtonAsTerminateButton(_ state:DJIRCHardwareState){
        // Fn: toggle tripod mode
        if (state.pauseButton.isClicked.boolValue && !isPauseButtonClicked){
            self.isPauseButtonClicked = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isPauseButtonClicked = false
            }
            NotiLogger.log(message: "Pause button clicked", event: .info)
            self.terminate()
        }
    }
    
}

extension WarehouseMissionViewController: DJIVideoFeedListener{
    func setUpSnapShotTaker(){
        let videoPreviewer = DJIVideoPreviewer.instance()
        videoPreviewer?.setupVideoPreviewer(previewViewer: previewer, listener: self)
        
    }
    
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        let videoPreviewer = DJIVideoPreviewer.instance()
        let tmpVideoData = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.count)
        videoData.copyBytes(to: tmpVideoData, count: videoData.count)
        videoPreviewer?.push(tmpVideoData, length: Int32(videoData.count))
    }
    func stopSnapShotTaker(){
        DJIVideoPreviewer.instance()?.removeVideoPreviewer(listener: self)
        DJIVideoPreviewer.instance()?.reset()
        DJIVideoPreviewer.instance()?.close()
    }
}

